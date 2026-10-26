import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Etapas } from './etapas';

describe('Etapas', () => {
  let component: Etapas;
  let fixture: ComponentFixture<Etapas>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Etapas]
    })
    .compileComponents();

    fixture = TestBed.createComponent(Etapas);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('atual', 2);
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve marcar as etapas feitas e a atual', () => {
    const itens = (fixture.nativeElement as HTMLElement).querySelectorAll('li');
    expect(itens[0].classList).toContain('feita');
    expect(itens[1].classList).toContain('atual');
    expect(itens[1].getAttribute('aria-current')).toBe('step');
    expect(itens[2].className).toBe('');
  });
});
