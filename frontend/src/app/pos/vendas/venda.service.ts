import { Injectable, computed, signal } from '@angular/core';
import {
  Cliente,
  DescontoGeral,
  FormaPagamento,
  ProdutoVariacao,
  RascunhoVenda,
  Venda,
  Vendedor,
} from './vendas.model';

/*
 * Estado da venda em andamento (rascunho) e regras de cálculo.
 * Não fala com o backend: buscas e gravação ficam no VendasApiService.
 */
@Injectable({
  providedIn: 'root',
})
export class VendaService {
  private readonly _rascunho = signal<RascunhoVenda>(novoRascunho());
  readonly rascunho = this._rascunho.asReadonly();

  readonly quantidadeItens = computed(() =>
    this._rascunho().itens.reduce((soma, item) => soma + item.quantidade, 0),
  );

  /*Soma dos itens pelo preço praticado (já considera valores alterados no PDV)*/
  readonly subtotal = computed(() =>
    arredondar(
      this._rascunho().itens.reduce((soma, item) => soma + item.quantidade * item.precoUnitario, 0),
    ),
  );

  /*Desconto geral convertido em R$, limitado ao subtotal*/
  readonly valorDesconto = computed(() => {
    const desconto = this._rascunho().desconto;
    if (!desconto) {
      return 0;
    }
    const valor =
      desconto.tipo === 'PERCENTUAL' ? (this.subtotal() * desconto.valor) / 100 : desconto.valor;
    return arredondar(Math.min(valor, this.subtotal()));
  });

  /*Cashback resgatado, limitado ao que sobra depois do desconto*/
  readonly cashback = computed(() =>
    arredondar(Math.min(this._rascunho().cashback, this.subtotal() - this.valorDesconto())),
  );

  readonly total = computed(() =>
    arredondar(this.subtotal() - this.valorDesconto() - this.cashback()),
  );

  readonly totalPago = computed(() =>
    arredondar(this._rascunho().pagamentos.reduce((soma, p) => soma + p.valor, 0)),
  );

  readonly restante = computed(() => Math.max(0, arredondar(this.total() - this.totalPago())));

  readonly troco = computed(() => Math.max(0, arredondar(this.totalPago() - this.total())));

  definirVendedor(vendedor: Vendedor | null) {
    this._rascunho.update((r) => ({ ...r, vendedor }));
  }

  /*Trocar de cliente zera o cashback resgatado do cliente anterior*/
  definirCliente(cliente: Cliente | null) {
    this._rascunho.update((r) => ({ ...r, cliente, cashback: 0 }));
  }

  /*Cada leitura de produto gera uma linha nova, como no PDV*/
  incluirItem(variacao: ProdutoVariacao) {
    this._rascunho.update((r) => ({
      ...r,
      itens: [
        ...r.itens,
        { variacao, quantidade: 1, precoOriginal: variacao.preco, precoUnitario: variacao.preco },
      ],
    }));
  }

  removerItem(indice: number) {
    this._rascunho.update((r) => ({ ...r, itens: r.itens.filter((_, i) => i !== indice) }));
  }

  alterarQuantidade(indice: number, quantidade: number): string | null {
    if (!Number.isInteger(quantidade) || quantidade <= 0) {
      return 'Quantidade inválida.';
    }
    this.atualizarItem(indice, { quantidade });
    return null;
  }

  /*Altera o preço unitário de um item (símbolo de moeda na linha do item)*/
  alterarPrecoItem(indice: number, preco: number): string | null {
    preco = arredondar(Number(preco));
    if (!(preco > 0)) {
      return 'Informe um valor maior que zero.';
    }
    this.atualizarItem(indice, { precoUnitario: preco });
    return null;
  }

  limparItens() {
    this._rascunho.update((r) => ({ ...r, itens: [], desconto: null, cashback: 0, pagamentos: [] }));
  }

  /*Desconto geral da venda (símbolo de moeda abaixo dos itens). null remove o desconto*/
  definirDesconto(desconto: DescontoGeral | null): string | null {
    if (desconto) {
      const valor = Number(desconto.valor);
      if (!(valor > 0)) {
        desconto = null;
      } else if (desconto.tipo === 'PERCENTUAL' && valor > 100) {
        return 'O percentual deve ser de até 100%.';
      } else if (desconto.tipo === 'VALOR' && valor > this.subtotal()) {
        return 'O desconto não pode ser maior que o subtotal.';
      } else {
        desconto = { tipo: desconto.tipo, valor: arredondar(valor) };
      }
    }
    this._rascunho.update((r) => ({ ...r, desconto }));
    return null;
  }

  definirCashback(valor: number) {
    this._rascunho.update((r) => ({ ...r, cashback: Math.max(0, arredondar(Number(valor) || 0)) }));
  }

  adicionarPagamento(forma: FormaPagamento, valor: number, parcelas = 1): string | null {
    valor = arredondar(Number(valor) || 0);
    if (this.restante() <= 0) {
      return 'A venda já está totalmente paga.';
    }
    if (valor <= 0) {
      return 'Informe um valor maior que zero.';
    }
    if (valor < forma.valorMinimo) {
      return `Valor mínimo para ${forma.descricao}: R$ ${forma.valorMinimo.toFixed(2)}.`;
    }
    if (!forma.permiteTroco && valor > this.restante()) {
      return `${forma.descricao} não permite valor acima do restante.`;
    }
    if (!Number.isInteger(parcelas) || parcelas < 1 || parcelas > forma.maxParcelas) {
      return `${forma.descricao} permite de 1 a ${forma.maxParcelas} parcela(s).`;
    }

    this._rascunho.update((r) => ({
      ...r,
      pagamentos: [...r.pagamentos, { forma, valor, parcelas }],
    }));
    return null;
  }

  removerPagamento(indice: number) {
    this._rascunho.update((r) => ({
      ...r,
      pagamentos: r.pagamentos.filter((_, i) => i !== indice),
    }));
  }

  /*Valida o rascunho e monta a venda que será enviada no POST /vendas (ou a mensagem de erro)*/
  montarVenda(): Venda | string {
    const r = this._rascunho();
    if (r.itens.length === 0) {
      return 'Inclua ao menos um item.';
    }
    if (!r.vendedor) {
      return 'Informe o vendedor.';
    }
    if (this.restante() > 0) {
      return 'Ainda há valor restante a pagar.';
    }
    return {
      numero: null,
      data: null,
      vendedor: r.vendedor,
      cliente: r.cliente,
      itens: r.itens,
      subtotal: this.subtotal(),
      desconto: r.desconto,
      valorDesconto: this.valorDesconto(),
      cashback: this.cashback(),
      total: this.total(),
      pagamentos: r.pagamentos,
      troco: this.troco(),
      status: 'FINALIZADA',
    };
  }

  /*Começa uma venda nova, mantendo o vendedor*/
  novaVenda() {
    this._rascunho.set(novoRascunho(this._rascunho().vendedor));
  }

  private atualizarItem(indice: number, alteracao: Partial<RascunhoVenda['itens'][number]>) {
    this._rascunho.update((r) => ({
      ...r,
      itens: r.itens.map((item, i) => (i === indice ? { ...item, ...alteracao } : item)),
    }));
  }
}

function novoRascunho(vendedor: Vendedor | null = null): RascunhoVenda {
  return { vendedor, cliente: null, itens: [], desconto: null, cashback: 0, pagamentos: [] };
}

function arredondar(valor: number): number {
  return Math.round(valor * 100) / 100;
}
