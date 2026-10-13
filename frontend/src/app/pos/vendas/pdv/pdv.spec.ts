import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { Pdv } from './pdv';
import { VendaService } from '../venda.service';
import { provideVendasApiMock } from '../vendas-api.mock';

describe('Pdv', () => {
  let component: Pdv;
  let fixture: ComponentFixture<Pdv>;
  let vendaService: VendaService;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [Pdv],
      providers: [provideRouter([]), provideVendasApiMock()]
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


  it('deve validar o CPF e buscar o cliente cadastrado', () => {
    component.alterarCpf('32970069865');

    expect(component.cpf()).toBe('329.700.698-65');
    expect(component.estadoCpf()).toBe('valido');
    expect(vendaService.rascunho().cliente?.nome).toBe('ALEX CAMARGO');
  });

  it('deve avisar CPF inválido na hora e CPF incompleto ao sair do campo', () => {
    component.alterarCpf('32970069864');
    expect(component.avisoCpf()).toContain('CPF inválido');

    component.alterarCpf('3297006');
    expect(component.avisoCpf()).toBeNull(); // ainda digitando
    component.cpfTocado.set(true);
    expect(component.avisoCpf()).toBe('CPF incompleto: faltam 4 dígitos.');

    component.alterarCpf('');
    expect(component.avisoCpf()).toBeNull(); // vazio = consumidor final
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

    expect(component.ultimoItem()?.variacao.codigoBarras).toBe('12345142');

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

  it('deve remover a linha selecionada com a tecla Del', () => {
    component.termoProduto = '12345/42';
    component.incluirProduto();
    component.indiceSelecionado.set(0);

    document.body.dispatchEvent(new KeyboardEvent('keydown', { key: 'Delete', bubbles: true }));

    expect(vendaService.rascunho().itens.length).toBe(0);
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

    expect(component.erroPagamento()).toContain('prontuário do vendedor');
  });
});
