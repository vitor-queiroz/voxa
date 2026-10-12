import { Component, computed, signal } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { VendaService } from '../venda.service';
import { VendasApiService } from '../vendas-api.service';
import { FormaPagamento, Venda } from '../vendas.model';
import { Acao, BarraAcoes } from '../compartilhado/barra-acoes/barra-acoes';
import { Etapas } from '../compartilhado/etapas/etapas';
import { Icone } from '../compartilhado/icone/icone';
import { ResumoVenda } from '../compartilhado/resumo-venda/resumo-venda';
import { VendedorProntuario } from '../compartilhado/vendedor-prontuario/vendedor-prontuario';

/*Etapa 2 da venda: confirma o vendedor pelo prontuário, lança os pagamentos e finaliza*/
@Component({
  selector: 'app-pagamento',
  imports: [CurrencyPipe, FormsModule, BarraAcoes, Etapas, Icone, ResumoVenda, VendedorProntuario],
  templateUrl: './pagamento.html',
  styleUrl: './pagamento.css',
})
export class Pagamento {
  valor = 0;
  parcelas = 1;

  readonly formas = signal<FormaPagamento[]>([]);
  readonly formaSelecionada = signal<FormaPagamento | null>(null);
  readonly erro = signal<string | null>(null);
  readonly enviando = signal(false);
  readonly vendaFinalizada = signal<Venda | null>(null);

  readonly opcoesParcelas = computed(() =>
    Array.from({ length: this.formaSelecionada()?.maxParcelas ?? 1 }, (_, i) => i + 1),
  );

  readonly acoes = computed<Acao[]>(() => {
    if (this.vendaFinalizada()) {
      return [{ id: 'nova-venda', rotulo: 'Nova venda', tecla: 'F2', estilo: 'primario' }];
    }
    const rascunho = this.vendaService.rascunho();
    return [
      { id: 'voltar', rotulo: 'Voltar', tecla: 'F3', desabilitada: this.enviando() },
      { id: 'cancelar', rotulo: 'Cancelar venda', tecla: 'F7', estilo: 'perigo', desabilitada: this.enviando() },
      {
        id: 'finalizar',
        rotulo: 'Finalizar venda',
        tecla: 'F2',
        estilo: 'primario',
        desabilitada:
          this.enviando() ||
          rascunho.itens.length === 0 ||
          !rascunho.vendedor ||
          this.vendaService.restante() > 0,
      },
    ];
  });

  constructor(
    protected vendaService: VendaService,
    private api: VendasApiService,
    private router: Router,
    private route: ActivatedRoute,
  ) {
    this.api.listarFormasPagamento().subscribe({
      next: (formas) => this.formas.set(formas),
      error: (erro: Error) => this.erro.set(erro.message),
    });
  }

  executar(acao: string) {
    switch (acao) {
      case 'voltar':
      case 'nova-venda':
        this.irParaPdv();
        break;
      case 'finalizar':
        this.finalizar();
        break;
      case 'cancelar':
        if (confirm('Cancelar a venda em andamento?')) {
          this.vendaService.novaVenda();
          this.irParaPdv();
        }
        break;
    }
  }

  selecionarForma(forma: FormaPagamento) {
    this.formaSelecionada.set(forma);
    this.valor = this.vendaService.restante();
    this.parcelas = 1;
    this.erro.set(null);
  }

  incluirPagamento() {
    const forma = this.formaSelecionada();
    if (!forma) {
      this.erro.set('Selecione uma forma de pagamento.');
      return;
    }
    const erro = this.vendaService.adicionarPagamento(forma, Number(this.valor), Number(this.parcelas));
    this.erro.set(erro);
    if (!erro) {
      this.formaSelecionada.set(null);
    }
  }

  removerPagamento(indice: number) {
    this.vendaService.removerPagamento(indice);
  }

  finalizar() {
    const venda = this.vendaService.montarVenda();
    if (typeof venda === 'string') {
      this.erro.set(venda);
      return;
    }

    this.enviando.set(true);
    this.api.registrarVenda(venda).subscribe({
      next: (registrada) => {
        this.enviando.set(false);
        this.erro.set(null);
        this.vendaService.novaVenda();
        this.vendaFinalizada.set(registrada);
      },
      error: (erro: Error) => {
        this.enviando.set(false);
        this.erro.set(erro.message);
      },
    });
  }

  irParaPdv() {
    this.router.navigate(['../pdv'], { relativeTo: this.route });
  }
}
