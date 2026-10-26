package com.voxa.backend.dto;

import java.math.BigDecimal;

/*Linha do painel de vendas: totais de um vendedor no período (sem comissão)*/
public record ResumoVendedor(
        FuncionarioResumo vendedor,
        long quantidadeVendas,
        long pecas,
        BigDecimal totalVendido) {
}
