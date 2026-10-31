import { Component, HostListener, computed, signal } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { VendaService } from '../venda.service';
import { VendasApiService } from '../vendas-api.service';
import { Cliente, ItemVenda } from '../vendas.model';
import { formatarCpf, somenteNumeros, validarCpf } from '../cpf';
import { TAMANHO_MAXIMO_FOTO, TIPOS_FOTO, enderecoFoto, reduzirFoto } from '../foto';
import { Acao, BarraAcoes } from '../compartilhado/barra-acoes/barra-acoes';
import { Etapas } from '../compartilhado/etapas/etapas';
import { Icone } from '../compartilhado/icone/icone';
import { VendedorProntuario } from '../compartilhado/vendedor-prontuario/vendedor-prontuario';
import { AjusteValor, AjusteValorDialogo } from './ajuste-valor/ajuste-valor';
import { CadastroCliente } from './cadastro-cliente/cadastro-cliente';
import { CashbackDialogo } from './cashback/cashback';

type DialogoAberto =
  | { tipo: 'cliente'; cliente: Cliente | null }
  | { tipo: 'cashback' }
  | { tipo: 'valor-item'; indice: number }
  | { tipo: 'desconto' };

/*Etapa 1 da venda: vendedor (prontuário), cliente e lançamento dos itens*/
@Component({
  selector: 'app-pdv',
  imports: [
    CurrencyPipe,
    FormsModule,
    BarraAcoes,
    Etapas,
    Icone,
    VendedorProntuario,
    AjusteValorDialogo,
    CadastroCliente,
    CashbackDialogo,
  ],
  templateUrl: './pdv.html',
  styleUrl: './pdv.css',
})
export class Pdv {
  termoProduto = '';

  readonly cpf = signal('');
  readonly cpfTocado = signal(false); /*o usuário já saiu do campo de CPF*/
  readonly clienteNaoCadastrado = signal(false);
  readonly indiceSelecionado = signal<number | null>(null);
  readonly dialogo = signal<DialogoAberto | null>(null);
  readonly erroProduto = signal<string | null>(null);
  readonly erroCliente = signal<string | null>(null);
  readonly erroDialogo = signal<string | null>(null);
  readonly erroPagamento = signal<string | null>(null);
  readonly erroFoto = signal<string | null>(null);
  readonly enviandoFoto = signal(false);
  readonly tiposFoto = TIPOS_FOTO.join(',');

  /*Reduz a foto antes do envio (trocada nos testes, que não têm canvas)*/
  prepararFoto: (arquivo: Blob) => Promise<Blob> = reduzirFoto;

  readonly estadoCpf = computed<'incompleto' | 'valido' | 'invalido'>(() => {
    const cpf = somenteNumeros(this.cpf());
    if (cpf.length < 11) {
      return 'incompleto';
    }
    return validarCpf(cpf) ? 'valido' : 'invalido';
  });

  readonly digitosCpf = computed(() => somenteNumeros(this.cpf()).length);

  /*Aviso do campo CPF: inválido na hora; incompleto só depois de sair do campo*/
  readonly avisoCpf = computed<string | null>(() => {
    if (this.estadoCpf() === 'invalido') {
      return 'CPF inválido. Confira os números digitados.';
    }
    const faltam = 11 - this.digitosCpf();
    if (this.cpfTocado() && faltam > 0 && faltam < 11) {
      return `CPF incompleto: ${faltam === 1 ? 'falta 1 dígito' : `faltam ${faltam} dígitos`}.`;
    }
    return null;
  });

  /*Última leitura do leitor/teclado (linha de confirmação abaixo do campo)*/
  readonly ultimoItem = computed<ItemVenda | null>(() => this.vendaService.rascunho().itens.at(-1) ?? null);

  /*Item da foto: o selecionado na tabela ou o último incluído*/
  readonly itemVisualizado = computed<ItemVenda | null>(() => {
    const itens = this.vendaService.rascunho().itens;
    return itens[this.indiceSelecionado() ?? itens.length - 1] ?? null;
  });

  readonly fotoVisualizada = computed(() => enderecoFoto(this.itemVisualizado()?.variacao.imagemUrl));

  readonly acoes = computed<Acao[]>(() => {
    const rascunho = this.vendaService.rascunho();
    const semItens = rascunho.itens.length === 0;
    return [
      { id: 'sair', rotulo: 'Sair' },
      { id: 'novo-cliente', rotulo: 'Novo cliente', tecla: 'F4' },
      { id: 'editar-cliente', rotulo: 'Editar cadastro', tecla: 'F8', desabilitada: !rascunho.cliente },
      { id: 'limpar', rotulo: 'Limpar carrinho', tecla: 'F6', desabilitada: semItens },
      { id: 'cancelar', rotulo: 'Cancelar venda', tecla: 'F7', estilo: 'perigo' },
      { id: 'pagamento', rotulo: 'Ir para pagamento', tecla: 'F2', estilo: 'primario', desabilitada: semItens },
    ];
  });

  constructor(
    protected vendaService: VendaService,
    private api: VendasApiService,
    private router: Router,
    private route: ActivatedRoute,
  ) {
    /*Ao voltar do pagamento, mostra o cliente que já estava preenchido*/
    this.cpf.set(formatarCpf(vendaService.rascunho().cliente?.cpf ?? ''));
  }

  /*Del remove a linha selecionada (fora de campos de texto)*/
  @HostListener('document:keydown.delete', ['$event'])
  aoPressionarDelete(evento: Event) {
    const indice = this.indiceSelecionado();
    const emCampo = (evento.target as HTMLElement).closest('input, select, textarea');
    if (indice !== null && !emCampo && !this.dialogo()) {
      this.removerItem(indice);
    }
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
          this.cpfTocado.set(false);
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

  alterarCpf(valor: string) {
    this.cpf.set(formatarCpf(valor));
    this.clienteNaoCadastrado.set(false);
    this.erroCliente.set(null);

    const cpf = somenteNumeros(valor);
    if (this.vendaService.rascunho().cliente?.cpf !== cpf) {
      this.vendaService.definirCliente(null);
    }
    if (this.estadoCpf() !== 'valido') {
      return;
    }
    this.api.buscarClientePorCpf(cpf).subscribe({
      next: (cliente) => {
        this.vendaService.definirCliente(cliente);
        this.clienteNaoCadastrado.set(cliente === null);
      },
      error: (erro: Error) => this.erroCliente.set(erro.message),
    });
  }

  incluirProduto() {
    const termo = this.termoProduto.trim();
    if (!termo) {
      return;
    }
    this.api.buscarVariacao(termo).subscribe({
      next: (variacao) => {
        if (!variacao) {
          this.erroProduto.set(`Código ${termo} não encontrado.`);
          return;
        }
        this.vendaService.incluirItem(variacao);
        this.indiceSelecionado.set(null);
        this.erroProduto.set(null);
        this.termoProduto = '';
      },
      error: (erro: Error) => this.erroProduto.set(erro.message),
    });
  }

  /*Foto escolhida no card "Item selecionado": vale para todos os tamanhos da mesma cor*/
  async aoEscolherFoto(evento: Event) {
    const campo = evento.target as HTMLInputElement;
    const arquivo = campo.files?.[0];
    campo.value = ''; /*permite escolher o mesmo arquivo de novo*/
    const item = this.itemVisualizado();
    if (!arquivo || !item) {
      return;
    }
    if (!TIPOS_FOTO.includes(arquivo.type)) {
      this.erroFoto.set('Escolha uma imagem JPG, PNG ou WEBP.');
      return;
    }
    if (arquivo.size > TAMANHO_MAXIMO_FOTO) {
      this.erroFoto.set('A imagem é muito grande (máximo de 20 MB).');
      return;
    }

    this.erroFoto.set(null);
    this.enviandoFoto.set(true);
    let foto: Blob;
    try {
      foto = await this.prepararFoto(arquivo);
    } catch {
      this.enviandoFoto.set(false);
      this.erroFoto.set('Não foi possível ler esta imagem. Use JPG, PNG ou WEBP.');
      return;
    }
    this.api.enviarFoto(item.variacao.id, foto).subscribe({
      next: (variacao) => {
        this.vendaService.atualizarFoto(variacao);
        this.enviandoFoto.set(false);
      },
      error: (erro: Error) => {
        this.erroFoto.set(erro.message);
        this.enviandoFoto.set(false);
      },
    });
  }

  removerFoto() {
    const item = this.itemVisualizado();
    if (!item || !confirm(`Remover a foto de ${item.variacao.produto.nome} (${item.variacao.cor})?`)) {
      return;
    }
    this.erroFoto.set(null);
    this.enviandoFoto.set(true);
    this.api.removerFoto(item.variacao.id).subscribe({
      next: (variacao) => {
        this.vendaService.atualizarFoto(variacao);
        this.enviandoFoto.set(false);
      },
      error: (erro: Error) => {
        this.erroFoto.set(erro.message);
        this.enviandoFoto.set(false);
      },
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
      this.erroPagamento.set('Informe o prontuário do vendedor antes do pagamento.');
      return;
    }
    this.erroPagamento.set(null);
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
