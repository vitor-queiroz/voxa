package com.voxa.backend.dto;

import com.voxa.backend.model.FormaPagamento;

import java.math.BigDecimal;

public record FormaPagamentoDto(String id, String descricao, BigDecimal valorMinimo, Integer maxParcelas, Boolean permiteTroco) {

    public static FormaPagamentoDto de(FormaPagamento forma) {
        return new FormaPagamentoDto(
                forma.getId(),
                forma.getDescricao(),
                forma.getValorMinimo(),
                forma.getMaxParcelas(),
                forma.getPermiteTroco());
    }
}
