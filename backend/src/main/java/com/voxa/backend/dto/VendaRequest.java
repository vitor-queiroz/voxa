package com.voxa.backend.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.math.BigDecimal;
import java.util.List;

/*
 * Corpo do POST /vendas. O frontend manda a venda inteira, mas o backend só lê os ids,
 * as quantidades e os valores digitados: subtotal, desconto, total, troco e comissão
 * são recalculados no VendaService (não confiamos nos valores do navegador).
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record VendaRequest(
        VendedorRef vendedor,
        ClienteRef cliente,
        List<ItemRequest> itens,
        DescontoDto desconto,
        BigDecimal cashback,
        List<PagamentoRequest> pagamentos) {

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record VendedorRef(String prontuario) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ClienteRef(Long id) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record VariacaoRef(Long id) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ItemRequest(VariacaoRef variacao, Integer quantidade, BigDecimal precoUnitario) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record FormaRef(String id) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record PagamentoRequest(FormaRef forma, BigDecimal valor, Integer parcelas) {
    }
}
