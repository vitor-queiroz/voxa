import { TestBed } from '@angular/core/testing';
import { VendaService } from './venda.service';
import { FORMAS_PAGAMENTO_MOCK, VARIACOES_MOCK, VENDEDORES_MOCK } from './vendas.mock';
import { Venda } from './vendas.model';

const [tenis42, , camisetaM] = VARIACOES_MOCK; // 349,90 e 59,90
const [dinheiro, pix, debito, credito] = FORMAS_PAGAMENTO_MOCK;

describe('VendaService', () => {
  let service: VendaService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(VendaService);
  });

  it('cada inclusão gera uma linha nova e soma no subtotal', () => {
    service.incluirItem(tenis42);
    service.incluirItem(tenis42);

    expect(service.rascunho().itens.length).toBe(2);
    expect(service.subtotal()).toBe(699.8);
  });

  it('altera quantidade e preço de um item', () => {
    service.incluirItem(camisetaM);

    expect(service.alterarQuantidade(0, 0)).toBe('Quantidade inválida.');
    expect(service.alterarQuantidade(0, 3)).toBeNull();
    expect(service.alterarPrecoItem(0, 50)).toBeNull();

    expect(service.rascunho().itens[0].precoOriginal).toBe(59.9);
    expect(service.subtotal()).toBe(150);
  });

  it('aplica desconto geral em percentual ou em valor', () => {
    service.incluirItem(tenis42);

    service.definirDesconto({ tipo: 'PERCENTUAL', valor: 10 });
    expect(service.valorDesconto()).toBe(34.99);
    expect(service.total()).toBe(314.91);

    service.definirDesconto({ tipo: 'VALOR', valor: 49.9 });
    expect(service.total()).toBe(300);

    expect(service.definirDesconto({ tipo: 'VALOR', valor: 1000 })).toContain('maior que o subtotal');
    expect(service.definirDesconto({ tipo: 'PERCENTUAL', valor: 120 })).toContain('100%');
  });

  it('desconta o cashback e zera ao trocar de cliente', () => {
    service.incluirItem(camisetaM);
    service.definirCashback(10);
    expect(service.total()).toBe(49.9);

    service.definirCliente(null);
    expect(service.cashback()).toBe(0);
  });

  it('só permite troco em dinheiro e valida parcelas', () => {
    service.incluirItem(camisetaM);

    expect(service.adicionarPagamento(pix, 60)).toContain('não permite');
    expect(service.adicionarPagamento(debito, 59.9, 2)).toContain('parcela');
    expect(service.adicionarPagamento(dinheiro, 60)).toBeNull();
    expect(service.troco()).toBe(0.1);
  });

  it('monta a venda somente com vendedor e pagamento completo', () => {
    service.incluirItem(tenis42);
    expect(service.montarVenda()).toBe('Informe o vendedor.');

    service.definirVendedor(VENDEDORES_MOCK[0]);
    expect(service.montarVenda()).toBe('Ainda há valor restante a pagar.');

    service.adicionarPagamento(credito, 349.9, 3);
    const venda = service.montarVenda() as Venda;

    expect(venda.total).toBe(349.9);
    expect(venda.numero).toBeNull();
  });

  it('nova venda limpa o rascunho mas mantém o vendedor', () => {
    service.definirVendedor(VENDEDORES_MOCK[0]);
    service.incluirItem(tenis42);

    service.novaVenda();

    expect(service.rascunho().itens.length).toBe(0);
    expect(service.rascunho().vendedor?.codigo).toBe('0GA8');
  });
});
