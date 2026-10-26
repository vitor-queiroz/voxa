import { Component, computed } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { VendaService } from '../../venda.service';

/*Coluna lateral do pagamento: total, quanto já foi pago, quanto falta e troco*/
@Component({
  selector: 'app-resumo-venda',
  imports: [CurrencyPipe],
  templateUrl: './resumo-venda.html',
  styleUrl: './resumo-venda.css',
})
export class ResumoVenda {
  /*Percentual pago, para a barra de progresso*/
  readonly progresso = computed(() => {
    const total = this.vendaService.total();
    return total > 0 ? Math.min(100, (this.vendaService.totalPago() / total) * 100) : 0;
  });

  constructor(protected vendaService: VendaService) { }
}
