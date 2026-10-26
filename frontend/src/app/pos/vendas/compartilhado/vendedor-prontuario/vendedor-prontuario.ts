import { Component, computed, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { VendasApiService } from '../../vendas-api.service';
import { VendaService, normalizarProntuario, podeVender } from '../../venda.service';
import { Funcionario } from '../../vendas.model';

/*
 * Campo "Prontuário do vendedor": busca o funcionário e vincula à venda.
 * Usado no PDV e na tela de pagamento.
 */
@Component({
  selector: 'app-vendedor-prontuario',
  imports: [FormsModule],
  templateUrl: './vendedor-prontuario.html',
  styleUrl: './vendedor-prontuario.css',
})
export class VendedorProntuario {
  prontuario = '';

  readonly funcionarios = signal<Funcionario[]>([]);
  readonly encontrado = signal<Funcionario | null>(null);
  readonly erro = signal<string | null>(null);

  readonly bloqueado = computed(() => {
    const funcionario = this.encontrado();
    return funcionario !== null && !podeVender(funcionario);
  });

  constructor(
    protected vendaService: VendaService,
    private api: VendasApiService,
  ) {
    this.api.listarFuncionarios().subscribe({
      next: (lista) => this.funcionarios.set(lista.filter(podeVender)),
      error: () => this.funcionarios.set([]), /*só tira as sugestões; a busca mostra o erro*/
    });

    const vinculado = vendaService.rascunho().vendedor;
    this.prontuario = vinculado?.prontuario ?? '';
    this.encontrado.set(vinculado);
  }

  buscar() {
    const prontuario = normalizarProntuario(this.prontuario);
    this.prontuario = prontuario;
    this.erro.set(null);
    this.encontrado.set(null);
    this.vendaService.definirVendedor(null);
    if (!prontuario) {
      return;
    }

    this.api.buscarFuncionario(prontuario).subscribe({
      next: (funcionario) => {
        if (!funcionario) {
          this.erro.set(`Prontuário ${prontuario} não encontrado.`);
          return;
        }
        this.encontrado.set(funcionario);
        if (!podeVender(funcionario)) {
          return; /*mostra o aviso, mas não vincula*/
        }
        this.vendaService.definirVendedor(funcionario);
      },
      error: (erro: Error) => this.erro.set(erro.message),
    });
  }
}
