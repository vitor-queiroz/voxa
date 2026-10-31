package com.voxa.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.Table;

/*
 * Foto de produto mostrada no PDV. Fica no banco para todos os computadores verem a mesma foto.
 * As variações apontam para ela pelo campo imagemUrl ("/produtos/imagens/{id}").
 */
@Entity
@Table(name = "produto_imagem")
public class ProdutoImagem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(length = 20, nullable = false)
    private String tipo; //image/jpeg, image/png ou image/webp

    @Lob
    @Column(nullable = false, length = 5 * 1024 * 1024) //MEDIUMBLOB no MySQL
    private byte[] dados;

    public ProdutoImagem() {
    }

    public ProdutoImagem(String tipo, byte[] dados) {
        this.tipo = tipo;
        this.dados = dados;
    }

    public Long getId() {
        return id;
    }

    public String getTipo() {
        return tipo;
    }

    public byte[] getDados() {
        return dados;
    }
}
