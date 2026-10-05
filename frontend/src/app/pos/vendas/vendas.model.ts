/*
 * Modelos do módulo de vendas.
 * Os nomes e tipos seguem o contrato esperado do backend (ver README.md).
 */

/*Produto "pai" (entidade Produto do backend)*/
export interface Produto {
  id: number;
  referencia: string;
  nome: string;
  marca: string;
}

/*Variação vendável do produto: tamanho/cor (entidade ProdutoVariacao do backend)*/
export interface ProdutoVariacao {
  id: number;
  produto: Produto;
  codigoBarras: string;
  tamanho: string;
  cor: string;
  preco: number;
  imagemUrl: string | null;
}

export interface Vendedor {
  codigo: string;
  nome: string;
  email: string | null;
  telefone: string | null;
}

export interface Cliente {
  id: number | null; /*null = cliente ainda não cadastrado no backend*/
  cpf: string; /*somente números*/
  nome: string;
  email: string | null;
  telefone: string | null;
}

export interface ItemVenda {
  variacao: ProdutoVariacao;
  quantidade: number;
  precoOriginal: number; /*preço de cadastro da variação*/
  precoUnitario: number; /*preço praticado (pode ter sido alterado no PDV)*/
}

export type TipoDesconto = 'PERCENTUAL' | 'VALOR';

/*Desconto aplicado sobre o subtotal da venda inteira*/
export interface DescontoGeral {
  tipo: TipoDesconto;
  valor: number; /*percentual (0-100) ou valor em R$, conforme o tipo*/
}

export interface FormaPagamento {
  id: string;
  descricao: string;
  valorMinimo: number;
  maxParcelas: number;
  permiteTroco: boolean; /*só dinheiro aceita valor acima do restante*/
}

export interface PagamentoVenda {
  forma: FormaPagamento;
  valor: number;
  parcelas: number;
}

/*Venda que está sendo montada no PDV, antes de finalizar*/
export interface RascunhoVenda {
  vendedor: Vendedor | null;
  cliente: Cliente | null;
  itens: ItemVenda[];
  desconto: DescontoGeral | null;
  cashback: number; /*valor de cashback resgatado pelo cliente*/
  pagamentos: PagamentoVenda[];
}

export type StatusVenda = 'FINALIZADA' | 'CANCELADA';

/*Venda registrada. "numero" e "data" são definidos pelo backend*/
export interface Venda {
  numero: number | null;
  data: string | null; /*ISO 8601*/
  vendedor: Vendedor;
  cliente: Cliente | null;
  itens: ItemVenda[];
  subtotal: number;
  desconto: DescontoGeral | null;
  valorDesconto: number;
  cashback: number;
  total: number;
  pagamentos: PagamentoVenda[];
  troco: number;
  status: StatusVenda;
}
