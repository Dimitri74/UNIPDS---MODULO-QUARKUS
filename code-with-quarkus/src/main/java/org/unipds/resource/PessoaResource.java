package org.unipds.resource;

import io.opentelemetry.instrumentation.annotations.SpanAttribute;
import io.opentelemetry.instrumentation.annotations.WithSpan;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import io.micrometer.core.annotation.Counted;
import org.unipds.dto.PessoaDTO;
import org.unipds.entity.Pessoa;
import org.unipds.observability.ObservabilityService;

import java.util.List;
import java.util.stream.Collectors;

@Path("pessoa")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class PessoaResource {

    @Inject
    ObservabilityService observabilityService;

    @GET
    @Counted(value = "counted.getPessoa")
    @WithSpan
    public List<PessoaDTO> getPessoa() {
        return Pessoa.<Pessoa>listAll().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }

    @GET
    @Path("findByAnoNascimento")
    @WithSpan
    public List<PessoaDTO> findByAnoNascimento(@QueryParam("anoNascimento") @SpanAttribute int anoNascimento) {
        return Pessoa.findByAnoNascimento(anoNascimento).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
    }


    @POST
    @Transactional
    @WithSpan
    public PessoaDTO createPessoa(@Valid @SpanAttribute PessoaDTO pessoaDTO) {
        Pessoa pessoa = new Pessoa();
        pessoa.nome = pessoaDTO.nome;
        pessoa.anoNascimento = pessoaDTO.anoNascimento;
        pessoa.persist();

        return toDTO(pessoa);
    }

    @PUT
    @Transactional
    @WithSpan
    public PessoaDTO updatePessoa(@Valid @SpanAttribute PessoaDTO pessoaDTO) {
        Pessoa p = Pessoa.findById(pessoaDTO.id);
        if (p == null) {
            throw new NotFoundException("Pessoa não encontrada");
        }
        p.nome = pessoaDTO.nome;
        p.anoNascimento = pessoaDTO.anoNascimento;
        p.persist();

        return toDTO(p);
    }

    @DELETE
    @Transactional
    @WithSpan
    public void deletePessoa(@SpanAttribute int id) {
        Pessoa.deleteById(id);
    }

    private PessoaDTO toDTO(Pessoa pessoa) {
        return new PessoaDTO(pessoa.id, pessoa.nome, pessoa.anoNascimento);
    }
}


