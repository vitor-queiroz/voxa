package com.voxa.backend.service;

import com.voxa.backend.dto.DescontoDto;
import com.voxa.backend.dto.VendaRequest;
import com.voxa.backend.dto.VendaResponse;
import com.voxa.backend.exception.NaoEncontradoException;
import com.voxa.backend.exception.RegraNegocioException;
import com.voxa.backend.model.Cliente;
import com.voxa.backend.model.FormaPagamento;
import com.voxa.backend.model.Funcionario;
import com.voxa.backend.model.ItemVenda;
import com.voxa.backend.model.PagamentoVenda;
import com.voxa.backend.model.ProdutoVariacao;
import com.voxa.backend.model.StatusVenda;
import com.voxa.backend.model.TipoDesconto;
import com.voxa.backend.model.Venda;
import com.voxa.backend.repository.ClienteRepository;
import com.voxa.backend.repository.FormaPagamentoRepository;
import com.voxa.backend.repository.ProdutoVariacaoRepository;
import com.voxa.backend.repository.VendaRepository;
import com.voxa.backend.util.Dinheiro;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/*
 * Registra, lista e cancela vendas.
 * Todos os valores são recalculados aqui — o backend não confia nos totais enviados pelo navegador.
 * As regras são as mesmas do frontend (venda.service.ts).
 */
@Service
public class VendaService {

    private final VendaRepository vendaRepository;
    private final ProdutoVariacaoRepository variacaoRepository;
    private final ClienteRepository clienteRepository;
    private final FormaPagamentoRepository formaPagamentoRepository;
    private final FuncionarioService funcionarioService;

    public VendaService(VendaRepository vendaRepository,
                        ProdutoVariacaoRepository variacaoRepository,
                        ClienteRepository clienteRepository,
                        FormaPagamentoRepository formaPagamentoRepository,
                        FuncionarioService funcionarioService) {
        this.vendaRepository = vendaRepository;
        this.variacaoRepository = variacaoRepository;
        this.clienteRepository = clienteRepository;
        this.formaPagamentoRepository = formaPagamentoRepository;
        this.funcionarioService = funcionarioService;
    }

    @Transactional
    public VendaResponse registrar(VendaRequest pedido) {
        Venda venda = new Venda();
        venda.setVendedor(vendedor(pedido.vendedor()));
        venda.setCliente(cliente(pedido.cliente()));

        incluirItens(venda, pedido.itens());
        BigDecimal subtotal = Dinheiro.arredondar(venda.getItens().stream()
                .map(item -> item.getPrecoUnitario().multiply(BigDecimal.valueOf(item.getQuantidade())))
                .reduce(BigDecimal.ZERO, BigDecimal::add));
        venda.setSubtotal(subtotal);

        BigDecimal valorDesconto = aplicarDesconto(venda, pedido.desconto(), subtotal);
        BigDecimal cashback = resgatarCashback(venda.getCliente(), pedido.cashback(), subtotal.subtract(valorDesconto));
        BigDecimal total = subtotal.subtract(valorDesconto).subtract(cashback);
        venda.setValorDesconto(valorDesconto);
        venda.setCashback(cashback);
        venda.setTotal(total);

        BigDecimal totalPago = incluirPagamentos(venda, pedido.pagamentos(), total);
        venda.setTroco(totalPago.subtract(total));

        BigDecimal percentual = funcionarioService.percentualComissao(venda.getVendedor());
        venda.setPercentualComissao(percentual);
        venda.setValorComissao(Dinheiro.percentualDe(total, percentual));

        venda.setData(LocalDateTime.now());
        venda.setStatus(StatusVenda.FINALIZADA);
        return VendaResponse.de(vendaRepository.save(venda));
    }

    /*Filtros opcionais: período (datas inclusivas) e prontuário do vendedor. Mais recentes primeiro*/
    @Transactional(readOnly = true)
    public List<VendaResponse> listar(LocalDate de, LocalDate ate, String prontuario) {
        Specification<Venda> filtro = (venda, consulta, cb) -> cb.conjunction();
        if (de != null) {
            filtro = filtro.and((venda, consulta, cb) -> cb.greaterThanOrEqualTo(venda.get("data"), de.atStartOfDay()));
        }
        if (ate != null) {
            filtro = filtro.and((venda, consulta, cb) -> cb.lessThan(venda.get("data"), ate.plusDays(1).atStartOfDay()));
        }
        if (prontuario != null && !prontuario.isBlank()) {
            filtro = filtro.and((venda, consulta, cb) -> cb.equal(venda.get("vendedor").get("prontuario"), prontuario));
        }
        return vendaRepository.findAll(filtro, Sort.by(Sort.Direction.DESC, "numero"))
                .stream().map(VendaResponse::de).toList();
    }

    /*Cancela a venda e devolve o cashback resgatado. Venda cancelada sai da comissão*/
    @Transactional
    public VendaResponse cancelar(Long numero) {
        Venda venda = vendaRepository.findById(numero)
                .orElseThrow(() -> new NaoEncontradoException("Venda nº " + numero + " não encontrada."));
        if (venda.getStatus() == StatusVenda.CANCELADA) {
            throw new RegraNegocioException("Venda nº " + numero + " já está cancelada.");
        }
        venda.setStatus(StatusVenda.CANCELADA);
        if (venda.getCliente() != null && Dinheiro.positivo(venda.getCashback())) {
            Cliente cliente = venda.getCliente();
            cliente.setSaldoCashback(cliente.getSaldoCashback().add(venda.getCashback()));
        }
        return VendaResponse.de(venda);
    }

    private Funcionario vendedor(VendaRequest.VendedorRef referencia) {
        if (referencia == null || referencia.prontuario() == null || referencia.prontuario().isBlank()) {
            throw new RegraNegocioException("Informe o prontuário do vendedor.");
        }
        Funcionario vendedor = funcionarioService.buscarEntidade(referencia.prontuario().trim());
        if (!vendedor.podeVender()) {
            throw new RegraNegocioException(vendedor.getNome() + " está \"" + vendedor.getSituacao()
                    + "\" e não pode ser vinculado à venda.");
        }
        return vendedor;
    }

    private Cliente cliente(VendaRequest.ClienteRef referencia) {
        if (referencia == null || referencia.id() == null) {
            return null; //consumidor final
        }
        return clienteRepository.findById(referencia.id())
                .orElseThrow(() -> new NaoEncontradoException("Cliente não encontrado."));
    }

    private void incluirItens(Venda venda, List<VendaRequest.ItemRequest> itens) {
        if (itens == null || itens.isEmpty()) {
            throw new RegraNegocioException("Inclua ao menos um item.");
        }
        for (VendaRequest.ItemRequest pedido : itens) {
            if (pedido.variacao() == null || pedido.variacao().id() == null) {
                throw new RegraNegocioException("Item sem produto.");
            }
            ProdutoVariacao variacao = variacaoRepository.findById(pedido.variacao().id())
                    .orElseThrow(() -> new NaoEncontradoException("Produto " + pedido.variacao().id() + " não encontrado."));
            if (variacao.getPreco() == null) {
                throw new RegraNegocioException("O produto " + variacao.getCodigoBarras() + " está sem preço cadastrado.");
            }
            if (pedido.quantidade() == null || pedido.quantidade() <= 0) {
                throw new RegraNegocioException("Quantidade inválida.");
            }
            BigDecimal preco = pedido.precoUnitario() != null ? pedido.precoUnitario() : variacao.getPreco();
            if (!Dinheiro.positivo(preco)) {
                throw new RegraNegocioException("O valor do item deve ser maior que zero.");
            }

            ItemVenda item = new ItemVenda();
            item.setVariacao(variacao);
            item.setQuantidade(pedido.quantidade());
            item.setPrecoOriginal(variacao.getPreco());
            item.setPrecoUnitario(Dinheiro.arredondar(preco));
            venda.adicionarItem(item);
        }
    }

    /*Grava o desconto informado e devolve o valor dele em R$*/
    private BigDecimal aplicarDesconto(Venda venda, DescontoDto desconto, BigDecimal subtotal) {
        if (desconto == null || desconto.tipo() == null || !Dinheiro.positivo(desconto.valor())) {
            return Dinheiro.ZERO;
        }
        BigDecimal valor = desconto.valor();
        BigDecimal emReais;
        if (desconto.tipo() == TipoDesconto.PERCENTUAL) {
            if (valor.compareTo(new BigDecimal("100")) > 0) {
                throw new RegraNegocioException("O percentual de desconto deve ser de até 100%.");
            }
            emReais = Dinheiro.percentualDe(subtotal, valor);
        } else {
            emReais = Dinheiro.arredondar(valor);
            if (emReais.compareTo(subtotal) > 0) {
                throw new RegraNegocioException("O desconto não pode ser maior que o subtotal.");
            }
        }
        venda.setDescontoTipo(desconto.tipo());
        venda.setDescontoValor(valor);
        return emReais;
    }

    /*Debita o cashback do saldo do cliente e devolve o valor resgatado*/
    private BigDecimal resgatarCashback(Cliente cliente, BigDecimal valor, BigDecimal limite) {
        if (valor == null || valor.signum() == 0) {
            return Dinheiro.ZERO;
        }
        BigDecimal cashback = Dinheiro.arredondar(valor);
        if (cashback.signum() < 0) {
            throw new RegraNegocioException("Valor de cashback inválido.");
        }
        if (cliente == null) {
            throw new RegraNegocioException("Cashback exige cliente identificado.");
        }
        if (cashback.compareTo(cliente.getSaldoCashback()) > 0) {
            throw new RegraNegocioException("Cashback acima do saldo do cliente.");
        }
        if (cashback.compareTo(limite) > 0) {
            throw new RegraNegocioException("Cashback acima do valor da venda.");
        }
        cliente.setSaldoCashback(cliente.getSaldoCashback().subtract(cashback));
        return cashback;
    }

    /*Valida e grava os pagamentos; devolve o total pago*/
    private BigDecimal incluirPagamentos(Venda venda, List<VendaRequest.PagamentoRequest> pagamentos, BigDecimal total) {
        if (pagamentos == null || pagamentos.isEmpty()) {
            if (total.signum() == 0) {
                return Dinheiro.ZERO; //venda zerada por desconto/cashback
            }
            throw new RegraNegocioException("Informe o pagamento.");
        }
        BigDecimal totalPago = BigDecimal.ZERO;
        BigDecimal pagoSemTroco = BigDecimal.ZERO;
        for (VendaRequest.PagamentoRequest pedido : pagamentos) {
            if (pedido.forma() == null || pedido.forma().id() == null) {
                throw new RegraNegocioException("Informe a forma de pagamento.");
            }
            FormaPagamento forma = formaPagamentoRepository.findById(pedido.forma().id())
                    .orElseThrow(() -> new NaoEncontradoException("Forma de pagamento " + pedido.forma().id() + " não encontrada."));
            if (!Dinheiro.positivo(pedido.valor())) {
                throw new RegraNegocioException("Informe um valor de pagamento maior que zero.");
            }
            BigDecimal valor = Dinheiro.arredondar(pedido.valor());
            if (valor.compareTo(forma.getValorMinimo()) < 0) {
                throw new RegraNegocioException("Valor mínimo para " + forma.getDescricao() + ": R$ " + forma.getValorMinimo() + ".");
            }
            int parcelas = pedido.parcelas() == null ? 1 : pedido.parcelas();
            if (parcelas < 1 || parcelas > forma.getMaxParcelas()) {
                throw new RegraNegocioException(forma.getDescricao() + " permite de 1 a " + forma.getMaxParcelas() + " parcela(s).");
            }

            PagamentoVenda pagamento = new PagamentoVenda();
            pagamento.setForma(forma);
            pagamento.setValor(valor);
            pagamento.setParcelas(parcelas);
            venda.adicionarPagamento(pagamento);

            totalPago = totalPago.add(valor);
            if (!Boolean.TRUE.equals(forma.getPermiteTroco())) {
                pagoSemTroco = pagoSemTroco.add(valor);
            }
        }
        if (totalPago.compareTo(total) < 0) {
            throw new RegraNegocioException("Ainda há valor restante a pagar.");
        }
        if (pagoSemTroco.compareTo(total) > 0) {
            throw new RegraNegocioException("Só pagamento em dinheiro pode passar do total (troco).");
        }
        return totalPago;
    }
}
