import { Component, computed, signal } from '@angular/core';
import { CurrencyPipe, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { VendasApiService } from '../vendas-api.service';
import { ResumoVendedor, StatusVenda, Venda } from '../vendas.model';

type Periodo = 'hoje' | '7' | '30' | 'mes' | 'personalizado';

/*
 * Painel de vendas: quais vendas foram feitas, por qual vendedor e de qual valor.
 * Não mostra comissão, porque todos os funcionários têm acesso ao sistema.
 */
@Component({
  selector: 'app-painel-vendas',
  imports: [CurrencyPipe, DatePipe, FormsModule],
  templateUrl: './painel-vendas.html',
  styleUrl: './painel-vendas.css',
})
export class PainelVendas {
  readonly periodo = signal<Periodo>('30');
  readonly de = signal(diasAtras(29));
  readonly ate = signal(diasAtras(0));
  readonly prontuario = signal(''); /*'' = todos os vendedores*/
  readonly situacao = signal<StatusVenda | ''>('');

  readonly resumo = signal<ResumoVendedor[]>([]);
  readonly vendasDoPeriodo = signal<Venda[]>([]);
  readonly erro = signal<string | null>(null);

  /*Vendedores com mais vendas primeiro*/
  readonly ranking = computed(() =>
    [...this.resumo()].sort((a, b) => b.totalVendido - a.totalVendido || a.vendedor.nome.localeCompare(b.vendedor.nome)),
  );

  readonly vendas = computed(() =>
    this.vendasDoPeriodo().filter(
      (v) =>
        (!this.prontuario() || v.vendedor.prontuario === this.prontuario()) &&
        (!this.situacao() || v.status === this.situacao()),
    ),
  );

  /*Indicadores: só vendas finalizadas da lista filtrada*/
  readonly totais = computed(() => {
    const finalizadas = this.vendas().filter((v) => v.status === 'FINALIZADA');
    const totalVendido = finalizadas.reduce((soma, v) => soma + v.total, 0);
    return {
      vendas: finalizadas.length,
      canceladas: this.vendas().length - finalizadas.length,
      pecas: finalizadas.reduce((soma, v) => soma + pecasDa(v), 0),
      totalVendido,
      ticketMedio: finalizadas.length ? totalVendido / finalizadas.length : 0,
    };
  });

  readonly maiorTotal = computed(() => Math.max(0, ...this.resumo().map((r) => r.totalVendido)));

  readonly pecasDa = pecasDa;

  constructor(private api: VendasApiService) {
    this.carregar();
  }

  escolherPeriodo(periodo: Periodo) {
    this.periodo.set(periodo);
    const hoje = new Date();
    const inicio: Record<Exclude<Periodo, 'personalizado'>, string> = {
      hoje: diasAtras(0),
      '7': diasAtras(6),
      '30': diasAtras(29),
      mes: formatarDia(new Date(hoje.getFullYear(), hoje.getMonth(), 1)),
    };
    if (periodo !== 'personalizado') {
      this.de.set(inicio[periodo]);
      this.ate.set(diasAtras(0));
    }
    this.carregar();
  }

  alterarData(campo: 'de' | 'ate', valor: string) {
    this[campo].set(valor);
    this.periodo.set('personalizado');
    this.carregar();
  }

  /*Clicar no vendedor filtra a lista; clicar de novo mostra todos*/
  filtrarVendedor(prontuario: string) {
    this.prontuario.set(this.prontuario() === prontuario ? '' : prontuario);
  }

  larguraBarra(total: number): number {
    return this.maiorTotal() > 0 ? (total / this.maiorTotal()) * 100 : 0;
  }

  carregar() {
    const filtro = { de: this.de(), ate: this.ate() };
    this.api.resumoVendedores(filtro).subscribe({
      next: (resumo) => {
        this.erro.set(null);
        this.resumo.set(resumo);
      },
      error: (erro: Error) => this.erro.set(erro.message),
    });
    this.api.listarVendas(filtro).subscribe({
      next: (vendas) => this.vendasDoPeriodo.set(vendas),
      error: (erro: Error) => this.erro.set(erro.message),
    });
  }
}

function pecasDa(venda: Venda): number {
  return venda.itens.reduce((soma, item) => soma + item.quantidade, 0);
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
