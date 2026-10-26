import { ComponentFixture, TestBed } from '@angular/core/testing';

import { AjusteValor, AjusteValorDialogo } from './ajuste-valor';

describe('AjusteValorDialogo', () => {
  let component: AjusteValorDialogo;
  let fixture: ComponentFixture<AjusteValorDialogo>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AjusteValorDialogo]
    })
    .compileComponents();

    fixture = TestBed.createComponent(AjusteValorDialogo);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('titulo', 'Alterar valor');
    fixture.componentRef.setInput('valorAtual', 349.9);
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve iniciar com o valor atual e emitir o ajuste ao confirmar', () => {
    let ajuste: AjusteValor | undefined;
    component.confirmar.subscribe((a) => (ajuste = a));

    expect(component.valor).toBe(349.9);
    component.valor = 300;
    component.enviar();

    expect(ajuste).toEqual({ tipo: 'VALOR', valor: 300 });
  });

  it('deve mostrar a escolha R$ / % somente quando permitido', async () => {
    const elemento = fixture.nativeElement as HTMLElement;
    expect(elemento.querySelector('.tipos')).toBeNull();

    fixture.componentRef.setInput('permitirPercentual', true);
    await fixture.whenStable();

    expect(elemento.querySelector('.tipos')).not.toBeNull();
  });
});
