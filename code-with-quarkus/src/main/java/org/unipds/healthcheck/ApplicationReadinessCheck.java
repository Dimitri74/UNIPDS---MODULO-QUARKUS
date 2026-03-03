package org.unipds.healthcheck;

import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Readiness;

/**
 * Health Check de prontidão da aplicação
 * Verifica se a aplicação está pronta para receber requisições
 */
@ApplicationScoped
@Readiness
public class ApplicationReadinessCheck implements HealthCheck {

    @Override
    public HealthCheckResponse call() {
        return HealthCheckResponse.up("Application Readiness Check");
    }
}

