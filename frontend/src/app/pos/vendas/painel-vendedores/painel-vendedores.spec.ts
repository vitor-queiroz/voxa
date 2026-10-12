import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PainelVendedores } from './painel-vendedores';
import { provideVendasApiMock } from '../vendas-api.mock';

describe('PainelVendedores', () => {
  let component: PainelVendedores;
  let fixture: ComponentFixture<PainelVendedores>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PainelVendedores],
      providers: [provideVendasApiMock()]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PainelVendedores);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve listar todos os funcionários, com o maior total vendido primeiro', () => {
    const ranking = component.ranking();
    expect(ranking.length).toBe(4);
    for (let i = 1; i < ranking.length; i++) {
      expect(ranking[i - 1].totalVendido).toBeGreaterThanOrEqual(ranking[i].totalVendido);
    }
  });

  it('não deve contar vendas canceladas na comissão', () => {
    const carlos = component.ranking().find((l) => l.vendedor.prontuario === '0001')!;
    // vendas de exemplo do Carlos: nº 5 (349,90) e nº 2 (379,80); a nº 3 está cancelada
    expect(carlos.quantidadeVendas).toBe(2);
    expect(carlos.totalVendido).toBe(729.7);
    expect(carlos.valorComissao).toBeCloseTo(21.89, 2);
  });

  it('deve filtrar só quem está trabalhando', () => {
    component.somenteAtivos.set(true);
    expect(component.ranking().some((l) => l.vendedor.prontuario === '0004')).toBe(false);
  });

  it('deve mostrar as vendas do vendedor selecionado, inclusive canceladas', () => {
    component.selecionar('0001');

    expect(component.selecionado()?.vendedor.nome).toBe('Carlos Eduardo Silva');
    expect(component.vendasDoVendedor().length).toBe(3);
  });

  it('deve recalcular ao mudar o período', () => {
    component.escolherPeriodo('hoje');
    expect(component.totais().vendas).toBe(0);
    expect(component.de()).toBe(component.ate());
  });
});
