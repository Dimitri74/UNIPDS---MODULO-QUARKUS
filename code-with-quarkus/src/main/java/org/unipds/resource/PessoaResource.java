package org.unipds.resource;

import io.opentelemetry.instrumentation.annotations.SpanAttribute;
import io.opentelemetry.instrumentation.annotations.WithSpan;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import io.micrometer.core.annotation.Counted;
import org.unipds.entity.Pessoa;
import org.unipds.observability.ObservabilityService;

import java.util.List;

@Path("pessoa")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PessoaResource {

    @Inject
    ObservabilityService observabilityService;

    @GET
    @Counted(value = "counted.getPessoa")
    @WithSpan
    public List<Pessoa> getPessoa() {
        return Pessoa.listAll();
    }

    @GET
    @Path("findByAnoNascimento")
    @WithSpan
    public List<Pessoa> findByAnoNascimento(@QueryParam("anoNascimento") @SpanAttribute int anoNascimento) {
        return Pessoa.findByAnoNascimento(anoNascimento);
    }


    @POST
    @Transactional
    @WithSpan
    public Pessoa createPessoa(@SpanAttribute Pessoa pessoa) {
        pessoa.id = null;
        pessoa.persist();

        return pessoa;
    }

    @PUT
    @Transactional
    @WithSpan
    public Pessoa updatePessoa(@SpanAttribute Pessoa pessoa) {
        Pessoa p = Pessoa.findById(pessoa.id);
        p.nome = pessoa.nome;
        p.anoNascimento = pessoa.anoNascimento;
        p.persist();

        return p;
    }

    @DELETE
    @Transactional
    @WithSpan
    public void deletePessoa(@SpanAttribute int id) {
        Pessoa.deleteById(id);
    }
}


