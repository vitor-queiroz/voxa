
import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { DadosEntrada } from '../dados-entrada/dados-entrada';
import { LancamentoProdutos } from '../lancamento-produtos/lancamento-produtos';

@Component({
  selector: 'app-entrada-mercadoria',
  standalone: true,
  imports: [CommonModule, DadosEntrada, LancamentoProdutos],
  templateUrl: './entrada-mercadoria.html',
  styleUrl: './entrada-mercadoria.css',
})
export class EntradaMercadoria {
  etapaAtual: number = 1;
}
