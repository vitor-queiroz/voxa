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

  it('deve exibir as abas do módulo de vendas', () => {
    const abas = (fixture.nativeElement as HTMLElement).querySelectorAll('.vx-abas a');
    expect(abas.length).toBe(2);
  });
});
