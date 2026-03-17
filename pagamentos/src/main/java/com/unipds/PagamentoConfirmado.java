package com.unipds;

import com.fasterxml.jackson.annotation.JsonProperty;

public class PagamentoConfirmado {

    @JsonProperty("pagamentoId")
    public Long pagamentoId;

    @JsonProperty("pedidoId")
    public Long pedidoId;

    public PagamentoConfirmado() {
    }

    public PagamentoConfirmado(Long pagamentoId, Long pedidoId) {
        this.pagamentoId = pagamentoId;
        this.pedidoId = pedidoId;
    }

    @Override
    public String toString() {
        return "PagamentoConfirmado{" +
                "pagamentoId=" + pagamentoId +
                ", pedidoId=" + pedidoId +
                '}';
    }
}

