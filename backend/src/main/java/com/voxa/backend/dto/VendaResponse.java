package com.voxa.backend.dto;

import com.voxa.backend.model.ItemVenda;
import com.voxa.backend.model.PagamentoVenda;
import com.voxa.backend.model.StatusVenda;
import com.voxa.backend.model.Venda;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/*
 * Venda como o frontend espera (mesmos nomes de campos do vendas.model.ts).
 * A comissão NÃO vai na resposta: todos os funcionários usam o sistema.
 * Ela continua gravada na tabela venda (percentual_comissao / valor_comissao).
 */
public record VendaResponse(
        Long numero,
        LocalDateTime data,
        FuncionarioResumo vendedor,
        ClienteDto cliente,
        List<ItemDto> itens,
        BigDecimal subtotal,
        DescontoDto desconto,
        BigDecimal valorDesconto,
        BigDecimal cashback,
        BigDecimal total,
        List<PagamentoDto> pagamentos,
        BigDecimal troco,
        StatusVenda status) {

    public record ItemDto(ProdutoVariacaoDto variacao, Integer quantidade, BigDecimal precoOriginal, BigDecimal precoUnitario) {

        static ItemDto de(ItemVenda item) {
            return new ItemDto(
                    ProdutoVariacaoDto.de(item.getVariacao()),
                    item.getQuantidade(),
                    item.getPrecoOriginal(),
                    item.getPrecoUnitario());
        }
    }

    public record PagamentoDto(FormaPagamentoDto forma, BigDecimal valor, Integer parcelas) {

        static PagamentoDto de(PagamentoVenda pagamento) {
            return new PagamentoDto(FormaPagamentoDto.de(pagamento.getForma()), pagamento.getValor(), pagamento.getParcelas());
        }
    }

    public static VendaResponse de(Venda venda) {
        DescontoDto desconto = venda.getDescontoTipo() == null
                ? null
                : new DescontoDto(venda.getDescontoTipo(), venda.getDescontoValor());
        return new VendaResponse(
                venda.getNumero(),
                venda.getData(),
                FuncionarioResumo.de(venda.getVendedor()),
                venda.getCliente() == null ? null : ClienteDto.de(venda.getCliente()),
                venda.getItens().stream().map(ItemDto::de).toList(),
                venda.getSubtotal(),
                desconto,
                venda.getValorDesconto(),
                venda.getCashback(),
                venda.getTotal(),
                venda.getPagamentos().stream().map(PagamentoDto::de).toList(),
                venda.getTroco(),
                venda.getStatus());
    }
}
