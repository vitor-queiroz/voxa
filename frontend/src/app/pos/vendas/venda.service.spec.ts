import { TestBed } from '@angular/core/testing';
import { VendaService, normalizarProntuario, podeVender } from './venda.service';
import { FORMAS_PAGAMENTO_MOCK, FUNCIONARIOS_MOCK, VARIACOES_MOCK } from './vendas.mock';
import { Venda } from './vendas.model';

const [tenis42, , camisetaM] = VARIACOES_MOCK; // 349,90 e 59,90
const [dinheiro, pix, debito, , credito] = FORMAS_PAGAMENTO_MOCK; // débito POS e crédito POS
const carlos = FUNCIONARIOS_MOCK[0];
const afastada = FUNCIONARIOS_MOCK[3];

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

  it('monta a venda somente com vendedor e pagamento completo, sem comissão', () => {
    service.incluirItem(tenis42);
    expect(service.montarVenda()).toBe('Informe o prontuário do vendedor.');

    service.definirVendedor(carlos);
    expect(service.montarVenda()).toBe('Ainda há valor restante a pagar.');

    service.adicionarPagamento(credito, 349.9, 3);
    const venda = service.montarVenda() as Venda;

    expect(venda.total).toBe(349.9);
    expect(venda.numero).toBeNull();
    expect(venda.vendedor.prontuario).toBe('0001');
    expect(venda).not.toHaveProperty('percentualComissao'); // comissão é só do backend
    expect(venda).not.toHaveProperty('valorComissao');
  });


  it('não finaliza com funcionário que não está trabalhando', () => {
    service.incluirItem(camisetaM);
    service.definirVendedor(afastada);
    service.adicionarPagamento(dinheiro, 59.9);

    expect(service.montarVenda()).toContain('Afastado');
  });

  it('nova venda limpa o rascunho mas mantém o vendedor', () => {
    service.definirVendedor(carlos);
    service.incluirItem(tenis42);

    service.novaVenda();

    expect(service.rascunho().itens.length).toBe(0);
    expect(service.rascunho().vendedor?.prontuario).toBe('0001');
  });

  it('completa o prontuário com zeros e verifica a situação', () => {
    expect(normalizarProntuario(' 1 ')).toBe('0001');
    expect(normalizarProntuario('12345')).toBe('12345');
    expect(podeVender(carlos)).toBe(true);
    expect(podeVender(afastada)).toBe(false);
  });

  it('atualiza a foto em todos os itens do mesmo produto e cor', () => {
    const [, tenis40] = VARIACOES_MOCK;
    service.incluirItem(tenis42);
    service.incluirItem(tenis40);
    service.incluirItem(camisetaM);

    service.atualizarFoto({ ...tenis42, imagemUrl: '/produtos/imagens/7' });

    const fotos = service.rascunho().itens.map((i) => i.variacao.imagemUrl);
    expect(fotos).toEqual(['/produtos/imagens/7', '/produtos/imagens/7', null]);
  });
});
