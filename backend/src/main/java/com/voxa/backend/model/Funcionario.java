package com.voxa.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;

/*
 * Mapeia a tabela "funcionario" que já existe no banco.
 * Quem vende é identificado pelo prontuário. CPF, RG e datas ficam só no backend (LGPD):
 * para o frontend vai o FuncionarioResumo.
 *
 * IMPORTANTE: tamanhos e tipos iguais ao CREATE TABLE do banco. Se forem diferentes,
 * o ddl-auto=update do Hibernate faz "modify column" e altera a tabela.
 */
@Entity
@Table(name = "funcionario")
public class Funcionario {

    @Id
    @Column(length = 10)
    private String prontuario;

    @Column(length = 100, nullable = false)
    private String nome;

    @Column(length = 11, nullable = false)
    private String cpf; //UNIQUE já existe no banco

    @Column(length = 12, nullable = false)
    private String rg;

    @Column(name = "data_nascimento", nullable = false)
    private LocalDate dataNascimento;

    @Column(length = 50, nullable = false)
    private String funcao;

    @Column(name = "data_admissao", nullable = false)
    private LocalDate dataAdmissao;

    //ENUM do banco. length = 11 (tamanho de "Trabalhando") para o Hibernate reconhecer a coluna como igual
    @Column(length = 11, columnDefinition = "enum('Trabalhando','Afastado','Demitido') default 'Trabalhando'")
    private String situacao; //só quem está "Trabalhando" pode vender

    @Column(name = "percentual_comissao", precision = 5, scale = 2)
    private BigDecimal percentualComissao; //opcional: null = usa o percentual padrão

    /*Só funcionário com situação "Trabalhando" pode ser vinculado a uma venda*/
    public boolean podeVender() {
        return situacao != null && situacao.trim().equalsIgnoreCase("Trabalhando");
    }

    public String getProntuario() {
        return prontuario;
    }

    public void setProntuario(String prontuario) {
        this.prontuario = prontuario;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getRg() {
        return rg;
    }

    public void setRg(String rg) {
        this.rg = rg;
    }

    public LocalDate getDataNascimento() {
        return dataNascimento;
    }

    public void setDataNascimento(LocalDate dataNascimento) {
        this.dataNascimento = dataNascimento;
    }

    public String getFuncao() {
        return funcao;
    }

    public void setFuncao(String funcao) {
        this.funcao = funcao;
    }

    public LocalDate getDataAdmissao() {
        return dataAdmissao;
    }

    public void setDataAdmissao(LocalDate dataAdmissao) {
        this.dataAdmissao = dataAdmissao;
    }

    public String getSituacao() {
        return situacao;
    }

    public void setSituacao(String situacao) {
        this.situacao = situacao;
    }

    public BigDecimal getPercentualComissao() {
        return percentualComissao;
    }

    public void setPercentualComissao(BigDecimal percentualComissao) {
        this.percentualComissao = percentualComissao;
    }
}
