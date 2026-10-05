import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ResumoVenda } from './resumo-venda';
import { VendaService } from '../../venda.service';
import { VARIACOES_MOCK } from '../../vendas.mock';

describe('ResumoVenda', () => {
  let component: ResumoVenda;
  let fixture: ComponentFixture<ResumoVenda>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ResumoVenda]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ResumoVenda);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve mostrar a linha de cashback somente quando houver resgate', async () => {
    const texto = () => (fixture.nativeElement as HTMLElement).textContent ?? '';
    const vendaService = TestBed.inject(VendaService);
    vendaService.incluirItem(VARIACOES_MOCK[0]);
    await fixture.whenStable();
    expect(texto()).not.toContain('Cashback');

    vendaService.definirCashback(10);
    await fixture.whenStable();
    expect(texto()).toContain('Cashback');
  });
});
