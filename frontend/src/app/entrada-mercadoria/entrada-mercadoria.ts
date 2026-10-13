
import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { DadosEntrada } from '../dados-entrada/dados-entrada';
import { LancamentoProdutos, ItemLancamento } from '../lancamento-produtos/lancamento-produtos';
import { ConferenciaEntrada } from '../conferencia-entrada/conferencia-entrada';

interface DadosConferencia {
  itens: ItemLancamento[];
  leiturasPendentes: string[];
}

@Component({
  selector: 'app-entrada-mercadoria',
  standalone: true,
  imports: [CommonModule, DadosEntrada, LancamentoProdutos, ConferenciaEntrada],
  templateUrl: './entrada-mercadoria.html',
  styleUrl: './entrada-mercadoria.css',
})
export class EntradaMercadoria {
  etapaAtual: number = 1;

  dadosConferencia: DadosConferencia | null = null;

  abrirConferencia(dados: DadosConferencia): void {
    this.dadosConferencia = dados;
    this.etapaAtual = 3;
  }
}
