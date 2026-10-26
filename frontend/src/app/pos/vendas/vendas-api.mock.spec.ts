import { TestBed } from '@angular/core/testing';
import { firstValueFrom } from 'rxjs';
import { VendasApiService } from './vendas-api.service';
import { provideVendasApiMock } from './vendas-api.mock';
import { Venda } from './vendas.model';
import { FUNCIONARIOS_MOCK } from './vendas.mock';

describe('VendasApiMockService', () => {
  let api: VendasApiService;

  beforeEach(() => {
    TestBed.configureTestingModule({ providers: [provideVendasApiMock()] });
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

  it('deve numerar depois das vendas existentes, listar e cancelar', async () => {
    const venda = { numero: null, data: null, status: 'FINALIZADA', vendedor: FUNCIONARIOS_MOCK[1] } as Venda;

    const registrada = await firstValueFrom(api.registrarVenda(venda));
    expect(registrada.numero).toBe(7);

    await firstValueFrom(api.cancelarVenda(7));
    expect((await firstValueFrom(api.listarVendas()))[0].status).toBe('CANCELADA');
  });

  it('deve filtrar as vendas por prontuário e período', async () => {
    const doCarlos = await firstValueFrom(api.listarVendas({ prontuario: '0001' }));
    expect(doCarlos.length).toBe(3);
    expect(doCarlos.every((v) => v.vendedor.prontuario === '0001')).toBe(true);

    const amanha = new Date();
    amanha.setDate(amanha.getDate() + 1);
    const futuro = amanha.toISOString().slice(0, 10);
    expect(await firstValueFrom(api.listarVendas({ de: futuro }))).toEqual([]);
  });

  it('deve resumir as vendas por prontuário sem comissão e sem contar canceladas', async () => {
    const resumo = await firstValueFrom(api.resumoVendedores());
    const carlos = resumo.find((r) => r.vendedor.prontuario === '0001')!;
    const ana = resumo.find((r) => r.vendedor.prontuario === '0004')!;

    expect(resumo.length).toBe(4);
    expect(carlos.quantidadeVendas).toBe(2);
    expect(carlos.totalVendido).toBe(729.7);
    expect(carlos).not.toHaveProperty('valorComissao');
    expect(ana.quantidadeVendas).toBe(0);
  });

  it('deve buscar funcionário pelo prontuário', async () => {
    expect((await firstValueFrom(api.buscarFuncionario('0001')))?.nome).toBe('Carlos Eduardo Silva');
    expect(await firstValueFrom(api.buscarFuncionario('9999'))).toBeNull();
  });
});
