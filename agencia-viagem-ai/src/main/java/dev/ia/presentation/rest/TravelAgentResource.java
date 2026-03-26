package dev.ia.presentation.rest;


import dev.ia.service.PackageExpertWithTemplate;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;

@Path("/travel")
public class TravelAgentResource {

    @Inject
    PackageExpertWithTemplate expert;

    @POST
    @Consumes(MediaType.TEXT_PLAIN)
    @Produces(MediaType.TEXT_PLAIN)
    public String ask(String question, @HeaderParam("X-User-Name") String userName) {
        if (userName != null && !userName.isEmpty()) {
            return expert.chat(userName, question, userName);
        } else {
            return "Usuário precisa estar autenticado!";
        }
    }
}