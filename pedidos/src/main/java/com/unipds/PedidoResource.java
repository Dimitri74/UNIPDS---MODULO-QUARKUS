package com.unipds;

import io.quarkus.hibernate.reactive.panache.common.WithTransaction;
import io.quarkus.panache.common.Parameters;
import io.smallrye.mutiny.Uni;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.List;

@Path("/pedidos")
public class PedidoResource {

    @GET
    @WithTransaction
    public Uni<List<Pedido>> lista() {
        return Pedido.find("SELECT DISTINCT p FROM Pedido p LEFT JOIN FETCH p.itensPedido").list();
    }

    @GET
    @Path("/{id}")
    @WithTransaction
    public Uni<Pedido> porId(Long id) {
        return Pedido.find("FROM Pedido p LEFT JOIN FETCH p.itensPedido WHERE p.id = :id", Parameters.with("id", id))
                .firstResult();
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    @WithTransaction
    public Uni<Response> criar(Pedido pedido) {
        return Pedido.<Pedido>persist(pedido)
                .map(p -> Response.status(Response.Status.CREATED).entity(p).build());
    }

}