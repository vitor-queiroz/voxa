import { Component, OnInit, input, output, signal } from '@angular/core';
import { FormsModule, NgForm } from '@angular/forms';
import { Dialogo } from '../../compartilhado/dialogo/dialogo';
import { VendasApiService } from '../../vendas-api.service';
import { Cliente } from '../../vendas.model';
import { formatarCpf, somenteNumeros, validarCpf } from '../../cpf';

/*Janela de "Novo cliente" e "Editar cadastro" do PDV*/
@Component({
  selector: 'app-cadastro-cliente',
  imports: [FormsModule, Dialogo],
  templateUrl: './cadastro-cliente.html',
  styleUrl: './cadastro-cliente.css',
})
export class CadastroCliente implements OnInit {
  cliente = input<Cliente | null>(null); /*null = novo cadastro*/
  cpfInicial = input('');

  salvo = output<Cliente>();
  fechar = output<void>();

  cpf = '';
  nome = '';
  email = '';
  telefone = '';

  readonly erro = signal<string | null>(null);
  readonly salvando = signal(false);

  constructor(private api: VendasApiService) { }

  ngOnInit() {
    const cliente = this.cliente();
    this.cpf = formatarCpf(cliente?.cpf ?? this.cpfInicial());
    this.nome = cliente?.nome ?? '';
    this.email = cliente?.email ?? '';
    this.telefone = cliente?.telefone ?? '';
  }

  formatar(valor: string) {
    this.cpf = formatarCpf(valor);
  }

  salvar(form: NgForm) {
    if (form.invalid) {
      this.erro.set('Preencha CPF e nome.');
      return;
    }
    if (!validarCpf(this.cpf)) {
      this.erro.set('CPF inválido.');
      return;
    }

    this.salvando.set(true);
    this.api
      .salvarCliente({
        id: this.cliente()?.id ?? null,
        cpf: somenteNumeros(this.cpf),
        nome: this.nome.trim().toUpperCase(),
        email: this.email.trim() || null,
        telefone: this.telefone.trim() || null,
      })
      .subscribe({
        next: (cliente) => {
          this.salvando.set(false);
          this.salvo.emit(cliente);
        },
        error: (erro: Error) => {
          this.salvando.set(false);
          this.erro.set(erro.message);
        },
      });
  }
}
