import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ResumoVenda } from './resumo-venda';
import { VendaService } from '../../venda.service';
import { FORMAS_PAGAMENTO_MOCK, VARIACOES_MOCK } from '../../vendas.mock';

describe('ResumoVenda', () => {
  let component: ResumoVenda;
  let fixture: ComponentFixture<ResumoVenda>;
  let vendaService: VendaService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ResumoVenda]
    })
    .compileComponents();

    vendaService = TestBed.inject(VendaService);
    fixture = TestBed.createComponent(ResumoVenda);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve calcular o progresso do pagamento', () => {
    vendaService.incluirItem(VARIACOES_MOCK[2]); // 59,90
    expect(component.progresso()).toBe(0);

    vendaService.adicionarPagamento(FORMAS_PAGAMENTO_MOCK[1], 29.95);
    expect(component.progresso()).toBe(50);
  });

  it('deve mostrar a linha de cashback somente quando houver resgate', async () => {
    const texto = () => (fixture.nativeElement as HTMLElement).textContent ?? '';
    vendaService.incluirItem(VARIACOES_MOCK[0]);
    await fixture.whenStable();
    expect(texto()).not.toContain('Cashback');

    vendaService.definirCashback(10);
    await fixture.whenStable();
    expect(texto()).toContain('Cashback');
  });
});
