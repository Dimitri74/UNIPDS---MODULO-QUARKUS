package com.unipds.service;


import com.unipds.dto.PedidoDto;
import io.smallrye.mutiny.Uni;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;

import java.math.BigDecimal;

@Path("/pedidos")
@RegisterRestClient(configKey = "pedido-api")
public interface PedidoService {

    @GET
    @Path("/{id}")
    Uni<PedidoDto> getById(@PathParam("id") Long pedidoId);

    default Uni<String> notaFiscal(Long pedidoId, BigDecimal valor) {
        return getById(pedidoId)
                .onItem().ifNotNull().transform(pedido -> {
                    String nome = (pedido.cliente != null && pedido.cliente.nome != null) ? pedido.cliente.nome : "N/A";
                    String cpf = (pedido.cliente != null && pedido.cliente.cpf != null) ? pedido.cliente.cpf : "N/A";
                    String celular = (pedido.cliente != null && pedido.cliente.celular != null) ? pedido.cliente.celular : "N/A";
                    String endereco = (pedido.cliente != null && pedido.cliente.endereco != null) ? pedido.cliente.endereco : "N/A";
                    
                    return """
                        <xml>
                          <valor>%s</valor>
                          <cliente>
                            <nome>%s</nome>
                            <cpf>%s</cpf>
                            <celular>%s</celular>
                            <endereco>%s</endereco>
                          </cliente>
                        </xml>
                        """.formatted(valor, nome, cpf, celular, endereco);
                })
                .onItem().ifNull().continueWith(() -> "Pedido não encontrado");
    }
}