package org.unipds.resource;

import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.rest.client.inject.RestClient;
import org.unipds.service.StarWarsService;

@Path("starwars")
@Produces(MediaType.APPLICATION_JSON)
public class StarWarsResource {

    @Inject
    @RestClient
    StarWarsService starWarsService;

    @GET
    @Path("starships")
    public String getStarships(){
        return starWarsService.getStarships();
    }
}