package com.voxa.backend.dto;

import java.util.List;

public record ProdutoCadastroDto(
        String referencia,
        String nome,
        String marca,
        List<ProdutoVariacaoCadastroDto> variacoes
) {
}