package com.unipds.consumer;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.unipds.event.PagamentoConfirmado;
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
        LOG.info("Recebido evento de pagamento confirmado em notas-fiscais: " + payload);

        final PagamentoConfirmado pagamentoConfirmado;
        try {
            pagamentoConfirmado = objectMapper.readValue(payload, PagamentoConfirmado.class);
        } catch (Exception e) {
            // Evento invalido nao deve derrubar o consumo do topico.
            LOG.error("Payload invalido para evento de pagamento confirmado. Evento descartado.", e);
            return Uni.createFrom().voidItem();
        }

        LOG.info("Pagamento confirmado desserializado: " + pagamentoConfirmado);

        if (pagamentoConfirmado.pedidoId == null) {
            LOG.warn("Evento de pagamento confirmado sem pedidoId. Evento descartado.");
            return Uni.createFrom().voidItem();
        }

        // Aqui voce pode implementar a logica para gerar nota fiscal automaticamente.
        // Por enquanto, apenas registramos o evento.
        registrarEventoPagamentoConfirmado(pagamentoConfirmado);
        return Uni.createFrom().voidItem();
    }

    private void registrarEventoPagamentoConfirmado(PagamentoConfirmado evento) {
        LOG.info("Nota fiscal será gerada para pedido: " + evento.pedidoId + 
                 " (Pagamento: " + evento.pagamentoId + ")");
        // TODO: Implementar lógica de persistência ou geração de nota fiscal
    }
}
