import { Component, computed, signal } from '@angular/core';
import { CurrencyPipe, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { VendasApiService } from '../vendas-api.service';
import { podeVender } from '../venda.service';
import { ResumoComissao, Venda } from '../vendas.model';

type Periodo = 'hoje' | '7' | '30' | 'mes' | 'personalizado';

/*Painel de vendedores: vendas e comissão de cada prontuário no período*/
@Component({
  selector: 'app-painel-vendedores',
  imports: [CurrencyPipe, DatePipe, FormsModule],
  templateUrl: './painel-vendedores.html',
  styleUrl: './painel-vendedores.css',
})
export class PainelVendedores {
  readonly periodo = signal<Periodo>('30');
  readonly de = signal(diasAtras(29));
  readonly ate = signal(diasAtras(0));
  readonly somenteAtivos = signal(false);

  readonly linhas = signal<ResumoComissao[]>([]);
  readonly prontuarioSelecionado = signal<string | null>(null);
  readonly vendasDoVendedor = signal<Venda[]>([]);
  readonly erro = signal<string | null>(null);

  /*Maior total vendido primeiro; filtro opcional por quem está trabalhando*/
  readonly ranking = computed(() =>
    this.linhas()
      .filter((l) => !this.somenteAtivos() || podeVender(l.vendedor))
      .sort((a, b) => b.totalVendido - a.totalVendido),
  );

  readonly totais = computed(() => {
    const linhas = this.ranking();
    const soma = (campo: 'quantidadeVendas' | 'pecas' | 'totalVendido' | 'valorComissao') =>
      linhas.reduce((total, l) => total + l[campo], 0);
    const vendas = soma('quantidadeVendas');
    const totalVendido = soma('totalVendido');
    return {
      vendas,
      pecas: soma('pecas'),
      totalVendido,
      valorComissao: soma('valorComissao'),
      ticketMedio: vendas > 0 ? totalVendido / vendas : 0,
    };
  });

  /*Base da barra de "Total vendido" (maior valor = barra cheia)*/
  readonly maiorTotal = computed(() => Math.max(0, ...this.ranking().map((l) => l.totalVendido)));

  readonly selecionado = computed(() =>
    this.ranking().find((l) => l.vendedor.prontuario === this.prontuarioSelecionado()) ?? null,
  );

  constructor(private api: VendasApiService) {
    this.carregar();
  }

  escolherPeriodo(periodo: Periodo) {
    this.periodo.set(periodo);
    const hoje = new Date();
    switch (periodo) {
      case 'hoje':
        this.de.set(diasAtras(0));
        break;
      case '7':
        this.de.set(diasAtras(6));
        break;
      case '30':
        this.de.set(diasAtras(29));
        break;
      case 'mes':
        this.de.set(formatarDia(new Date(hoje.getFullYear(), hoje.getMonth(), 1)));
        break;
    }
    if (periodo !== 'personalizado') {
      this.ate.set(diasAtras(0));
    }
    this.carregar();
  }

  alterarData(campo: 'de' | 'ate', valor: string) {
    this[campo].set(valor);
    this.periodo.set('personalizado');
    this.carregar();
  }

  selecionar(prontuario: string) {
    this.prontuarioSelecionado.set(prontuario);
    this.carregarVendasDoVendedor();
  }

  carregar() {
    const filtro = { de: this.de(), ate: this.ate() };
    this.api.resumoComissoes(filtro).subscribe({
      next: (linhas) => {
        this.erro.set(null);
        this.linhas.set(linhas);
      },
      error: (erro: Error) => this.erro.set(erro.message),
    });
    this.carregarVendasDoVendedor();
  }

  /*Percentual da barra de cada vendedor*/
  larguraBarra(total: number): number {
    return this.maiorTotal() > 0 ? (total / this.maiorTotal()) * 100 : 0;
  }

  private carregarVendasDoVendedor() {
    const prontuario = this.prontuarioSelecionado();
    if (!prontuario) {
      return;
    }
    this.api
      .listarVendas({ de: this.de(), ate: this.ate(), prontuario })
      .subscribe({
        next: (vendas) => this.vendasDoVendedor.set(vendas),
        error: (erro: Error) => this.erro.set(erro.message),
      });
  }
}

function formatarDia(data: Date): string {
  const mes = String(data.getMonth() + 1).padStart(2, '0');
  const dia = String(data.getDate()).padStart(2, '0');
  return `${data.getFullYear()}-${mes}-${dia}`;
}

function diasAtras(dias: number): string {
  const data = new Date();
  data.setDate(data.getDate() - dias);
  return formatarDia(data);
}
