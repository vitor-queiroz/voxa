import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LancamentoProdutos } from './lancamento-produtos';

describe('LancamentoProdutos', () => {
  let component: LancamentoProdutos;
  let fixture: ComponentFixture<LancamentoProdutos>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LancamentoProdutos],
    }).compileComponents();

    fixture = TestBed.createComponent(LancamentoProdutos);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
