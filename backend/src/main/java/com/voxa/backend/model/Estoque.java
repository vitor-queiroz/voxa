package com.voxa.backend.model;

import jakarta.persistence.*;

@Entity
public class Estoque {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "produto_variacao_id", unique = true, nullable = false)
    private ProdutoVariacao produtoVariacao;

    @Column(nullable = false)
    private Integer quantidade;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public ProdutoVariacao getProdutoVariacao() {
        return produtoVariacao;
    }

    public void setProdutoVariacao(ProdutoVariacao produtoVariacao) {
        this.produtoVariacao = produtoVariacao;
    }

    public Integer getQuantidade() {
        return quantidade;
    }

    public void setQuantidade(Integer quantidade) {
        this.quantidade = quantidade;
    }
}