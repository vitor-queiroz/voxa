package com.voxa.backend.dto;

import com.voxa.backend.model.Produto;
import com.voxa.backend.model.ProdutoVariacao;

import java.math.BigDecimal;

public record ProdutoVariacaoDto(
        Long id,
        ProdutoDto produto,
        String codigoBarras,
        String tamanho,
        String cor,
        BigDecimal preco,
        String imagemUrl) {

    public record ProdutoDto(Long id, String referencia, String nome, String marca) {

        public static ProdutoDto de(Produto produto) {
            return new ProdutoDto(produto.getId(), produto.getReferencia(), produto.getNome(), produto.getMarca());
        }
    }

    public static ProdutoVariacaoDto de(ProdutoVariacao variacao) {
        return new ProdutoVariacaoDto(
                variacao.getId(),
                ProdutoDto.de(variacao.getProduto()),
                variacao.getCodigoBarras(),
                variacao.getTamanho(),
                variacao.getCor(),
                variacao.getPreco(),
                variacao.getImagemUrl());
    }
}
