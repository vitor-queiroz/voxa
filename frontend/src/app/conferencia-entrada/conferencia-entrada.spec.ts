import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ConferenciaEntrada } from './conferencia-entrada';

describe('ConferenciaEntrada', () => {
  let component: ConferenciaEntrada;
  let fixture: ComponentFixture<ConferenciaEntrada>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ConferenciaEntrada],
    }).compileComponents();

    fixture = TestBed.createComponent(ConferenciaEntrada);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
