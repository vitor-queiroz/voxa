import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BarraAcoes } from './barra-acoes';

describe('BarraAcoes', () => {
  let component: BarraAcoes;
  let fixture: ComponentFixture<BarraAcoes>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BarraAcoes]
    })
    .compileComponents();

    fixture = TestBed.createComponent(BarraAcoes);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('dica', 'F2 vai para o pagamento');
    fixture.componentRef.setInput('acoes', [
      { id: 'pagamento', rotulo: 'Ir para pagamento', tecla: 'F2', estilo: 'primario' },
      { id: 'cancelar', rotulo: 'Cancelar venda', tecla: 'F7', desabilitada: true }
    ]);
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve mostrar a dica e a tecla de atalho de cada ação', () => {
    const elemento = fixture.nativeElement as HTMLElement;
    expect(elemento.querySelector('.dica')?.textContent).toContain('F2 vai para o pagamento');
    expect(elemento.querySelectorAll('kbd').length).toBe(2);
  });

  it('deve acionar a ação pela tecla de atalho, exceto se desabilitada', () => {
    const acionadas: string[] = [];
    component.acionar.subscribe((id) => acionadas.push(id));

    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'F2' }));
    document.dispatchEvent(new KeyboardEvent('keydown', { key: 'F7' }));

    expect(acionadas).toEqual(['pagamento']);
  });
});
