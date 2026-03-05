package org.unipds.healthcheck;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Liveness;
import org.eclipse.microprofile.rest.client.inject.RestClient;
import org.unipds.service.StarWarsService;

import java.time.LocalDateTime;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Health Check para verificar a disponibilidade da API Star Wars de forma passiva
 */
@ApplicationScoped
@Liveness
public class StarWarsHealthCheck implements HealthCheck {

    @Inject
    @RestClient
    StarWarsService starWarsService;

    // Cache para evitar chamadas excessivas (estratégia passiva/suave)
    private final AtomicReference<HealthCheckStatus> lastStatus = new AtomicReference<>();
    private static final int CACHE_SECONDS = 60;

    @Override
    public HealthCheckResponse call() {
        HealthCheckStatus current = lastStatus.get();
        
        // Se temos um status recente, usamos ele para não sobrecarregar a API externa
        if (current != null && current.timestamp.isAfter(LocalDateTime.now().minusSeconds(CACHE_SECONDS))) {
            return buildResponse(current.up, "Status em cache (" + CACHE_SECONDS + "s)");
        }

        try {
            // Tenta fazer uma chamada simples à API
            String response = starWarsService.getStarships();

            boolean isUp = response != null && !response.isEmpty();
            lastStatus.set(new HealthCheckStatus(isUp, LocalDateTime.now()));
            
            return buildResponse(isUp, isUp ? "I am Ready!" : "I am Not Ready.");
        } catch (Exception e) {
            // Em caso de erro, se tivermos um status anterior, podemos ser tolerantes ou reportar erro
            // Aqui decidimos reportar o erro, mas atualizamos o timestamp para não tentar de novo imediatamente
            lastStatus.set(new HealthCheckStatus(false, LocalDateTime.now()));
            return HealthCheckResponse.builder()
                    .down()
                    .name("StarWars API Health Check")
                    .withData("error", e.getMessage())
                    .build();
        }
    }

    private HealthCheckResponse buildResponse(boolean up, String status) {
        return HealthCheckResponse.builder()
                .status(up)
                .name("StarWars API Health Check")
                .withData("status", status)
                .build();
    }

    private static class HealthCheckStatus {
        final boolean up;
        final LocalDateTime timestamp;

        HealthCheckStatus(boolean up, LocalDateTime timestamp) {
            this.up = up;
            this.timestamp = timestamp;
        }
    }
}

