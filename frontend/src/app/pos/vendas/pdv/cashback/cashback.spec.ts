import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CashbackDialogo } from './cashback';
import { CLIENTES_MOCK } from '../../vendas.mock';

describe('CashbackDialogo', () => {
  let component: CashbackDialogo;
  let fixture: ComponentFixture<CashbackDialogo>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [CashbackDialogo]
    })
    .compileComponents();

    fixture = TestBed.createComponent(CashbackDialogo);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('cliente', CLIENTES_MOCK[0]); // saldo 25,50
    fixture.componentRef.setInput('totalVenda', 20);
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve limitar o disponível ao total da venda', () => {
    expect(component.saldo()).toBe(25.5);
    expect(component.disponivel()).toBe(20);
  });

  it('deve recusar resgate acima do disponível e emitir o valor válido', () => {
    let resgatado: number | undefined;
    component.resgatar.subscribe((v) => (resgatado = v));

    component.valorResgate = 21;
    component.confirmar();
    expect(component.erro()).toContain('acima');

    component.valorResgate = 15;
    component.confirmar();
    expect(resgatado).toBe(15);
  });
});
