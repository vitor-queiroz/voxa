import { Cliente, FormaPagamento, ProdutoVariacao, Vendedor } from './vendas.model';

/*
 * DADOS DE EXEMPLO — usados enquanto o backend não tem os endpoints de vendas.
 * Somente o VendasApiService usa este arquivo. Quando a integração estiver pronta, ele pode ser apagado.
 */

export const VENDEDORES_MOCK: Vendedor[] = [
  { codigo: '0GA8', nome: 'ORLANDO A', email: 'orlando@voxa.com', telefone: '(11) 98888-1001' },
  { codigo: '0GB2', nome: 'MARIANA S', email: 'mariana@voxa.com', telefone: '(11) 98888-1002' },
  { codigo: '0GC5', nome: 'CARLOS M', email: null, telefone: '(11) 98888-1003' },
];

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
