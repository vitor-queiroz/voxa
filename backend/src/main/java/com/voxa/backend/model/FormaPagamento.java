package com.voxa.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;

@Entity
@Table(name = "forma_pagamento")
public class FormaPagamento {

    @Id
    @Column(length = 20)
    private String id; //DINHEIRO, PIX, DEBITO, CREDITO

    @Column(nullable = false)
    private String descricao;

    @Column(name = "valor_minimo", nullable = false, precision = 10, scale = 2)
    private BigDecimal valorMinimo = BigDecimal.ZERO;

    @Column(name = "max_parcelas", nullable = false)
    private Integer maxParcelas = 1;

    @Column(name = "permite_troco", nullable = false)
    private Boolean permiteTroco = false; //só dinheiro aceita valor acima do total

    public FormaPagamento() {
    }

    public FormaPagamento(String id, String descricao, BigDecimal valorMinimo, Integer maxParcelas, Boolean permiteTroco) {
        this.id = id;
        this.descricao = descricao;
        this.valorMinimo = valorMinimo;
        this.maxParcelas = maxParcelas;
        this.permiteTroco = permiteTroco;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public BigDecimal getValorMinimo() {
        return valorMinimo;
    }

    public void setValorMinimo(BigDecimal valorMinimo) {
        this.valorMinimo = valorMinimo;
    }

    public Integer getMaxParcelas() {
        return maxParcelas;
    }

    public void setMaxParcelas(Integer maxParcelas) {
        this.maxParcelas = maxParcelas;
    }

    public Boolean getPermiteTroco() {
        return permiteTroco;
    }

    public void setPermiteTroco(Boolean permiteTroco) {
        this.permiteTroco = permiteTroco;
    }
}
