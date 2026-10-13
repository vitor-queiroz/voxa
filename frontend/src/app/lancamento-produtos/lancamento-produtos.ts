import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Output } from '@angular/core';
import { FormsModule } from '@angular/forms';

type ModoLancamento = 'bipagem' | 'manual';

export interface ItemLancamento {
  referencia: string;
  produto: string;
  cor: string;
  tamanho: number;
  codigoBarras: string;
  quantidade: number;
  custoUnitario: number;
}

@Component({
  selector: 'app-lancamento-produtos',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './lancamento-produtos.html',
  styleUrl: './lancamento-produtos.css',
})

export class LancamentoProdutos {
  @Output() voltar = new EventEmitter<void>();
  @Output() conferir = new EventEmitter<{
    itens: ItemLancamento[];
    leiturasPendentes: string[];
  }>();

  modo: ModoLancamento = 'bipagem';

  codigoBarras = '';
  referencia = '';
  nomeProduto = '';
  cor = '';
  custoUnitario: number | null = null;

  tamanhos = [34, 35, 36, 37, 38, 39, 40];

  grade: Record<number, number> = {
    34: 0,
    35: 0,
    36: 0,
    37: 0,
    38: 0,
    39: 0,
    40: 0,
  };

  itens: ItemLancamento[] = [];

  leiturasPendentes: string[] = [];  // As leituras ficam separadas até a consulta real ao cadastro ser integrada.


  mensagem = '';
  tipoMensagem: 'sucesso' | 'aviso' = 'aviso';

  numeroNota = '—';   // Será preenchido com os dados reais da nota na integração com a etapa 1.
  serieNota = '—';
  fornecedor = 'Aguardando dados da nota';
  valorNota = 0;

  get totalPecas(): number {
    return this.itens.reduce(
      (total, item) => total + item.quantidade,
      0,
    );
  }

  get totalReferencias(): number {
    return new Set(this.itens.map(item => item.referencia)).size;
  }

  get valorLancado(): number {
    return this.itens.reduce(
      (total, item) => total + item.quantidade * item.custoUnitario,
      0,
    );
  }

  get faltaLancar(): number {
    return this.valorNota - this.valorLancado;
  }

  get totalGrade(): number {
    return this.tamanhos.reduce(
      (total, tamanho) => total + (Number(this.grade[tamanho]) || 0),
      0,
    );
  }

  get subtotalManual(): number {
    return this.totalGrade * (Number(this.custoUnitario) || 0);
  }



  selecionarModo(modo: ModoLancamento): void {
    this.modo = modo;
    this.limparMensagem();
  }

  registrarBipagem(): void {
    const codigo = this.codigoBarras.trim();

    if (!codigo) {
      this.exibirMensagem(
        'Informe ou leia um código de barras.',
        'aviso',
      );
      return;
    }

    this.leiturasPendentes.push(codigo);
    this.codigoBarras = '';

    this.exibirMensagem(
      'Leitura registrada. A identificação automática será conectada ao cadastro de produtos.',
      'aviso',
    );
  }

  vincularLeitura(codigo: string): void {
    this.codigoBarras = codigo;
    this.selecionarModo('manual');

    this.exibirMensagem(
      'Preencha os dados do produto para preparar o vínculo desta leitura.',
      'aviso',
    );
  }

  descartarLeitura(indice: number): void {
    this.leiturasPendentes.splice(indice, 1);

    this.exibirMensagem(
      'Leitura pendente descartada.',
      'sucesso',
    );
  }

  adicionarProdutoManual(): void {
    const referencia = this.referencia.trim();
    const produto = this.nomeProduto.trim();
    const cor = this.cor.trim();
    const custo = Number(this.custoUnitario);

    if (!referencia || !produto || !cor) {
      this.exibirMensagem(
        'Preencha a referência, o produto e a cor.',
        'aviso',
      );
      return;
    }

    if (
      this.custoUnitario === null ||
      this.custoUnitario === undefined ||
      !Number.isFinite(custo) ||
      custo < 0
    ) {
      this.exibirMensagem(
        'Informe um custo unitário válido.',
        'aviso',
      );
      return;
    }

    if (this.totalGrade <= 0) {
      this.exibirMensagem(
        'Informe a quantidade de pelo menos um tamanho.',
        'aviso',
      );
      return;
    }

    for (const tamanho of this.tamanhos) {
      const quantidade = Math.max(
        0,
        Math.floor(Number(this.grade[tamanho]) || 0),
      );

      if (quantidade > 0) {
        this.itens.push({
          referencia,
          produto,
          cor,
          tamanho,
          codigoBarras: '',
          quantidade,
          custoUnitario: custo,
        });
      }
    }

    this.exibirMensagem(
      'Itens adicionados à lista desta tela. A gravação definitiva será integrada ao backend.',
      'sucesso',
    );

    this.limparFormularioManual();
  }

  removerItem(indice: number): void {
    this.itens.splice(indice, 1);

    this.exibirMensagem(
      'Item removido da lista desta tela.',
      'sucesso',
    );
  }

  emitirConferencia(): void {
    this.conferir.emit({
      itens: this.itens.map(item => ({ ...item })),
      leiturasPendentes: [...this.leiturasPendentes],
    });
  }


  limparFormularioManual(): void {
    this.referencia = '';
    this.nomeProduto = '';
    this.cor = '';
    this.custoUnitario = null;

    for (const tamanho of this.tamanhos) {
      this.grade[tamanho] = 0;
    }
  }

  limparMensagem(): void {
    this.mensagem = '';
  }

  private exibirMensagem(
    texto: string,
    tipo: 'sucesso' | 'aviso',
  ): void {
    this.mensagem = texto;
    this.tipoMensagem = tipo;
  }
}