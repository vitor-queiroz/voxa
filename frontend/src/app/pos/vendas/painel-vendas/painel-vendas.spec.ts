import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PainelVendas } from './painel-vendas';
import { provideVendasApiMock } from '../vendas-api.mock';

describe('PainelVendas', () => {
  let component: PainelVendas;
  let fixture: ComponentFixture<PainelVendas>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PainelVendas],
      providers: [provideVendasApiMock()]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PainelVendas);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('não deve mostrar comissão em nenhum lugar da tela', () => {
    const texto = ((fixture.nativeElement as HTMLElement).textContent ?? '').toLowerCase();
    expect(texto).not.toContain('comiss');
  });

  it('deve listar as vendas do período com vendedor e valor', () => {
    expect(component.vendas().length).toBe(6);
    const linhas = (fixture.nativeElement as HTMLElement).querySelectorAll('section:last-of-type tbody tr');
    expect(linhas[0].textContent).toContain('Mariana Souza');
    expect(linhas[0].textContent).toContain('309'); // valor da venda nº 6: R$ 309,70
  });

  it('deve somar só as vendas finalizadas nos indicadores', () => {
    // 6 vendas de exemplo, 1 cancelada
    expect(component.totais().vendas).toBe(5);
    expect(component.totais().canceladas).toBe(1);
  });

  it('deve filtrar pelo vendedor ao clicar na linha e mostrar todos ao clicar de novo', () => {
    component.filtrarVendedor('0001');
    expect(component.vendas().every((v) => v.vendedor.prontuario === '0001')).toBe(true);
    expect(component.vendas().length).toBe(3);

    component.filtrarVendedor('0001');
    expect(component.vendas().length).toBe(6);
  });

  it('deve filtrar pela situação', () => {
    component.situacao.set('CANCELADA');
    expect(component.vendas().length).toBe(1);
  });

  it('deve trazer todos os funcionários no resumo, com o maior total vendido primeiro', () => {
    const ranking = component.ranking();
    expect(ranking.length).toBe(4);
    for (let i = 1; i < ranking.length; i++) {
      expect(ranking[i - 1].totalVendido).toBeGreaterThanOrEqual(ranking[i].totalVendido);
    }
  });

  it('deve recarregar ao mudar o período', () => {
    component.escolherPeriodo('hoje');
    expect(component.de()).toBe(component.ate());
    expect(component.totais().vendas).toBe(0);
  });
});
