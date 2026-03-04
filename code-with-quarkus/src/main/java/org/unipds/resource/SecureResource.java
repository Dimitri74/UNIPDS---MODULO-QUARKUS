package org.unipds.resource;

import jakarta.annotation.security.RolesAllowed;
import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import org.eclipse.microprofile.jwt.Claim;
import org.eclipse.microprofile.jwt.Claims;
import org.eclipse.microprofile.jwt.JsonWebToken;

@Path("secure")
@RequestScoped
public class SecureResource {

    @Inject
    JsonWebToken jwt;

    @Claim(standard = Claims.preferred_username)
    String username;

    @GET
    @Path("claim")
    @RolesAllowed({"Not-Subscriber", "Subscriber", "Admin", "User"})
    @Produces(MediaType.TEXT_PLAIN)
    public String getClaim(){
        return username != null ? username : jwt.getName();
    }

    @GET
    @Path("info")
    @RolesAllowed({"Not-Subscriber", "Subscriber", "Admin", "User"})
    @Produces(MediaType.APPLICATION_JSON)
    public String getTokenInfo(){
        StringBuilder info = new StringBuilder();
        info.append("{\n");
        info.append("  \"username\": \"").append(jwt.getName()).append("\",\n");
        info.append("  \"groups\": ").append(jwt.getGroups()).append(",\n");
        info.append("  \"issuer\": \"").append(jwt.getIssuer()).append("\",\n");
        info.append("  \"subject\": \"").append(jwt.getSubject()).append("\"\n");
        info.append("}");
        return info.toString();
    }
}

