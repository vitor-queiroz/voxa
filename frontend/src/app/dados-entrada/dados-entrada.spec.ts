import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DadosEntrada } from './dados-entrada';

describe('DadosEntrada', () => {
  let component: DadosEntrada;
  let fixture: ComponentFixture<DadosEntrada>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DadosEntrada],
    }).compileComponents();

    fixture = TestBed.createComponent(DadosEntrada);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
