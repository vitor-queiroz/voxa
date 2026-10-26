import { Component, input } from '@angular/core';

/*Indicador de etapas da venda: 1 Itens e cliente · 2 Pagamento · 3 Concluída*/
@Component({
  selector: 'app-etapas',
  templateUrl: './etapas.html',
  styleUrl: './etapas.css',
})
export class Etapas {
  atual = input.required<number>();
  readonly etapas = ['Itens e cliente', 'Pagamento', 'Venda concluída'];
}
