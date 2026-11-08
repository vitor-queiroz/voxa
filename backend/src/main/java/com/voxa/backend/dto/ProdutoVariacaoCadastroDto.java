package com.voxa.backend.dto;

import java.math.BigDecimal;

public record ProdutoVariacaoCadastroDto(
        String tamanho,
        String codigoBarras,
        BigDecimal preco,
        Integer quantidade
) {
}