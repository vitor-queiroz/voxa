import { Component, HostListener, input, output } from '@angular/core';
import { Icone, NomeIcone } from '../icone/icone';

export interface Acao {
  id: string;
  rotulo: string;
  icone: NomeIcone;
  tecla?: string; /*ex.: 'F2' — atalho de teclado*/
  desabilitada?: boolean;
  estilo?: 'sucesso' | 'perigo';
}

/*Barra de atalhos no rodapé das telas de venda*/
@Component({
  selector: 'app-barra-acoes',
  imports: [Icone],
  templateUrl: './barra-acoes.html',
  styleUrl: './barra-acoes.css',
})
export class BarraAcoes {
  acoes = input.required<Acao[]>();
  acionar = output<string>();

  @HostListener('document:keydown', ['$event'])
  aoPressionarTecla(evento: KeyboardEvent) {
    const acao = this.acoes().find((a) => a.tecla === evento.key);
    if (!acao) {
      return;
    }
    evento.preventDefault();
    if (!acao.desabilitada) {
      this.acionar.emit(acao.id);
    }
  }
}
