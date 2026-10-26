import { Component, input } from '@angular/core';

export type NomeIcone =
  | 'carrinho'
  | 'usuario'
  | 'lixeira'
  | 'cancelar'
  | 'editar'
  | 'sair'
  | 'voltar'
  | 'confirmar'
  | 'mais'
  | 'menos'
  | 'imagem'
  | 'valido'
  | 'invalido'
  | 'fechar';

/*Ícones em SVG (traço no estilo Lucide), sem dependência externa*/
@Component({
  selector: 'app-icone',
  templateUrl: './icone.html',
  styleUrl: './icone.css',
})
export class Icone {
  nome = input.required<NomeIcone>();
  tamanho = input(18);
}
