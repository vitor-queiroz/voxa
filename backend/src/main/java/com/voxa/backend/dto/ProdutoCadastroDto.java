package com.voxa.backend.dto;

import java.util.List;

public record ProdutoCadastroDto(
        String nome,
        String marca,
        List<ProdutoCorCadastroDto> cores
) {
}