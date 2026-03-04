package org.unipds.healthcheck;

import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Liveness;
import org.eclipse.microprofile.rest.client.inject.RestClient;
import org.unipds.service.StarWarsService;

/**
 * Health Check para verificar a disponibilidade da API Star Wars
 */
@ApplicationScoped
@Liveness
public class StarWarsHealthCheck implements HealthCheck {

    @Inject
    @RestClient
    StarWarsService starWarsService;

    @Override
    public HealthCheckResponse call() {
        try {
            // Tenta fazer uma chamada simples à API
            String response = starWarsService.getStarships();

            if (response != null && !response.isEmpty()) {
                return HealthCheckResponse.builder()
                        .up()
                        .name("StarWars API Health Check")
                        .withData("status", "I am Ready!")
                        .build();
            } else {
                return HealthCheckResponse.builder()
                        .down()
                        .name("StarWars API Health Check")
                        .withData("status", "I am Not Ready.")
                        .build();
            }
        } catch (Exception e) {
            return HealthCheckResponse.builder()
                    .down()
                    .name("StarWars API Health Check")
                    .withData("error", e.getMessage())
                    .build();
        }
    }
}

