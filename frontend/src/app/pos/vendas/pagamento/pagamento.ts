import { Component, computed, signal } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { VendaService } from '../venda.service';
import { VendasApiService } from '../vendas-api.service';
import { FormaPagamento, Venda } from '../vendas.model';
import { Acao, BarraAcoes } from '../compartilhado/barra-acoes/barra-acoes';
import { ResumoVenda } from '../compartilhado/resumo-venda/resumo-venda';

/*Tela de pagamento: escolha das formas de pagamento e finalização da venda*/
@Component({
  selector: 'app-pagamento',
  imports: [CurrencyPipe, FormsModule, BarraAcoes, ResumoVenda],
  templateUrl: './pagamento.html',
  styleUrl: './pagamento.css',
})
export class Pagamento {
  valor = 0;
  parcelas = 1;

  readonly formas = signal<FormaPagamento[]>([]);
  readonly formaSelecionada = signal<FormaPagamento | null>(null);
  readonly indicePagamento = signal<number | null>(null);
  readonly erro = signal<string | null>(null);
  readonly enviando = signal(false);
  readonly vendaFinalizada = signal<Venda | null>(null);

  readonly opcoesParcelas = computed(() =>
    Array.from({ length: this.formaSelecionada()?.maxParcelas ?? 1 }, (_, i) => i + 1),
  );

  readonly acoes = computed<Acao[]>(() => {
    const bloqueada = this.vendaFinalizada() !== null || this.enviando();
    return [
      { id: 'voltar', rotulo: 'Voltar', icone: 'voltar', tecla: 'F3', desabilitada: bloqueada },
      { id: 'incluir', rotulo: 'Incluir pagamento', icone: 'mais', tecla: 'F9', desabilitada: bloqueada },
      {
        id: 'excluir',
        rotulo: 'Excluir pagamento',
        icone: 'menos',
        tecla: 'F8',
        desabilitada: bloqueada || this.indicePagamento() === null,
      },
      { id: 'cancelar', rotulo: 'Cancelar venda', icone: 'cancelar', tecla: 'F7', estilo: 'perigo', desabilitada: bloqueada },
      {
        id: 'finalizar',
        rotulo: 'Finalizar venda',
        icone: 'confirmar',
        tecla: 'F2',
        estilo: 'sucesso',
        desabilitada: bloqueada || this.vendaService.restante() > 0,
      },
    ];
  });

  constructor(
    protected vendaService: VendaService,
    private api: VendasApiService,
    private router: Router,
    private route: ActivatedRoute,
  ) {
    this.api.listarFormasPagamento().subscribe((formas) => this.formas.set(formas));
  }

  executar(acao: string) {
    switch (acao) {
      case 'voltar':
        this.irParaPdv();
        break;
      case 'finalizar':
        this.finalizar();
        break;
      case 'incluir':
        this.incluirPagamento();
        break;
      case 'excluir':
        this.excluirPagamento();
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

  excluirPagamento() {
    const indice = this.indicePagamento();
    if (indice === null) {
      return;
    }
    this.vendaService.removerPagamento(indice);
    this.indicePagamento.set(null);
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
