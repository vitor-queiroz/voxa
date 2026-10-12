
import { CommonModule } from '@angular/common';
import { Component, ChangeDetectorRef } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { FornecedorService } from '../auth/fornecedor.service';

@Component({
  selector: 'app-dados-entrada',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dados-entrada.html',
  styleUrl: './dados-entrada.css',
})
export class DadosEntrada {

  arquivoSelecionado: string = '';
  mensagemXml: string = '';

  cnpj: string = '';
  fornecedor: string = '';
  nota: string = '';
  serie: string = '';
  emissao: string = '';
  natureza: string = '';
  totalNota: string = '';
  chave: string = '';

  mensagemFornecedor = '';
  dataEntrada: string = this.obterDataAtual();

  constructor(private fornecedorService: FornecedorService, private cdr: ChangeDetectorRef) { }

  buscarFornecedorPorCnpj(): void {
    const cnpjLimpo = this.cnpj.replace(/\D/g, '');

    if (!cnpjLimpo) {
      this.mensagemFornecedor = 'Digite o CNPJ do fornecedor.';
      return;
    }

    if (cnpjLimpo.length !== 14) {
      this.mensagemFornecedor = 'O CNPJ deve conter 14 dígitos.';
      return;
    }

    this.mensagemFornecedor = 'Consultando fornecedor...';

    this.fornecedorService.buscarPorCnpj(cnpjLimpo).subscribe({
      next: (fornecedorEncontrado) => {
        this.cnpj = fornecedorEncontrado.cnpj;
        this.fornecedor =
          fornecedorEncontrado.nomeFantasia?.trim() ||
          fornecedorEncontrado.razaoSocial;

        this.mensagemFornecedor = 'Fornecedor encontrado no cadastro!';

        this.cdr.markForCheck();
      },

      error: (erro) => {
        if (erro.status === 404) {
          this.mensagemFornecedor =
            'Fornecedor não cadastrado. Confira o CNPJ ou cadastre-o.';

          this.cdr.markForCheck();
          return;
        }

        this.mensagemFornecedor =
          'Não foi possível consultar o fornecedor. Tente novamente.';

        this.cdr.markForCheck();
        console.error('Erro ao consultar fornecedor:', erro);
      },
    });
  }

  aoSelecionarXml(event: Event): void {
    const input = event.target as HTMLInputElement;
    const arquivo = input.files?.[0];

    if (!arquivo) {
      return;
    }

    if (!arquivo.name.toLowerCase().endsWith('.xml')) {
      this.mensagemXml = 'Selecione um arquivo XML válido.';
      this.arquivoSelecionado = '';
      return;
    }

    const leitor = new FileReader();

    leitor.onload = () => {
      const conteudo = leitor.result;

      this.cdr.markForCheck();

      if (typeof conteudo !== 'string') {
        this.mensagemXml = 'Não foi possível ler o arquivo.';
        return;
      }

      const parser = new DOMParser();
      const documento = parser.parseFromString(
        conteudo,
        'application/xml'
      );

      if (documento.querySelector('parsererror')) {
        this.mensagemXml = 'O arquivo XML está inválido.';
        this.arquivoSelecionado = '';
        return;
      }

      const emitente =
        documento.getElementsByTagNameNS('*', 'emit')[0];
      const ide =
        documento.getElementsByTagNameNS('*', 'ide')[0];
      const total =
        documento.getElementsByTagNameNS('*', 'ICMSTot')[0];

      const obterTextoDoBloco = (
        bloco: Element | undefined,
        nome: string
      ): string => {
        return bloco
          ? bloco.getElementsByTagNameNS('*', nome)[0]
            ?.textContent?.trim() ?? ''
          : '';
      };

      this.cnpj = obterTextoDoBloco(emitente, 'CNPJ')
        .replace(/\D/g, '');

      this.fornecedor = obterTextoDoBloco(emitente, 'xNome');
      this.nota = obterTextoDoBloco(ide, 'nNF');
      this.serie = obterTextoDoBloco(ide, 'serie');
      this.emissao = obterTextoDoBloco(ide, 'dhEmi')
        .substring(0, 10);
      this.natureza = obterTextoDoBloco(ide, 'natOp');
      this.totalNota = obterTextoDoBloco(total, 'vNF');

      const infNFe =
        documento.getElementsByTagNameNS('*', 'infNFe')[0];

      const identificador = infNFe?.getAttribute('Id') ?? '';

      this.chave = identificador.startsWith('NFe')
        ? identificador.substring(3)
        : identificador;

      this.arquivoSelecionado = arquivo.name;

      if (!this.cnpj) {
        this.mensagemXml =
          'XML carregado, mas o CNPJ do emitente não foi encontrado.';
        return;
      }

      this.mensagemXml = 'XML carregado. Consultando fornecedor...';

      this.fornecedorService.buscarPorCnpj(this.cnpj).subscribe({
        next: (fornecedorEncontrado) => {
          this.fornecedor =
            fornecedorEncontrado.nomeFantasia?.trim() ||
            fornecedorEncontrado.razaoSocial;

          this.mensagemXml =
            'XML carregado! Fornecedor encontrado no cadastro.';

          this.cdr.markForCheck();  
        },

        error: (erro) => {
          if (erro.status === 404) {
            this.mensagemXml =
              'XML carregado, mas o fornecedor não está cadastrado.';

            this.cdr.markForCheck();
            return;
          }

          this.mensagemXml =
            'XML carregado, mas não foi possível consultar o fornecedor.';

          this.cdr.markForCheck();
          console.error('Erro ao consultar fornecedor:', erro);
        },
      });
    };

    leitor.onerror = () => {
      this.mensagemXml = 'Erro ao ler o arquivo XML.';
      this.cdr.markForCheck();
    };

    leitor.readAsText(arquivo);
  }

  private obterDataAtual(): string {
    const hoje = new Date();
    const deslocamento = hoje.getTimezoneOffset();

    return new Date(hoje.getTime() - deslocamento * 60000)
      .toISOString()
      .slice(0, 10);
  }
}
