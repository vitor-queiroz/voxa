import { ComponentFixture, TestBed } from '@angular/core/testing';

import { VendedorProntuario } from './vendedor-prontuario';
import { VendaService } from '../../venda.service';
import { provideVendasApiMock } from '../../vendas-api.mock';

describe('VendedorProntuario', () => {
  let component: VendedorProntuario;
  let fixture: ComponentFixture<VendedorProntuario>;
  let vendaService: VendaService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [VendedorProntuario],
      providers: [provideVendasApiMock()]
    })
    .compileComponents();

    vendaService = TestBed.inject(VendaService);
    fixture = TestBed.createComponent(VendedorProntuario);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve completar o prontuário e vincular o vendedor, sem mostrar comissão', () => {
    component.prontuario = '1';
    component.buscar();

    expect(component.prontuario).toBe('0001');
    expect(vendaService.rascunho().vendedor?.nome).toBe('Carlos Eduardo Silva');
    fixture.detectChanges();
    expect((fixture.nativeElement as HTMLElement).textContent).not.toContain('Comissão');
  });

  it('não deve vincular funcionário afastado', () => {
    component.prontuario = '0004';
    component.buscar();

    expect(component.bloqueado()).toBe(true);
    expect(vendaService.rascunho().vendedor).toBeNull();
  });

  it('deve avisar quando o prontuário não existe', () => {
    component.prontuario = '9999';
    component.buscar();

    expect(component.erro()).toContain('não encontrado');
  });

  it('só deve sugerir funcionários que estão trabalhando', () => {
    expect(component.funcionarios().map((f) => f.prontuario)).not.toContain('0004');
  });
});
