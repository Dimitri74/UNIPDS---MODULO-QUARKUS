package org.unipds.resource;

import io.opentelemetry.instrumentation.annotations.WithSpan;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.rest.client.inject.RestClient;
import org.unipds.observability.ObservabilityService;
import org.unipds.service.StarWarsService;

@Path("starwars")
@Produces(MediaType.APPLICATION_JSON)
public class StarWarsResource {

    @Inject
    @RestClient
    StarWarsService starWarsService;

    @Inject
    ObservabilityService observabilityService;

    @GET
    @Path("starships")
    @WithSpan
    public String getStarships(){
        return starWarsService.getStarships();
    }
}