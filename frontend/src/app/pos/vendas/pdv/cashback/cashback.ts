import { Component, OnInit, computed, input, output, signal } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Dialogo } from '../../compartilhado/dialogo/dialogo';
import { VendasApiService } from '../../vendas-api.service';
import { Cliente } from '../../vendas.model';

/*Janela "Acesso ao Cashback": consulta o saldo do cliente e resgata na venda*/
@Component({
  selector: 'app-cashback',
  imports: [CurrencyPipe, FormsModule, Dialogo],
  templateUrl: './cashback.html',
  styleUrl: './cashback.css',
})
export class CashbackDialogo implements OnInit {
  cliente = input.required<Cliente>();
  totalVenda = input.required<number>(); /*total antes do cashback*/
  resgateAtual = input(0);

  resgatar = output<number>();
  fechar = output<void>();

  readonly saldo = signal<number | null>(null);
  readonly erro = signal<string | null>(null);
  valorResgate = 0;

  /*Não dá para resgatar mais do que o saldo nem mais do que o total da venda*/
  readonly disponivel = computed(() => Math.min(this.saldo() ?? 0, this.totalVenda()));

  constructor(private api: VendasApiService) { }

  ngOnInit() {
    this.valorResgate = this.resgateAtual();
    this.api.consultarCashback(this.cliente().cpf).subscribe((saldo) => this.saldo.set(saldo));
  }

  confirmar() {
    const valor = Number(this.valorResgate) || 0;
    if (valor < 0 || valor > this.disponivel()) {
      this.erro.set('Valor de resgate acima do cashback disponível.');
      return;
    }
    this.resgatar.emit(valor);
  }
}
