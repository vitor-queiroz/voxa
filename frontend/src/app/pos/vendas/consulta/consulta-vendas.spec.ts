import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ConsultaVendas } from './consulta-vendas';
import { provideVendasApiMock } from '../vendas-api.mock';

describe('ConsultaVendas', () => {
  let component: ConsultaVendas;
  let fixture: ComponentFixture<ConsultaVendas>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ConsultaVendas],
      providers: [provideVendasApiMock()]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ConsultaVendas);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve carregar as vendas de exemplo', () => {
    expect(component.vendas().length).toBe(6);
  });

  it('deve filtrar pelo prontuário ou nome do vendedor', () => {
    component.filtroTexto.set('0002');
    expect(component.vendasFiltradas().every((v) => v.vendedor.prontuario === '0002')).toBe(true);

    component.filtroTexto.set('carlos');
    expect(component.vendasFiltradas().length).toBe(3);
  });

  it('deve cancelar a venda e tirar do total finalizado', () => {
    vi.spyOn(window, 'confirm').mockReturnValue(true);
    const venda = component.vendas().find((v) => v.numero === 6)!;
    const totalAntes = component.totalFinalizado();

    component.cancelarVenda(venda);

    expect(component.vendas().find((v) => v.numero === 6)?.status).toBe('CANCELADA');
    expect(component.totalFinalizado()).toBeCloseTo(totalAntes - venda.total, 2);
  });
});
