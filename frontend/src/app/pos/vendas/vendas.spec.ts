import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { Vendas } from './vendas';

describe('Vendas', () => {
  let component: Vendas;
  let fixture: ComponentFixture<Vendas>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Vendas],
      providers: [provideRouter([])]
    })
    .compileComponents();

    fixture = TestBed.createComponent(Vendas);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve exibir o menu do módulo de vendas', () => {
    const links = (fixture.nativeElement as HTMLElement).querySelectorAll('.vx-menu a');
    expect(Array.from(links).map((a) => a.textContent?.trim())).toEqual([
      'Nova venda',
      'Consulta',
      'Painel de vendas',
    ]);
  });

  it('deve carregar as fontes do design uma única vez', () => {
    TestBed.createComponent(Vendas);
    expect(document.querySelectorAll('link[data-vx-fontes]').length).toBe(1);
  });
});
