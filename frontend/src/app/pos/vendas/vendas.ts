import { Component, ViewEncapsulation } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';

/*
 * Tela base do módulo de vendas: menu de abas + área das telas (PDV, pagamento, consulta).
 * Os estilos de vendas.css valem para todas as telas do módulo (painéis, tabelas, botões),
 * mas ficam restritos ao <app-vendas>, sem afetar o resto do sistema.
 */
@Component({
  selector: 'app-vendas',
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './vendas.html',
  styleUrl: './vendas.css',
  encapsulation: ViewEncapsulation.None,
})
export class Vendas { }
