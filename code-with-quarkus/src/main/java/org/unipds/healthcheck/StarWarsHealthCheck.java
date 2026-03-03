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
                return HealthCheckResponse.up("StarWars API Health Check , I am Ready!");
            } else {
                return HealthCheckResponse.down("StarWars API Health Check ,  I am Not Ready.");
            }
        } catch (Exception e) {
            return HealthCheckResponse.down("StarWars API Health Check");
        }
    }
}

