package com.voxa.backend.dto;

import java.math.BigDecimal;

/*Linha do painel de vendedores: totais de um prontuário no período (GET /comissoes)*/
public record ResumoComissao(
        FuncionarioResumo vendedor,
        long quantidadeVendas,
        long pecas,
        BigDecimal totalVendido,
        BigDecimal valorComissao) {
}
