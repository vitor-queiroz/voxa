import { Injectable } from '@angular/core';
import { Observable, of, throwError } from 'rxjs';
import { Cliente, FormaPagamento, ProdutoVariacao, Venda, Vendedor } from './vendas.model';
import {
  CASHBACK_MOCK,
  CLIENTES_MOCK,
  FORMAS_PAGAMENTO_MOCK,
  VARIACOES_MOCK,
  VENDEDORES_MOCK,
} from './vendas.mock';

/*
 * ÚNICO ponto de comunicação do módulo de vendas com o backend.
 *
 * Hoje todos os métodos respondem com dados de exemplo (vendas.mock.ts).
 * Para integrar, troque o corpo de cada método pela chamada HTTP indicada no comentário
 * (ex.: return this.http.get<Vendedor[]>(`${this.apiUrl}/vendedores`)).
 * As telas já trabalham com Observable, então não precisam mudar.
 * O contrato completo (JSON de entrada/saída e erros) está no README.md desta pasta.
 */
@Injectable({
  providedIn: 'root',
})
export class VendasApiService {

  /*private apiUrl = 'http://localhost:8080'; — mesmo endereço usado no AuthService*/

  private clientes = [...CLIENTES_MOCK];
  private vendas: Venda[] = [];
  private proximoNumero = 1;

  /*GET /vendedores*/
  listarVendedores(): Observable<Vendedor[]> {
    return of(VENDEDORES_MOCK);
  }

  /*GET /vendedores/{codigo} — 404 quando não existe (aqui: null)*/
  buscarVendedor(codigo: string): Observable<Vendedor | null> {
    const termo = codigo.trim().toUpperCase();
    return of(VENDEDORES_MOCK.find((v) => v.codigo === termo) ?? null);
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

  /*POST /vendas — o backend define "numero", "data" e "status" e devolve a venda gravada*/
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

  /*GET /vendas — mais recentes primeiro*/
  listarVendas(): Observable<Venda[]> {
    return of(this.vendas);
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
}
