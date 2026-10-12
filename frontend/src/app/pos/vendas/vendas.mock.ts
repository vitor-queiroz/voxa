import { Cliente, FormaPagamento, Funcionario, ProdutoVariacao, Venda } from './vendas.model';

/*
 * DADOS DE EXEMPLO — usados enquanto o backend não tem os endpoints de vendas.
 * Somente o VendasApiService usa este arquivo. Quando a integração estiver pronta, ele pode ser apagado.
 */

/*Mesmo formato da tabela "funcionario" (prontuário 0001 é o cadastrado no banco)*/
export const FUNCIONARIOS_MOCK: Funcionario[] = [
  { prontuario: '0001', nome: 'Carlos Eduardo Silva', funcao: 'Vendedor', situacao: 'Trabalhando' },
  { prontuario: '0002', nome: 'Mariana Souza', funcao: 'Vendedora', situacao: 'Trabalhando' },
  { prontuario: '0003', nome: 'João Pereira', funcao: 'Gerente', situacao: 'Trabalhando' },
  { prontuario: '0004', nome: 'Ana Lima', funcao: 'Vendedora', situacao: 'Afastado' },
];

/*Percentual de comissão por prontuário (padrão 3%)*/
export const PERCENTUAL_COMISSAO_PADRAO = 3;
export const COMISSAO_MOCK: Record<string, number> = { '0003': 1.5 };

export const CLIENTES_MOCK: Cliente[] = [
  { id: 1, cpf: '32970069865', nome: 'ALEX CAMARGO', email: 'alex@email.com', telefone: '(11) 97777-2001' },
  { id: 2, cpf: '52998224725', nome: 'BEATRIZ LIMA', email: null, telefone: '(21) 97777-2002' },
];

/*Saldo de cashback por CPF*/
export const CASHBACK_MOCK: Record<string, number> = {
  '32970069865': 25.5,
  '52998224725': 0,
};

const nikeZoom = { id: 1, referencia: '12345', nome: 'Tênis Nike Zoom Fly', marca: 'Nike' };
const camiseta = { id: 2, referencia: '20010', nome: 'Camiseta Básica Algodão', marca: 'VOXA' };
const calca = { id: 3, referencia: '30020', nome: 'Calça Jeans Slim', marca: 'VOXA' };

export const VARIACOES_MOCK: ProdutoVariacao[] = [
  { id: 1, produto: nikeZoom, codigoBarras: '12345142', tamanho: '42', cor: 'Preto', preco: 349.9, imagemUrl: null },
  { id: 2, produto: nikeZoom, codigoBarras: '12345140', tamanho: '40', cor: 'Preto', preco: 349.9, imagemUrl: null },
  { id: 3, produto: camiseta, codigoBarras: '20010001', tamanho: 'M', cor: 'Branca', preco: 59.9, imagemUrl: null },
  { id: 4, produto: camiseta, codigoBarras: '20010002', tamanho: 'G', cor: 'Branca', preco: 59.9, imagemUrl: null },
  { id: 5, produto: calca, codigoBarras: '30020040', tamanho: '40', cor: 'Azul', preco: 189.9, imagemUrl: null },
];

export const FORMAS_PAGAMENTO_MOCK: FormaPagamento[] = [
  { id: 'DINHEIRO', descricao: 'DINHEIRO', valorMinimo: 0, maxParcelas: 1, permiteTroco: true },
  { id: 'PIX', descricao: 'PIX', valorMinimo: 0.3, maxParcelas: 1, permiteTroco: false },
  { id: 'DEBITO', descricao: 'CARTÃO DÉBITO', valorMinimo: 0, maxParcelas: 1, permiteTroco: false },
  { id: 'CREDITO', descricao: 'CARTÃO CRÉDITO', valorMinimo: 0, maxParcelas: 10, permiteTroco: false },
];

/*Algumas vendas antigas, para a consulta e o painel não começarem vazios*/
export function vendasIniciaisMock(): Venda[] {
  const diasAtras = (dias: number, hora: number) => {
    const data = new Date();
    data.setDate(data.getDate() - dias);
    data.setHours(hora, 15, 0, 0);
    return data.toISOString();
  };
  const [tenis42, tenis40, camisetaM, , calca40] = VARIACOES_MOCK;
  const [dinheiro, pix, , credito] = FORMAS_PAGAMENTO_MOCK;
  const [carlos, mariana, joao] = FUNCIONARIOS_MOCK;

  const montar = (
    numero: number,
    data: string,
    vendedor: Funcionario,
    itens: [ProdutoVariacao, number][],
    forma: FormaPagamento,
    status: Venda['status'] = 'FINALIZADA',
  ): Venda => {
    const total = Math.round(itens.reduce((soma, [v, qtd]) => soma + v.preco * qtd, 0) * 100) / 100;
    const percentualComissao = COMISSAO_MOCK[vendedor.prontuario] ?? PERCENTUAL_COMISSAO_PADRAO;
    return {
      numero,
      data,
      vendedor,
      cliente: null,
      itens: itens.map(([variacao, quantidade]) => ({
        variacao, quantidade, precoOriginal: variacao.preco, precoUnitario: variacao.preco,
      })),
      subtotal: total,
      desconto: null,
      valorDesconto: 0,
      cashback: 0,
      total,
      pagamentos: [{ forma, valor: total, parcelas: 1 }],
      troco: 0,
      percentualComissao,
      valorComissao: Math.round(total * percentualComissao) / 100,
      status,
    };
  };

  return [
    montar(6, diasAtras(1, 16), mariana, [[calca40, 1], [camisetaM, 2]], pix),
    montar(5, diasAtras(2, 11), carlos, [[tenis42, 1]], credito),
    montar(4, diasAtras(3, 15), joao, [[camisetaM, 3]], dinheiro),
    montar(3, diasAtras(5, 10), carlos, [[tenis40, 1], [camisetaM, 1]], pix, 'CANCELADA'),
    montar(2, diasAtras(9, 17), carlos, [[calca40, 2]], dinheiro),
    montar(1, diasAtras(12, 14), mariana, [[tenis42, 1], [tenis40, 1]], credito),
  ];
}
