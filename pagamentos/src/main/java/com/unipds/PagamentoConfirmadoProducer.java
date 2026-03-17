package com.unipds;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.smallrye.mutiny.Uni;
import io.smallrye.reactive.messaging.MutinyEmitter;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.reactive.messaging.Outgoing;
import org.eclipse.microprofile.reactive.messaging.Channel;
import org.jboss.logging.Logger;

@ApplicationScoped
public class PagamentoConfirmadoProducer {

    private static final Logger LOG = Logger.getLogger(PagamentoConfirmadoProducer.class);

    @Inject
    ObjectMapper objectMapper;

    @Inject
    @Channel("pagamentos-confirmados")
    MutinyEmitter<String> emitter;

    public Uni<Void> publicarPagamentoConfirmado(Long pagamentoId, Long pedidoId) {
        try {
            PagamentoConfirmado evento = new PagamentoConfirmado(pagamentoId, pedidoId);
            String payload = objectMapper.writeValueAsString(evento);

            LOG.info("Publicando evento de pagamento confirmado: " + payload);

            return emitter.send(payload);
        } catch (Exception e) {
            LOG.error("Erro ao publicar evento de pagamento confirmado", e);
            return Uni.createFrom().failure(e);
        }
    }
}

