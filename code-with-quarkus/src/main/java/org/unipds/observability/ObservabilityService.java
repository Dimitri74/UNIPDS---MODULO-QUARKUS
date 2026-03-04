package org.unipds.observability;

import io.opentelemetry.api.metrics.Meter;
import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.instrumentation.annotations.SpanAttribute;
import io.opentelemetry.instrumentation.annotations.WithSpan;
import jakarta.inject.Singleton;

/**
 * Classe de observabilidade para registrar spans e métricas customizados
 */
@Singleton
public class ObservabilityService {

    private final Tracer tracer;
    private final Meter meter;

    public ObservabilityService(Tracer tracer, Meter meter) {
        this.tracer = tracer;
        this.meter = meter;
    }

    /**
     * Exemplo de método com tracing automático
     */
    @WithSpan
    public String processarRequisicao(@SpanAttribute String recurso) {
        return "Processando: " + recurso;
    }

    /**
     * Exemplo de método com tracing automático e múltiplos atributos
     */
    @WithSpan
    public void registrarOperacao(
            @SpanAttribute String operacao,
            @SpanAttribute String usuario,
            @SpanAttribute long duracao) {
        // Lógica de negócio
    }

    /**
     * Retorna o tracer para uso manual se necessário
     */
    public Tracer getTracer() {
        return tracer;
    }

    /**
     * Retorna o meter para uso manual se necessário
     */
    public Meter getMeter() {
        return meter;
    }
}

