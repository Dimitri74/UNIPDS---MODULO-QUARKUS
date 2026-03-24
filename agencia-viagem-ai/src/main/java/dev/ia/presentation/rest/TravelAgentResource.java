package dev.ia.presentation.rest;



import dev.ia.application.ai.PackageExpert;
import dev.ia.security.SecurityContext;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;

@Path("/travel")
public class TravelAgentResource {

    @Inject
    PackageExpert expert;

    @POST
    @Consumes(MediaType.TEXT_PLAIN)
    @Produces(MediaType.TEXT_PLAIN)
    public String ask(String question, @HeaderParam("X-User-Name") String userName) {
        if (userName != null && !userName.isEmpty()) {
            try {
                SecurityContext.setCurrentUser(userName);
                return expert.chat(userName, question); // Usar userName como memoryId
            } finally {
                SecurityContext.clear();
            }
        } else {
            return "Usuário precisa estar autenticado!";
        }
    }
}