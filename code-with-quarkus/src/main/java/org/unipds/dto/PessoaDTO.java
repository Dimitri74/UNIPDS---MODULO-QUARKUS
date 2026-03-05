package org.unipds.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class PessoaDTO {

    public Long id;

    @NotBlank(message = "O nome é obrigatório")
    @Size(min = 3, max = 100, message = "O nome deve ter entre 3 e 100 caracteres")
    public String nome;

    @Min(value = 1900, message = "Ano de nascimento inválido")
    @Max(value = 2026, message = "Ano de nascimento não pode ser no futuro")
    public int anoNascimento;

    public PessoaDTO() {
    }

    public PessoaDTO(Long id, String nome, int anoNascimento) {
        this.id = id;
        this.nome = nome;
        this.anoNascimento = anoNascimento;
    }
}
