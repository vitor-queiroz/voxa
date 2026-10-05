import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { Pdv } from './pdv';
import { VendaService } from '../venda.service';

describe('Pdv', () => {
  let component: Pdv;
  let fixture: ComponentFixture<Pdv>;
  let vendaService: VendaService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Pdv],
      providers: [provideRouter([])]
    })
    .compileComponents();

    vendaService = TestBed.inject(VendaService);
    fixture = TestBed.createComponent(Pdv);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('deve preencher o vendedor pelo código', () => {
    component.codigoVendedor = '0ga8';
    component.buscarVendedor();
    expect(vendaService.rascunho().vendedor?.nome).toBe('ORLANDO A');

    component.codigoVendedor = 'XXXX';
    component.buscarVendedor();
    expect(component.erroVendedor()).toBe('Vendedor não encontrado.');
  });

  it('deve validar o CPF e buscar o cliente cadastrado', () => {
    component.alterarCpf('32970069865');

    expect(component.cpf()).toBe('329.700.698-65');
    expect(component.estadoCpf()).toBe('valido');
    expect(vendaService.rascunho().cliente?.nome).toBe('ALEX CAMARGO');
  });

  it('deve avisar quando o CPF é válido mas não está cadastrado', () => {
    component.alterarCpf('11144477735');

    expect(vendaService.rascunho().cliente).toBeNull();
    expect(component.clienteNaoCadastrado()).toBe(true);
  });

  it('deve incluir produto por REF/TAM e mostrar erro para código inexistente', () => {
    component.termoProduto = '12345/42';
    component.incluirProduto();
    expect(vendaService.rascunho().itens.length).toBe(1);
    expect(component.termoProduto).toBe('');
    expect(component.itemVisualizado()?.variacao.id).toBe(1);

    component.termoProduto = '00000';
    component.incluirProduto();
    expect(component.erroProduto()).toContain('não encontrado');
  });

  it('deve alterar o valor do item e aplicar desconto total pelas janelas', () => {
    component.termoProduto = '12345142';
    component.incluirProduto();

    component.abrirDialogo({ tipo: 'valor-item', indice: 0 });
    component.aoAlterarValorItem(0, { tipo: 'VALOR', valor: 300 });
    expect(component.dialogo()).toBeNull();

    component.aoAplicarDesconto({ tipo: 'PERCENTUAL', valor: 10 });
    expect(vendaService.total()).toBe(270);
  });

  it('deve ignorar os atalhos enquanto houver janela aberta', () => {
    component.abrirDialogo({ tipo: 'desconto' });
    component.executar('novo-cliente');

    expect(component.dialogo()?.tipo).toBe('desconto');
  });

  it('não deve ir para o pagamento sem vendedor', () => {
    component.termoProduto = '12345/42';
    component.incluirProduto();

    component.irParaPagamento();

    expect(component.erroVendedor()).toContain('Informe o vendedor');
  });
});
