import { TestBed } from '@angular/core/testing';
import { firstValueFrom } from 'rxjs';
import { VendasApiService } from './vendas-api.service';
import { Venda } from './vendas.model';

describe('VendasApiService', () => {
  let api: VendasApiService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    api = TestBed.inject(VendasApiService);
  });

  it('deve buscar a variação por REF/TAM ou por código de barras', async () => {
    expect((await firstValueFrom(api.buscarVariacao('12345/42')))?.id).toBe(1);
    expect((await firstValueFrom(api.buscarVariacao('12345142')))?.id).toBe(1);
    expect(await firstValueFrom(api.buscarVariacao('99999'))).toBeNull();
  });

  it('deve cadastrar cliente novo e impedir CPF duplicado', async () => {
    const novo = { id: null, cpf: '11144477735', nome: 'NOVO', email: null, telefone: null };

    const salvo = await firstValueFrom(api.salvarCliente(novo));
    expect(salvo.id).not.toBeNull();
    expect((await firstValueFrom(api.buscarClientePorCpf('11144477735')))?.nome).toBe('NOVO');

    await expect(firstValueFrom(api.salvarCliente(novo))).rejects.toThrow('Já existe');
  });

  it('deve numerar, listar e cancelar vendas', async () => {
    const venda = { numero: null, data: null, status: 'FINALIZADA' } as Venda;

    const registrada = await firstValueFrom(api.registrarVenda(venda));
    expect(registrada.numero).toBe(1);

    await firstValueFrom(api.cancelarVenda(1));
    expect((await firstValueFrom(api.listarVendas()))[0].status).toBe('CANCELADA');
  });
});
