package com.voxa.backend.dto;

import com.voxa.backend.model.Produto;
import com.voxa.backend.model.ProdutoCor;
import com.voxa.backend.model.ProdutoVariacao;

import java.math.BigDecimal;

public record ProdutoVariacaoDto(
        Long id,
        ProdutoDto produto,
        String codigoBarras,
        String tamanho,
        String cor,
        BigDecimal preco,
        String imagemUrl,
        Integer quantidade
) {

    public record ProdutoDto(
            Long id,
            String referencia,
            String nome,
            String marca
    ) {
        public static ProdutoDto de(Produto produto, String referencia) {
            return new ProdutoDto(
                    produto.getId(),
                    referencia,
                    produto.getNome(),
                    produto.getMarca()
            );
        }
    }

    public static ProdutoVariacaoDto de(
            ProdutoVariacao variacao,
            Integer quantidade
    ) {
        ProdutoCor produtoCor = variacao.getProdutoCor();

        Produto produto = produtoCor != null
                ? produtoCor.getProduto()
                : variacao.getProduto();

        String referencia = produtoCor != null
                ? produtoCor.getReferencia()
                : produto.getReferencia();

        String cor = produtoCor != null
                ? produtoCor.getCor()
                : variacao.getCor();

        String imagemUrl = produtoCor != null
                ? produtoCor.getImagemUrl()
                : variacao.getImagemUrl();

        return new ProdutoVariacaoDto(
                variacao.getId(),
                ProdutoDto.de(produto, referencia),
                variacao.getCodigoBarras(),
                variacao.getTamanho(),
                cor,
                variacao.getPreco(),
                imagemUrl,
                quantidade
        );
    }

    public static ProdutoVariacaoDto de(ProdutoVariacao variacao) {
        return de(variacao, null);
    }
}
