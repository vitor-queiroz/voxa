package com.voxa.backend.dto;

import java.util.List;

public record ProdutoCorCadastroDto(
        String referencia,
        String cor,
        List<ProdutoVariacaoCadastroDto> variacoes
) {
}
