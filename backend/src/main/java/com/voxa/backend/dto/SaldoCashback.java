package com.voxa.backend.dto;

import java.math.BigDecimal;

/*Resposta do GET /clientes/{cpf}/cashback*/
public record SaldoCashback(BigDecimal saldo) {
}
