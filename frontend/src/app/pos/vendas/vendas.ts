import { Component, DOCUMENT, ViewEncapsulation, inject } from '@angular/core';
import { DatePipe } from '@angular/common';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';

const FONTES_URL =
  'https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap';

/*
 * Tela base do módulo de vendas: barra superior VOXA + área das telas.
 * Os estilos de vendas.css e vendas-componentes.css valem para todas as telas do módulo,
 * mas ficam restritos ao <app-vendas>, sem afetar o resto do sistema.
 */
@Component({
  selector: 'app-vendas',
  imports: [DatePipe, RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './vendas.html',
  styleUrls: ['./vendas.css', './vendas-componentes.css'],
  encapsulation: ViewEncapsulation.None,
})
export class Vendas {
  readonly hoje = new Date();

  constructor() {
    carregarFontes(inject(DOCUMENT));
  }
}

/*Fontes do design (IBM Plex). Sem internet, o navegador usa as fontes de reserva do CSS*/
function carregarFontes(documento: Document) {
  if (documento.querySelector('link[data-vx-fontes]')) {
    return;
  }
  const link = documento.createElement('link');
  link.setAttribute('data-vx-fontes', '');
  link.rel = 'stylesheet';
  link.href = FONTES_URL;
  documento.head.appendChild(link);
}
