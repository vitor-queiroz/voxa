import { Component, computed, signal } from '@angular/core';
import { CurrencyPipe, DatePipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { VendasApiService } from '../vendas-api.service';
import { StatusVenda, Venda } from '../vendas.model';

/*Consulta das vendas realizadas, com filtros e detalhe da venda selecionada*/
@Component({
  selector: 'app-consulta-vendas',
  imports: [CurrencyPipe, DatePipe, FormsModule],
  templateUrl: './consulta-vendas.html',
  styleUrl: './consulta-vendas.css',
})
export class ConsultaVendas {
  readonly vendas = signal<Venda[]>([]);
  readonly filtroTexto = signal('');
  readonly filtroStatus = signal<StatusVenda | ''>('');
  readonly numeroSelecionado = signal<number | null>(null);
  readonly erro = signal<string | null>(null);

  readonly vendasFiltradas = computed(() => {
    const texto = this.filtroTexto().trim().toLowerCase();
    const status = this.filtroStatus();
    return this.vendas().filter((v) => {
      if (status && v.status !== status) {
        return false;
      }
      if (!texto) {
        return true;
      }
      return [String(v.numero), v.vendedor.nome, v.cliente?.nome ?? '', v.cliente?.cpf ?? '']
        .some((campo) => campo.toLowerCase().includes(texto));
    });
  });

  readonly vendaSelecionada = computed<Venda | undefined>(() =>
    this.vendas().find((v) => v.numero === this.numeroSelecionado()),
  );

  readonly totalFinalizado = computed(() =>
    this.vendasFiltradas()
      .filter((v) => v.status === 'FINALIZADA')
      .reduce((soma, v) => soma + v.total, 0),
  );

  constructor(private api: VendasApiService) {
    this.carregar();
  }

  carregar() {
    this.api.listarVendas().subscribe((vendas) => this.vendas.set(vendas));
  }

  cancelarVenda(venda: Venda) {
    if (venda.numero === null || !confirm(`Cancelar a venda nº ${venda.numero}?`)) {
      return;
    }
    this.api.cancelarVenda(venda.numero).subscribe({
      next: () => {
        this.erro.set(null);
        this.carregar();
      },
      error: (erro: Error) => this.erro.set(erro.message),
    });
  }
}
