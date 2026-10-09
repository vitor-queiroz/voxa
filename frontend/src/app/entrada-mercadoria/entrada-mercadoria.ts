import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-entrada-mercadoria',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './entrada-mercadoria.html',
  styleUrl: './entrada-mercadoria.css',
})
export class EntradaMercadoria {

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


      const emitente = documento.getElementsByTagNameNS('*', 'emit')[0];
      const ide = documento.getElementsByTagNameNS('*', 'ide')[0];
      const total = documento.getElementsByTagNameNS('*', 'ICMSTot')[0];

      const obterTextoDoBloco = (
        bloco: Element | undefined,
        nome: string
      ): string => {
        return bloco
          ? bloco.getElementsByTagNameNS('*', nome)[0]?.textContent?.trim() ?? ''
          : '';
      };

      this.cnpj = obterTextoDoBloco(emitente, 'CNPJ');
      this.fornecedor = obterTextoDoBloco(emitente, 'xNome');
      this.nota = obterTextoDoBloco(ide, 'nNF');
      this.serie = obterTextoDoBloco(ide, 'serie');
      this.emissao = obterTextoDoBloco(ide, 'dhEmi').substring(0, 10);
      this.natureza = obterTextoDoBloco(ide, 'natOp');
      this.totalNota = obterTextoDoBloco(total, 'vNF');



      const infNFe = documento.getElementsByTagNameNS('*', 'infNFe')[0];
      const identificador = infNFe?.getAttribute('Id') ?? '';

      this.chave = identificador.startsWith('NFe')
        ? identificador.substring(3)
        : identificador;

      this.arquivoSelecionado = arquivo.name;
      this.mensagemXml = 'XML carregado com sucesso! Dados extraídos.';

      console.log('Dados extraídos da NF-e:', {
        cnpj: this.cnpj,
        fornecedor: this.fornecedor,
        nota: this.nota,
        serie: this.serie,
        emissao: this.emissao,
        natureza: this.natureza,
        totalNota: this.totalNota,
        chave: this.chave,
      });
    };

    leitor.onerror = () => {
      this.mensagemXml = 'Erro ao ler o arquivo XML.';
    };

    leitor.readAsText(arquivo);
  }
}