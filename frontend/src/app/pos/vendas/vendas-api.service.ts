import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Observable, catchError, map, of, throwError } from 'rxjs';
import {
  Cliente,
  FiltroVendas,
  FormaPagamento,
  Funcionario,
  ProdutoVariacao,
  ResumoVendedor,
  Venda,
} from './vendas.model';
import { API_URL } from './vendas.config';

/*Métodos públicos da API de vendas (a versão de exemplo, VendasApiMockService, segue o mesmo formato)*/
export type ApiVendas = { [M in keyof VendasApiService]: VendasApiService[M] };

/*
 * ÚNICO ponto de comunicação do módulo de vendas com o backend (Spring Boot).
 * Erros do servidor viram Error com a mensagem do backend ({ "mensagem": "..." }),
 * que as telas mostram para o usuário. Buscas que dão 404 devolvem null.
 * O contrato completo está no README.md desta pasta.
 */
@Injectable({
  providedIn: 'root',
})
export class VendasApiService {

  constructor(private http: HttpClient) { }

  /*GET /funcionarios — somente prontuario, nome, funcao e situacao (sem CPF/RG)*/
  listarFuncionarios(): Observable<Funcionario[]> {
    return this.http.get<Funcionario[]>(`${API_URL}/funcionarios`).pipe(catchError(paraErro));
  }

  /*GET /funcionarios/{prontuario} — 404 vira null*/
  buscarFuncionario(prontuario: string): Observable<Funcionario | null> {
    return this.http
      .get<Funcionario>(`${API_URL}/funcionarios/${encodeURIComponent(prontuario)}`)
      .pipe(catchError(nuloSe404));
  }


  /*GET /clientes?cpf={cpf} — 404 vira null*/
  buscarClientePorCpf(cpf: string): Observable<Cliente | null> {
    return this.http.get<Cliente>(`${API_URL}/clientes`, { params: { cpf } }).pipe(catchError(nuloSe404));
  }

  /*POST /clientes (id null) ou PUT /clientes/{id}*/
  salvarCliente(cliente: Cliente): Observable<Cliente> {
    const requisicao =
      cliente.id === null
        ? this.http.post<Cliente>(`${API_URL}/clientes`, cliente)
        : this.http.put<Cliente>(`${API_URL}/clientes/${cliente.id}`, cliente);
    return requisicao.pipe(catchError(paraErro));
  }

  /*GET /clientes/{cpf}/cashback — { "saldo": 25.50 }*/
  consultarCashback(cpf: string): Observable<number> {
    return this.http
      .get<{ saldo: number }>(`${API_URL}/clientes/${cpf}/cashback`)
      .pipe(map((resposta) => resposta.saldo), catchError(paraErro));
  }

  /*GET /produtos/variacoes/busca?termo= — REF/TAM (12345/42) ou código de barras; 404 vira null*/
  buscarVariacao(termo: string): Observable<ProdutoVariacao | null> {
    return this.http
      .get<ProdutoVariacao>(`${API_URL}/produtos/variacoes/busca`, { params: { termo: termo.trim() } })
      .pipe(catchError(nuloSe404));
  }

  /*
   * POST /produtos/variacoes/{id}/imagem (multipart, campo "arquivo").
   * A foto vale para todos os tamanhos da mesma cor; devolve a variação com o novo imagemUrl.
   */
  enviarFoto(variacaoId: number, foto: Blob): Observable<ProdutoVariacao> {
    const dados = new FormData();
    dados.append('arquivo', foto, 'foto.jpg');
    return this.http
      .post<ProdutoVariacao>(`${API_URL}/produtos/variacoes/${variacaoId}/imagem`, dados)
      .pipe(catchError(paraErro));
  }

  /*DELETE /produtos/variacoes/{id}/imagem — tira a foto de todos os tamanhos da mesma cor*/
  removerFoto(variacaoId: number): Observable<ProdutoVariacao> {
    return this.http
      .delete<ProdutoVariacao>(`${API_URL}/produtos/variacoes/${variacaoId}/imagem`)
      .pipe(catchError(paraErro));
  }

  /*GET /formas-pagamento*/
  listarFormasPagamento(): Observable<FormaPagamento[]> {
    return this.http.get<FormaPagamento[]>(`${API_URL}/formas-pagamento`).pipe(catchError(paraErro));
  }

  /*POST /vendas — o backend recalcula os valores e define numero, data, status e comissão*/
  registrarVenda(venda: Venda): Observable<Venda> {
    return this.http.post<Venda>(`${API_URL}/vendas`, venda).pipe(catchError(paraErro));
  }

  /*GET /vendas?de=AAAA-MM-DD&ate=AAAA-MM-DD&prontuario=0001 — mais recentes primeiro*/
  listarVendas(filtro: FiltroVendas = {}): Observable<Venda[]> {
    return this.http
      .get<Venda[]>(`${API_URL}/vendas`, { params: semVazios(filtro) })
      .pipe(catchError(paraErro));
  }

  /*PATCH /vendas/{numero}/cancelamento*/
  cancelarVenda(numero: number): Observable<Venda> {
    return this.http
      .patch<Venda>(`${API_URL}/vendas/${numero}/cancelamento`, null)
      .pipe(catchError(paraErro));
  }

  /*GET /vendas/resumo-vendedores?de=AAAA-MM-DD&ate=AAAA-MM-DD — uma linha por funcionário, sem comissão*/
  resumoVendedores(filtro: FiltroVendas = {}): Observable<ResumoVendedor[]> {
    return this.http
      .get<ResumoVendedor[]>(`${API_URL}/vendas/resumo-vendedores`, { params: semVazios(filtro) })
      .pipe(catchError(paraErro));
  }
}

/*Transforma o erro HTTP em Error com a mensagem do backend*/
function paraErro(erro: HttpErrorResponse): Observable<never> {
  const mensagem =
    erro.status === 0
      ? 'Sem conexão com o servidor. Verifique se o backend está ligado.'
      : (erro.error?.mensagem ?? `Erro ${erro.status} ao falar com o servidor.`);
  return throwError(() => new Error(mensagem));
}

function nuloSe404(erro: HttpErrorResponse): Observable<null> {
  return erro.status === 404 ? of(null) : paraErro(erro);
}

/*Remove filtros vazios da URL*/
function semVazios(filtro: FiltroVendas): Record<string, string> {
  return Object.fromEntries(Object.entries(filtro).filter(([, valor]) => !!valor));
}
