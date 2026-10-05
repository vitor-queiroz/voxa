import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ConsultaVendas } from './consulta-vendas';
import { VendasApiService } from '../vendas-api.service';
import { Venda } from '../vendas.model';
import { VENDEDORES_MOCK } from '../vendas.mock';

describe('ConsultaVendas', () => {
  let component: ConsultaVendas;
  let fixture: ComponentFixture<ConsultaVendas>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ConsultaVendas]
    })
    .compileComponents();

    const venda = { vendedor: VENDEDORES_MOCK[0], cliente: null, itens: [], pagamentos: [], total: 10 } as unknown as Venda;
    TestBed.inject(VendasApiService).registrarVenda(venda).subscribe();

    fixture = TestBed.createComponent(ConsultaVendas);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve filtrar as vendas pelo nome do vendedor', () => {
    component.filtroTexto.set('orlando');
    expect(component.vendasFiltradas().length).toBe(1);

    component.filtroTexto.set('mariana');
    expect(component.vendasFiltradas().length).toBe(0);
  });

  it('deve cancelar a venda e recarregar a lista', () => {
    vi.spyOn(window, 'confirm').mockReturnValue(true);

    component.cancelarVenda(component.vendas()[0]);

    expect(component.vendas()[0].status).toBe('CANCELADA');
    expect(component.totalFinalizado()).toBe(0);
  });
});
