package com.voxa.backend.dto;

import com.voxa.backend.model.TipoDesconto;

import java.math.BigDecimal;

/*Desconto total da venda: { "tipo": "PERCENTUAL", "valor": 10 } ou { "tipo": "VALOR", "valor": 49.90 }*/
public record DescontoDto(TipoDesconto tipo, BigDecimal valor) {
}
