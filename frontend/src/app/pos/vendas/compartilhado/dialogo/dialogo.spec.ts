import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Dialogo } from './dialogo';

describe('Dialogo', () => {
  let component: Dialogo;
  let fixture: ComponentFixture<Dialogo>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Dialogo]
    })
    .compileComponents();

    fixture = TestBed.createComponent(Dialogo);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('titulo', 'Teste');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve fechar pelo botão, pelo fundo e pela tecla Esc', () => {
    let fechamentos = 0;
    component.fechar.subscribe(() => fechamentos++);
    const elemento = fixture.nativeElement as HTMLElement;

    elemento.querySelector<HTMLButtonElement>('.fechar')?.click();
    elemento.querySelector<HTMLElement>('.fundo')?.click();
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape' }));

    expect(fechamentos).toBe(3);
  });
});
