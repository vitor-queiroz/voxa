import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Input, Output } from '@angular/core';
import { ItemLancamento } from '../lancamento-produtos/lancamento-produtos';

@Component({
  selector: 'app-conferencia-entrada',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './conferencia-entrada.html',
  styleUrl: './conferencia-entrada.css',
})
export class ConferenciaEntrada {
  @Input() dados: {
    itens: ItemLancamento[];
    leiturasPendentes: string[];
  } | null = null;

  @Output() voltar = new EventEmitter<void>();

  get totalPecas(): number {
    return (this.dados?.itens ?? []).reduce(
      (total, item) => total + item.quantidade,
      0,
    );
  }

  get totalReferencias(): number {
    return new Set(
      (this.dados?.itens ?? []).map(item => item.referencia),
    ).size;
  }

  get valorLancado(): number {
    return (this.dados?.itens ?? []).reduce(
      (total, item) => total + item.quantidade * item.custoUnitario,
      0,
    );
  }
}
