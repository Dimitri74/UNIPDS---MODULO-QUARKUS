package com.unipds;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;


import io.quarkus.hibernate.reactive.panache.Panache;
import io.smallrye.mutiny.Uni;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.PUT;
import jakarta.ws.rs.Path;

import java.util.List;

@Path("/pagamentos")
public class PagamentoResource {

    @GET
    public Uni<List<Pagamento>> lista() {
        return Pagamento.listAll();
    }

    @GET
    @Path("/{id}")
    public Uni<Pagamento> porId(Long id) {
        return Pagamento.findById(id);
    }

    @PUT
    @Path("/{id}")
    public  Uni<Pagamento> confirma(Long id) {
        return Panache.withTransaction(() ->
                Pagamento.<Pagamento>findById(id)
                        .onItem().ifNotNull().invoke(pagamento -> {
                            pagamento.status = StatusPagamento.CONFIRMADO;
                        }));
    }

}