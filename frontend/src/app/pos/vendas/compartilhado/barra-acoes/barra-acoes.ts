import { Component, HostListener, input, output } from '@angular/core';

export interface Acao {
  id: string;
  rotulo: string;
  tecla?: string; /*ex.: 'F2' — atalho de teclado*/
  desabilitada?: boolean;
  estilo?: 'primario' | 'perigo';
}

/*Rodapé fixo das telas de venda: dicas à esquerda, ações (com tecla de atalho) à direita*/
@Component({
  selector: 'app-barra-acoes',
  templateUrl: './barra-acoes.html',
  styleUrl: './barra-acoes.css',
})
export class BarraAcoes {
  acoes = input.required<Acao[]>();
  dica = input('');
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
