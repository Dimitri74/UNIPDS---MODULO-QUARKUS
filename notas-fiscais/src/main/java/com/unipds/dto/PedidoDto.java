package com.unipds.dto;


import java.time.LocalDateTime;

public class PedidoDto {

    public Long id;

    public LocalDateTime dataHora;

    public String status;

    public ClienteDto cliente;

}