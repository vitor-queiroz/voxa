import { Component, HostListener, input, output } from '@angular/core';
import { Icone } from '../icone/icone';

/*Janela modal genérica. O conteúdo é projetado: <app-dialogo titulo="..."> ... </app-dialogo>*/
@Component({
  selector: 'app-dialogo',
  imports: [Icone],
  templateUrl: './dialogo.html',
  styleUrl: './dialogo.css',
})
export class Dialogo {
  titulo = input.required<string>();
  fechar = output<void>();

  @HostListener('document:keydown.escape')
  aoPressionarEsc() {
    this.fechar.emit();
  }
}
