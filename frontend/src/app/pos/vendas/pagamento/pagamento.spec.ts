import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { Pagamento } from './pagamento';
import { VendaService } from '../venda.service';
import { FUNCIONARIOS_MOCK, VARIACOES_MOCK } from '../vendas.mock';
import { provideVendasApiMock } from '../vendas-api.mock';

describe('Pagamento', () => {
  let component: Pagamento;
  let fixture: ComponentFixture<Pagamento>;
  let vendaService: VendaService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Pagamento],
      providers: [provideRouter([]), provideVendasApiMock()]
    })
    .compileComponents();

    vendaService = TestBed.inject(VendaService);
    fixture = TestBed.createComponent(Pagamento);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve carregar as formas de pagamento', () => {
    expect(component.formas().length).toBeGreaterThan(0);
  });

  it('deve sugerir o valor restante ao selecionar a forma de pagamento', () => {
    vendaService.incluirItem(VARIACOES_MOCK[0]);
    component.selecionarForma(component.formas()[0]);

    expect(component.valor).toBe(349.9);
  });

  it('não deve permitir finalizar sem o prontuário do vendedor', () => {
    vendaService.incluirItem(VARIACOES_MOCK[0]);
    component.selecionarForma(component.formas()[0]);
    component.incluirPagamento();

    expect(component.acoes().find((a) => a.id === 'finalizar')?.desabilitada).toBe(true);
    component.finalizar();
    expect(component.erro()).toBe('Informe o prontuário do vendedor.');
  });

  it('deve registrar a venda com a comissão e iniciar um rascunho novo', () => {
    vendaService.definirVendedor(FUNCIONARIOS_MOCK[0], 3);
    vendaService.incluirItem(VARIACOES_MOCK[0]);
    component.selecionarForma(component.formas()[0]);
    component.incluirPagamento();
    component.finalizar();

    expect(component.vendaFinalizada()?.numero).toBe(7);
    expect(component.vendaFinalizada()?.valorComissao).toBe(10.5);
    expect(vendaService.rascunho().itens.length).toBe(0);
  });
});
