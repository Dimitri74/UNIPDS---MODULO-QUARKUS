package com.unipds;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.quarkus.hibernate.reactive.panache.Panache;
import io.smallrye.mutiny.Uni;
import io.smallrye.reactive.messaging.annotations.Blocking;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.reactive.messaging.Incoming;
import org.jboss.logging.Logger;

@ApplicationScoped
public class PagamentoConfirmadoConsumer {

    private static final Logger LOG = Logger.getLogger(PagamentoConfirmadoConsumer.class);

    @Inject
    ObjectMapper objectMapper;

    @Incoming("pagamentos-confirmados")
    public Uni<Void> consumePagamentoConfirmado(String payload) {
        LOG.info("Recebido evento de pagamento confirmado: " + payload);

        final PagamentoConfirmado pagamentoConfirmado;
        try {
            pagamentoConfirmado = objectMapper.readValue(payload, PagamentoConfirmado.class);
        } catch (Exception e) {
            // Evento inválido não deve derrubar o consumo do tópico.
            LOG.error("Payload inválido para evento de pagamento confirmado. Evento descartado.", e);
            return Uni.createFrom().voidItem();
        }

        LOG.info("Pagamento confirmado desserializado: " + pagamentoConfirmado);

        if (pagamentoConfirmado.pedidoId == null) {
            LOG.warn("Evento de pagamento confirmado sem pedidoId. Evento descartado.");
            return Uni.createFrom().voidItem();
        }

        return atualizarStatusPedido(pagamentoConfirmado.pedidoId);
    }

    private Uni<Void> atualizarStatusPedido(Long pedidoId) {
        return Panache.withTransaction(() ->
                Pedido.<Pedido>findById(pedidoId)
                        .onItem().ifNotNull().invoke(pedido -> {
                            if (StatusPedido.REALIZADO.equals(pedido.status) || StatusPedido.CONFIRMADO.equals(pedido.status)) {
                                pedido.status = StatusPedido.PAGO;
                                LOG.info("Status do Pedido " + pedidoId + " atualizado para PAGO");
                            } else {
                                LOG.warn("Pedido " + pedidoId + " não está em estado REALIZADO ou CONFIRMADO. Status atual: " + pedido.status);
                            }
                        })
                        .onItem().ifNull().continueWith(() -> {
                            LOG.warn("Pedido " + pedidoId + " não encontrado");
                            return null;
                        })
        ).replaceWithVoid();
    }
}
