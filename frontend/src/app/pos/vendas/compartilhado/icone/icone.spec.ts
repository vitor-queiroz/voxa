import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Icone } from './icone';

describe('Icone', () => {
  let component: Icone;
  let fixture: ComponentFixture<Icone>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Icone]
    })
    .compileComponents();

    fixture = TestBed.createComponent(Icone);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('nome', 'carrinho');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve desenhar o ícone no tamanho informado', async () => {
    fixture.componentRef.setInput('tamanho', 32);
    await fixture.whenStable();

    const svg = (fixture.nativeElement as HTMLElement).querySelector('svg');
    expect(svg?.getAttribute('width')).toBe('32');
    expect(svg?.querySelectorAll('circle').length).toBe(2);
  });
});
