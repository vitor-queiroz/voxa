import { Component, OnInit, input, output } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Dialogo } from '../../compartilhado/dialogo/dialogo';
import { TipoDesconto } from '../../vendas.model';

export interface AjusteValor {
  tipo: TipoDesconto;
  valor: number;
}

/*
 * Janela do símbolo de moeda:
 * - na linha do item: altera o valor unitário (somente R$);
 * - abaixo dos itens: desconto geral da venda (R$ ou %).
 */
@Component({
  selector: 'app-ajuste-valor',
  imports: [FormsModule, Dialogo],
  templateUrl: './ajuste-valor.html',
  styleUrl: './ajuste-valor.css',
})
export class AjusteValorDialogo implements OnInit {
  titulo = input.required<string>();
  rotulo = input('Valor');
  dica = input('');
  valorAtual = input(0);
  tipoAtual = input<TipoDesconto>('VALOR');
  permitirPercentual = input(false);
  erro = input<string | null>(null);

  confirmar = output<AjusteValor>();
  fechar = output<void>();

  tipo: TipoDesconto = 'VALOR';
  valor = 0;

  ngOnInit() {
    this.tipo = this.tipoAtual();
    this.valor = this.valorAtual();
  }

  enviar() {
    this.confirmar.emit({ tipo: this.tipo, valor: Number(this.valor) || 0 });
  }
}
