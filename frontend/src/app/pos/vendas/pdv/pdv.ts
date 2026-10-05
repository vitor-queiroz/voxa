import { Component, computed, signal } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { VendaService } from '../venda.service';
import { VendasApiService } from '../vendas-api.service';
import { Cliente, ItemVenda, Vendedor } from '../vendas.model';
import { formatarCpf, somenteNumeros, validarCpf } from '../cpf';
import { Acao, BarraAcoes } from '../compartilhado/barra-acoes/barra-acoes';
import { Icone } from '../compartilhado/icone/icone';
import { AjusteValor, AjusteValorDialogo } from './ajuste-valor/ajuste-valor';
import { CadastroCliente } from './cadastro-cliente/cadastro-cliente';
import { CashbackDialogo } from './cashback/cashback';

type DialogoAberto =
  | { tipo: 'cliente'; cliente: Cliente | null }
  | { tipo: 'cashback' }
  | { tipo: 'valor-item'; indice: number }
  | { tipo: 'desconto' };

/*Tela inicial de vendas: Nova venda | Ponto de venda*/
@Component({
  selector: 'app-pdv',
  imports: [CurrencyPipe, FormsModule, BarraAcoes, Icone, AjusteValorDialogo, CadastroCliente, CashbackDialogo],
  templateUrl: './pdv.html',
  styleUrl: './pdv.css',
})
export class Pdv {
  codigoVendedor = '';
  termoProduto = '';

  readonly vendedores = signal<Vendedor[]>([]);
  readonly cpf = signal('');
  readonly clienteNaoCadastrado = signal(false);
  readonly indiceSelecionado = signal<number | null>(null);
  readonly dialogo = signal<DialogoAberto | null>(null);
  readonly erroVendedor = signal<string | null>(null);
  readonly erroProduto = signal<string | null>(null);
  readonly erroDialogo = signal<string | null>(null);

  readonly estadoCpf = computed<'incompleto' | 'valido' | 'invalido'>(() => {
    const cpf = somenteNumeros(this.cpf());
    if (cpf.length < 11) {
      return 'incompleto';
    }
    return validarCpf(cpf) ? 'valido' : 'invalido';
  });

  /*Item mostrado na "Visualização do item": o selecionado ou o último incluído*/
  readonly itemVisualizado = computed<ItemVenda | null>(() => {
    const itens = this.vendaService.rascunho().itens;
    return itens[this.indiceSelecionado() ?? itens.length - 1] ?? null;
  });

  readonly acoes = computed<Acao[]>(() => {
    const rascunho = this.vendaService.rascunho();
    const semItens = rascunho.itens.length === 0;
    return [
      { id: 'novo-cliente', rotulo: 'Novo cliente', icone: 'usuario', tecla: 'F4' },
      { id: 'limpar', rotulo: 'Limpar carrinho', icone: 'lixeira', tecla: 'F6', desabilitada: semItens },
      { id: 'cancelar', rotulo: 'Cancelar venda', icone: 'cancelar', tecla: 'F7' },
      { id: 'editar-cliente', rotulo: 'Editar cadastro', icone: 'editar', tecla: 'F8', desabilitada: !rascunho.cliente },
      { id: 'pagamento', rotulo: 'Ir para pagamento', icone: 'carrinho', tecla: 'F2', estilo: 'sucesso', desabilitada: semItens },
      { id: 'sair', rotulo: 'Sair', icone: 'sair', estilo: 'perigo' },
    ];
  });

  constructor(
    protected vendaService: VendaService,
    private api: VendasApiService,
    private router: Router,
    private route: ActivatedRoute,
  ) {
    this.api.listarVendedores().subscribe((vendedores) => this.vendedores.set(vendedores));

    /*Ao voltar do pagamento, mostra o que já estava preenchido*/
    const rascunho = vendaService.rascunho();
    this.codigoVendedor = rascunho.vendedor?.codigo ?? '';
    this.cpf.set(formatarCpf(rascunho.cliente?.cpf ?? ''));
  }

  executar(acao: string) {
    if (this.dialogo()) {
      return; /*atalhos ficam inativos enquanto houver uma janela aberta*/
    }
    switch (acao) {
      case 'novo-cliente':
        this.abrirDialogo({ tipo: 'cliente', cliente: null });
        break;
      case 'editar-cliente':
        this.abrirDialogo({ tipo: 'cliente', cliente: this.vendaService.rascunho().cliente });
        break;
      case 'limpar':
        if (confirm('Remover todos os itens do carrinho?')) {
          this.vendaService.limparItens();
          this.indiceSelecionado.set(null);
        }
        break;
      case 'cancelar':
        if (confirm('Cancelar a venda em andamento?')) {
          this.vendaService.novaVenda();
          this.cpf.set('');
          this.clienteNaoCadastrado.set(false);
          this.indiceSelecionado.set(null);
          this.erroProduto.set(null);
        }
        break;
      case 'pagamento':
        this.irParaPagamento();
        break;
      case 'sair':
        this.sair();
        break;
    }
  }

  buscarVendedor() {
    const codigo = this.codigoVendedor.trim();
    if (!codigo) {
      this.vendaService.definirVendedor(null);
      this.erroVendedor.set(null);
      return;
    }
    this.api.buscarVendedor(codigo).subscribe((vendedor) => {
      this.vendaService.definirVendedor(vendedor);
      this.erroVendedor.set(vendedor ? null : 'Vendedor não encontrado.');
    });
  }

  alterarCpf(valor: string) {
    this.cpf.set(formatarCpf(valor));
    this.clienteNaoCadastrado.set(false);

    const cpf = somenteNumeros(valor);
    if (this.vendaService.rascunho().cliente?.cpf !== cpf) {
      this.vendaService.definirCliente(null);
    }
    if (this.estadoCpf() !== 'valido') {
      return;
    }
    this.api.buscarClientePorCpf(cpf).subscribe((cliente) => {
      this.vendaService.definirCliente(cliente);
      this.clienteNaoCadastrado.set(cliente === null);
    });
  }

  incluirProduto() {
    const termo = this.termoProduto.trim();
    if (!termo) {
      return;
    }
    this.api.buscarVariacao(termo).subscribe((variacao) => {
      if (!variacao) {
        this.erroProduto.set(`Produto "${termo}" não encontrado.`);
        return;
      }
      this.vendaService.incluirItem(variacao);
      this.indiceSelecionado.set(null);
      this.erroProduto.set(null);
      this.termoProduto = '';
    });
  }

  alterarQuantidade(indice: number, evento: Event) {
    const campo = evento.target as HTMLInputElement;
    const erro = this.vendaService.alterarQuantidade(indice, Number(campo.value));
    this.erroProduto.set(erro);
    if (erro) {
      campo.value = String(this.vendaService.rascunho().itens[indice].quantidade);
    }
  }

  removerItem(indice: number) {
    this.vendaService.removerItem(indice);
    this.indiceSelecionado.set(null);
  }

  abrirDialogo(dialogo: DialogoAberto) {
    this.erroDialogo.set(null);
    this.dialogo.set(dialogo);
  }

  fecharDialogo() {
    this.dialogo.set(null);
  }

  aoSalvarCliente(cliente: Cliente) {
    this.vendaService.definirCliente(cliente);
    this.cpf.set(formatarCpf(cliente.cpf));
    this.clienteNaoCadastrado.set(false);
    this.fecharDialogo();
  }

  aoResgatarCashback(valor: number) {
    this.vendaService.definirCashback(valor);
    this.fecharDialogo();
  }

  aoAlterarValorItem(indice: number, ajuste: AjusteValor) {
    this.concluirAjuste(this.vendaService.alterarPrecoItem(indice, ajuste.valor));
  }

  aoAplicarDesconto(ajuste: AjusteValor) {
    this.concluirAjuste(this.vendaService.definirDesconto(ajuste));
  }

  irParaPagamento() {
    if (!this.vendaService.rascunho().vendedor) {
      this.erroVendedor.set('Informe o vendedor antes do pagamento.');
      return;
    }
    this.router.navigate(['../pagamento'], { relativeTo: this.route });
  }

  sair() {
    const temItens = this.vendaService.rascunho().itens.length > 0;
    if (!temItens || confirm('Sair e descartar a venda em andamento?')) {
      this.vendaService.novaVenda();
      this.router.navigate(['/login']);
    }
  }

  private concluirAjuste(erro: string | null) {
    this.erroDialogo.set(erro);
    if (!erro) {
      this.fecharDialogo();
    }
  }
}
