import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { Pagamento } from './pagamento';
import { VendaService } from '../venda.service';
import { VARIACOES_MOCK, VENDEDORES_MOCK } from '../vendas.mock';

describe('Pagamento', () => {
  let component: Pagamento;
  let fixture: ComponentFixture<Pagamento>;
  let vendaService: VendaService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Pagamento],
      providers: [provideRouter([])]
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

  it('deve registrar a venda e iniciar um rascunho novo', () => {
    vendaService.definirVendedor(VENDEDORES_MOCK[0]);
    vendaService.incluirItem(VARIACOES_MOCK[0]);
    component.selecionarForma(component.formas()[0]);
    component.incluirPagamento();
    component.finalizar();

    expect(component.vendaFinalizada()?.numero).toBe(1);
    expect(vendaService.rascunho().itens.length).toBe(0);
  });
});
