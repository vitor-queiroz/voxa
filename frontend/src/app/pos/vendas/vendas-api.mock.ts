import { Injectable, Provider } from '@angular/core';
import { Observable, of, throwError } from 'rxjs';
import { ApiVendas, VendasApiService } from './vendas-api.service';
import {
  Cliente,
  FiltroVendas,
  FormaPagamento,
  Funcionario,
  ProdutoVariacao,
  ResumoVendedor,
  Venda,
} from './vendas.model';
import {
  CASHBACK_MOCK,
  CLIENTES_MOCK,
  FORMAS_PAGAMENTO_MOCK,
  FUNCIONARIOS_MOCK,
  VARIACOES_MOCK,
  vendasIniciaisMock,
} from './vendas.mock';

/*
 * Versão de EXEMPLO da API de vendas: responde com os dados de vendas.mock.ts, sem backend.
 * Usada nos testes e quando USAR_DADOS_DE_EXEMPLO = true (vendas.config.ts).
 * Cada método indica o endpoint real que ele simula.
 */
@Injectable()
export class VendasApiMockService implements ApiVendas {
  private clientes = [...CLIENTES_MOCK];
  private vendas: Venda[] = vendasIniciaisMock();
  private proximoNumero = this.vendas.length + 1;

  /*GET /funcionarios — somente prontuario, nome, funcao e situacao (sem CPF/RG)*/
  listarFuncionarios(): Observable<Funcionario[]> {
    return of(FUNCIONARIOS_MOCK);
  }

  /*GET /funcionarios/{prontuario} — 404 quando não existe (aqui: null)*/
  buscarFuncionario(prontuario: string): Observable<Funcionario | null> {
    return of(FUNCIONARIOS_MOCK.find((f) => f.prontuario === prontuario) ?? null);
  }


  /*GET /clientes?cpf={cpf} — 404 quando não existe (aqui: null)*/
  buscarClientePorCpf(cpf: string): Observable<Cliente | null> {
    return of(this.clientes.find((c) => c.cpf === cpf) ?? null);
  }

  /*POST /clientes (id null) ou PUT /clientes/{id} — devolve o cliente salvo, com id*/
  salvarCliente(cliente: Cliente): Observable<Cliente> {
    if (cliente.id === null && this.clientes.some((c) => c.cpf === cliente.cpf)) {
      return throwError(() => new Error('Já existe um cliente com este CPF.'));
    }
    const salvo: Cliente = { ...cliente, id: cliente.id ?? this.clientes.length + 1 };
    this.clientes = [...this.clientes.filter((c) => c.id !== salvo.id), salvo];
    return of(salvo);
  }

  /*GET /clientes/{cpf}/cashback — { "saldo": 25.50 }*/
  consultarCashback(cpf: string): Observable<number> {
    return of(CASHBACK_MOCK[cpf] ?? 0);
  }

  /*GET /produtos/variacoes/busca?termo={termo} — termo = "REF/TAM" (12345/42) ou código de barras*/
  buscarVariacao(termo: string): Observable<ProdutoVariacao | null> {
    const busca = termo.trim().toUpperCase();
    const variacao = VARIACOES_MOCK.find(
      (v) =>
        v.codigoBarras === busca ||
        `${v.produto.referencia}/${v.tamanho}`.toUpperCase() === busca,
    );
    return of(variacao ?? null);
  }

  /*GET /formas-pagamento*/
  listarFormasPagamento(): Observable<FormaPagamento[]> {
    return of(FORMAS_PAGAMENTO_MOCK);
  }

  /*POST /vendas — o backend define "numero", "data", "status" e recalcula a comissão*/
  registrarVenda(venda: Venda): Observable<Venda> {
    const registrada: Venda = {
      ...venda,
      numero: this.proximoNumero++,
      data: new Date().toISOString(),
      status: 'FINALIZADA',
    };
    this.vendas = [registrada, ...this.vendas];
    return of(registrada);
  }

  /*GET /vendas?de=AAAA-MM-DD&ate=AAAA-MM-DD&prontuario=0001 — mais recentes primeiro*/
  listarVendas(filtro: FiltroVendas = {}): Observable<Venda[]> {
    return of(this.vendas.filter((v) => atendeFiltro(v, filtro)));
  }

  /*PATCH /vendas/{numero}/cancelamento — devolve a venda com status CANCELADA*/
  cancelarVenda(numero: number): Observable<Venda> {
    const venda = this.vendas.find((v) => v.numero === numero);
    if (!venda) {
      return throwError(() => new Error(`Venda nº ${numero} não encontrada.`));
    }
    const cancelada: Venda = { ...venda, status: 'CANCELADA' };
    this.vendas = this.vendas.map((v) => (v.numero === numero ? cancelada : v));
    return of(cancelada);
  }

  /*
   * GET /vendas/resumo-vendedores?de=AAAA-MM-DD&ate=AAAA-MM-DD
   * Uma linha por funcionário com os totais das vendas FINALIZADAS no período (sem comissão).
   */
  resumoVendedores(filtro: FiltroVendas = {}): Observable<ResumoVendedor[]> {
    const finalizadas = this.vendas.filter((v) => v.status === 'FINALIZADA' && atendeFiltro(v, filtro));
    return of(
      FUNCIONARIOS_MOCK.map((vendedor) => {
        const dele = finalizadas.filter((v) => v.vendedor.prontuario === vendedor.prontuario);
        return {
          vendedor,
          quantidadeVendas: dele.length,
          pecas: dele.reduce((soma, v) => soma + v.itens.reduce((s, i) => s + i.quantidade, 0), 0),
          totalVendido: arredondar(dele.reduce((soma, v) => soma + v.total, 0)),
        };
      }),
    );
  }
}

function atendeFiltro(venda: Venda, filtro: FiltroVendas): boolean {
  const dia = venda.data ? diaLocal(venda.data) : '';
  return (
    (!filtro.de || dia >= filtro.de) &&
    (!filtro.ate || dia <= filtro.ate) &&
    (!filtro.prontuario || venda.vendedor.prontuario === filtro.prontuario)
  );
}

/*AAAA-MM-DD no fuso do navegador*/
function diaLocal(iso: string): string {
  const data = new Date(iso);
  const mes = String(data.getMonth() + 1).padStart(2, '0');
  const dia = String(data.getDate()).padStart(2, '0');
  return `${data.getFullYear()}-${mes}-${dia}`;
}

function arredondar(valor: number): number {
  return Math.round(valor * 100) / 100;
}

/*Troca a API real pela de exemplo: providers: [provideVendasApiMock()]*/
export function provideVendasApiMock(): Provider {
  return { provide: VendasApiService, useClass: VendasApiMockService };
}
