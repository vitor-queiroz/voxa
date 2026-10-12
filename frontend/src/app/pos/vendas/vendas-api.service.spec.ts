import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { firstValueFrom } from 'rxjs';
import { VendasApiService } from './vendas-api.service';
import { API_URL } from './vendas.config';
import { Cliente, Venda } from './vendas.model';

describe('VendasApiService (HTTP)', () => {
  let api: VendasApiService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [provideHttpClient(), provideHttpClientTesting()],
    });
    api = TestBed.inject(VendasApiService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('deve buscar o funcionário pelo prontuário e devolver null no 404', async () => {
    const encontrado = firstValueFrom(api.buscarFuncionario('0001'));
    http.expectOne(`${API_URL}/funcionarios/0001`).flush({ prontuario: '0001', nome: 'Carlos' });
    expect((await encontrado)?.nome).toBe('Carlos');

    const inexistente = firstValueFrom(api.buscarFuncionario('9999'));
    http.expectOne(`${API_URL}/funcionarios/9999`).flush({ mensagem: 'não encontrado' }, { status: 404, statusText: 'Not Found' });
    expect(await inexistente).toBeNull();
  });

  it('deve ler o percentual de comissão e o saldo de cashback', async () => {
    const percentual = firstValueFrom(api.consultarPercentualComissao('0003'));
    http.expectOne(`${API_URL}/funcionarios/0003/comissao`).flush({ percentual: 1.5 });
    expect(await percentual).toBe(1.5);

    const saldo = firstValueFrom(api.consultarCashback('32970069865'));
    http.expectOne(`${API_URL}/clientes/32970069865/cashback`).flush({ saldo: 25.5 });
    expect(await saldo).toBe(25.5);
  });

  it('deve buscar produto pelo termo na query string', async () => {
    const variacao = firstValueFrom(api.buscarVariacao(' 12345/42 '));
    const requisicao = http.expectOne((r) => r.url === `${API_URL}/produtos/variacoes/busca`);
    expect(requisicao.request.params.get('termo')).toBe('12345/42');
    requisicao.flush({ id: 1 });
    expect((await variacao)?.id).toBe(1);
  });

  it('deve usar POST para cliente novo e PUT para cliente existente', () => {
    const novo: Cliente = { id: null, cpf: '11144477735', nome: 'JOANA', email: null, telefone: null };
    api.salvarCliente(novo).subscribe();
    expect(http.expectOne(`${API_URL}/clientes`).request.method).toBe('POST');

    api.salvarCliente({ ...novo, id: 7 }).subscribe();
    expect(http.expectOne(`${API_URL}/clientes/7`).request.method).toBe('PUT');
  });

  it('deve mostrar a mensagem do backend quando a venda é recusada', async () => {
    const resultado = firstValueFrom(api.registrarVenda({} as Venda));
    http.expectOne(`${API_URL}/vendas`).flush(
      { mensagem: 'Ainda há valor restante a pagar.' },
      { status: 400, statusText: 'Bad Request' },
    );
    await expect(resultado).rejects.toThrow('Ainda há valor restante a pagar.');
  });

  it('deve avisar quando o backend está desligado', async () => {
    const resultado = firstValueFrom(api.listarFormasPagamento());
    http.expectOne(`${API_URL}/formas-pagamento`).error(new ProgressEvent('error'), { status: 0 });
    await expect(resultado).rejects.toThrow('Sem conexão com o servidor');
  });

  it('deve mandar só os filtros preenchidos e usar PATCH no cancelamento', () => {
    api.listarVendas({ de: '2026-10-01', ate: '', prontuario: '0001' }).subscribe();
    const lista = http.expectOne((r) => r.url === `${API_URL}/vendas`);
    expect(lista.request.params.keys()).toEqual(['de', 'prontuario']);
    lista.flush([]);

    api.resumoComissoes({ de: '2026-10-01', ate: '2026-10-31' }).subscribe();
    http.expectOne(`${API_URL}/comissoes?de=2026-10-01&ate=2026-10-31`).flush([]);

    api.cancelarVenda(5).subscribe();
    expect(http.expectOne(`${API_URL}/vendas/5/cancelamento`).request.method).toBe('PATCH');
  });
});
