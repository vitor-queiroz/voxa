package com.voxa.backend.dto;

import java.math.BigDecimal;

/*Resposta do GET /funcionarios/{prontuario}/comissao*/
public record PercentualComissao(BigDecimal percentual) {
}
