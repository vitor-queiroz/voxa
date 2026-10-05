import { Component } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { VendaService } from '../../venda.service';

/*Resumo dos totais da venda em andamento, com a situação do pagamento*/
@Component({
  selector: 'app-resumo-venda',
  imports: [CurrencyPipe],
  templateUrl: './resumo-venda.html',
  styleUrl: './resumo-venda.css',
})
export class ResumoVenda {
  constructor(protected vendaService: VendaService) { }
}
