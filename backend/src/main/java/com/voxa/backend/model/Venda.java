package com.voxa.backend.model;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "venda", indexes = @Index(name = "idx_venda_vendedor_data", columnList = "prontuario_vendedor, data"))
public class Venda {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long numero;

    @Column(nullable = false)
    private LocalDateTime data;

    @ManyToOne(optional = false)
    @JoinColumn(name = "prontuario_vendedor", nullable = false)
    private Funcionario vendedor; //a comissão vai para este prontuário

    @ManyToOne
    @JoinColumn(name = "cliente_id")
    private Cliente cliente; //null = consumidor final

    @OneToMany(mappedBy = "venda", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ItemVenda> itens = new ArrayList<>();

    @OneToMany(mappedBy = "venda", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PagamentoVenda> pagamentos = new ArrayList<>();

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal subtotal;

    @Enumerated(EnumType.STRING)
    @Column(name = "desconto_tipo", length = 10)
    private TipoDesconto descontoTipo;

    @Column(name = "desconto_valor", precision = 10, scale = 2)
    private BigDecimal descontoValor;

    @Column(name = "valor_desconto", nullable = false, precision = 10, scale = 2)
    private BigDecimal valorDesconto;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal cashback;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal total;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal troco;

    @Column(name = "percentual_comissao", nullable = false, precision = 5, scale = 2)
    private BigDecimal percentualComissao; //fica gravado: mudar a regra depois não altera vendas antigas

    @Column(name = "valor_comissao", nullable = false, precision = 10, scale = 2)
    private BigDecimal valorComissao;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 12)
    private StatusVenda status;

    public void adicionarItem(ItemVenda item) {
        item.setVenda(this);
        itens.add(item);
    }

    public void adicionarPagamento(PagamentoVenda pagamento) {
        pagamento.setVenda(this);
        pagamentos.add(pagamento);
    }

    public Long getNumero() {
        return numero;
    }

    public void setNumero(Long numero) {
        this.numero = numero;
    }

    public LocalDateTime getData() {
        return data;
    }

    public void setData(LocalDateTime data) {
        this.data = data;
    }

    public Funcionario getVendedor() {
        return vendedor;
    }

    public void setVendedor(Funcionario vendedor) {
        this.vendedor = vendedor;
    }

    public Cliente getCliente() {
        return cliente;
    }

    public void setCliente(Cliente cliente) {
        this.cliente = cliente;
    }

    public List<ItemVenda> getItens() {
        return itens;
    }

    public List<PagamentoVenda> getPagamentos() {
        return pagamentos;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public TipoDesconto getDescontoTipo() {
        return descontoTipo;
    }

    public void setDescontoTipo(TipoDesconto descontoTipo) {
        this.descontoTipo = descontoTipo;
    }

    public BigDecimal getDescontoValor() {
        return descontoValor;
    }

    public void setDescontoValor(BigDecimal descontoValor) {
        this.descontoValor = descontoValor;
    }

    public BigDecimal getValorDesconto() {
        return valorDesconto;
    }

    public void setValorDesconto(BigDecimal valorDesconto) {
        this.valorDesconto = valorDesconto;
    }

    public BigDecimal getCashback() {
        return cashback;
    }

    public void setCashback(BigDecimal cashback) {
        this.cashback = cashback;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }

    public BigDecimal getTroco() {
        return troco;
    }

    public void setTroco(BigDecimal troco) {
        this.troco = troco;
    }

    public BigDecimal getPercentualComissao() {
        return percentualComissao;
    }

    public void setPercentualComissao(BigDecimal percentualComissao) {
        this.percentualComissao = percentualComissao;
    }

    public BigDecimal getValorComissao() {
        return valorComissao;
    }

    public void setValorComissao(BigDecimal valorComissao) {
        this.valorComissao = valorComissao;
    }

    public StatusVenda getStatus() {
        return status;
    }

    public void setStatus(StatusVenda status) {
        this.status = status;
    }
}
