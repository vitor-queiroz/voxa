# Módulo de Vendas (frontend)

Telas de venda do VOXA: **Nova venda (PDV)**, **Pagamento** e **Consulta de vendas**.

> Por enquanto é **somente frontend**. Todos os dados vêm de exemplos em `vendas.mock.ts`.
> Para ligar no backend, só é preciso alterar o `vendas-api.service.ts` (ver [Integração com o backend](#integração-com-o-backend)).

---

## Sumário

1. [Como acessar](#como-acessar)
2. [Estrutura de pastas](#estrutura-de-pastas)
3. [Telas](#telas)
4. [Regras de negócio](#regras-de-negócio)
5. [Integração com o backend](#integração-com-o-backend)
6. [Contrato da API (endpoints)](#contrato-da-api-endpoints)
7. [Entidades sugeridas no backend](#entidades-sugeridas-no-backend)
8. [Dados de exemplo para teste](#dados-de-exemplo-para-teste)
9. [Pendências e decisões em aberto](#pendências-e-decisões-em-aberto)

---

## Como acessar

A rota do módulo é registrada em `app.routes.ts` (ajuste o caminho do `import` se a pasta estiver em outro lugar, ex.: `./pos/vendas/vendas.routes`):

```ts
{
  path: 'vendas',
  loadChildren: () => import('./vendas/vendas.routes').then((m) => m.VENDAS_ROUTES)
}
```

| URL                 | Tela                    |
| ------------------- | ----------------------- |
| `/vendas/pdv`       | Nova venda (PDV)        |
| `/vendas/pagamento` | Pagamento da venda      |
| `/vendas/consulta`  | Consulta de vendas      |

O módulo já configura sozinho o formato brasileiro de moeda e data (`R$ 1.234,56`) em `vendas.routes.ts`.

---

## Estrutura de pastas

Cada componente segue o padrão do Angular CLI: `.ts` (lógica), `.html` (template), `.css` (estilo) e `.spec.ts` (testes).

```
vendas/
├── README.md                  ← este documento
├── vendas.routes.ts           ← rotas do módulo + formato pt-BR
├── vendas.ts/.html/.css/.spec ← tela base (abas) + estilos comuns do módulo
├── vendas.model.ts            ← interfaces (contrato de dados com o backend)
├── vendas-api.service.ts      ← ÚNICO ponto de comunicação com o backend
├── vendas.mock.ts             ← dados de exemplo (apagar após a integração)
├── venda.service.ts           ← estado da venda em andamento + cálculos
├── cpf.ts                     ← validação e máscara de CPF
├── pdv/                       ← tela Nova venda | Ponto de venda
│   ├── ajuste-valor/          ← janela do símbolo de moeda (valor do item / desconto total)
│   ├── cadastro-cliente/      ← janela Novo cliente / Editar cadastro
│   └── cashback/              ← janela Acesso ao cashback
├── pagamento/                 ← tela de pagamento e finalização
├── consulta/                  ← tela de consulta de vendas
└── compartilhado/
    ├── barra-acoes/           ← barra de atalhos do rodapé (com teclas F)
    ├── dialogo/               ← janela modal genérica
    ├── icone/                 ← ícones SVG
    └── resumo-venda/          ← resumo dos totais (usado no pagamento)
```

**Quem faz o quê:**

- **Componentes** (telas e janelas) só exibem dados e repassam ações.
- **`VendaService`** guarda a venda em andamento (*rascunho*) e faz todos os cálculos. Não acessa o backend.
- **`VendasApiService`** faz buscas e gravações. Hoje responde com os mocks; depois fará as chamadas HTTP.

---

## Telas

### Nova venda | Ponto de venda (`pdv/`)

| Área                      | Funcionamento                                                                                                   |
| ------------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Dados do vendedor**     | Digita ou escolhe o código; o nome, e-mail e telefone são preenchidos pela busca do vendedor.                    |
| **Dados do cliente**      | Digita o CPF (máscara automática). Ao completar 11 dígitos, valida e mostra *CPF válido/inválido*. CPF válido → busca o cliente. Sem cliente = *Consumidor final*. |
| **Acesso ao cashback**    | Habilitado com cliente identificado. Mostra o saldo e permite resgatar parte dele na venda.                       |
| **Visualização do item**  | Foto do item selecionado (ou do último incluído). Usa `imagemUrl` da variação.                                   |
| **Adicionar produto**     | Campo amarelo: digita **REF/TAM** (ex.: `12345/42`) ou o **código de barras** e tecla Enter. Cada leitura cria uma linha nova. |
| **Linha do item**         | Nº, descrição, cor/tamanho, referência, quantidade (editável), **símbolo de moeda = alterar valor do item**, valor e lixeira (remover). Valor alterado mostra o original riscado. |
| **Aplicar desconto total**| **Símbolo de moeda abaixo dos itens = desconto geral** da venda, em R$ ou %. Informar 0 remove o desconto.          |
| **Resumo dos totais**     | Subtotal, Descontos, Cashback (quando houver) e Total.                                                           |

**Barra de atalhos:**

| Botão              | Tecla | Ação                                                       |
| ------------------ | ----- | ---------------------------------------------------------- |
| Novo cliente       | F4    | Abre o cadastro de cliente (já traz o CPF não cadastrado). |
| Limpar carrinho    | F6    | Remove itens, desconto, cashback e pagamentos.             |
| Cancelar venda     | F7    | Descarta a venda inteira (mantém o vendedor).              |
| Editar cadastro    | F8    | Edita o cliente identificado.                              |
| Ir para pagamento  | F2    | Vai para a tela de pagamento (exige vendedor e itens).     |
| Sair               | —     | Descarta a venda e volta para o login.                     |

Os atalhos não funcionam enquanto há uma janela aberta. Esc fecha a janela.

### Pagamento (`pagamento/`)

Lista as formas de pagamento, permite combinar várias (ex.: crédito 3x + dinheiro), calcula restante e troco e **finaliza** a venda (`POST /vendas`). Atalhos: Voltar (F3), Incluir pagamento (F9), Excluir pagamento (F8), Cancelar venda (F7), Finalizar venda (F2).

### Consulta de vendas (`consulta/`)

Lista as vendas (`GET /vendas`), com busca por nº, vendedor, cliente ou CPF, filtro por situação, detalhe da venda e cancelamento (`PATCH /vendas/{numero}/cancelamento`).

---

## Regras de negócio

Implementadas em `venda.service.ts` (com testes em `venda.service.spec.ts`). **O backend deve repetir as validações** ao gravar a venda; o frontend não é confiável sozinho.

| Regra | Descrição |
| ----- | --------- |
| Subtotal | `Σ (quantidade × precoUnitario)` — já considera valores alterados no PDV. |
| Desconto total | `PERCENTUAL`: `subtotal × valor / 100` (até 100%). `VALOR`: valor em R$ (não pode passar do subtotal). |
| Cashback | Limitado ao saldo do cliente e ao que sobra depois do desconto. Trocar de cliente zera o resgate. |
| Total | `subtotal − desconto − cashback` |
| Pagamento | Não aceita valor ≤ 0 nem abaixo do `valorMinimo` da forma. Só formas com `permiteTroco` (dinheiro) aceitam valor acima do restante. Parcelas de 1 até `maxParcelas`. |
| Troco | `totalPago − total` (quando positivo). |
| Finalizar | Exige ao menos 1 item, vendedor e restante = 0. |
| Arredondamento | Todos os valores em 2 casas decimais. |
| CPF | Validado pelos dígitos verificadores antes de consultar o backend (`cpf.ts`). Enviado **somente com números**. |

---

## Integração com o backend

1. No `vendas-api.service.ts`, injete o `HttpClient` (o `provideHttpClient()` já está no `app.config.ts`) e descomente o `apiUrl`:

   ```ts
   private apiUrl = 'http://localhost:8080';
   constructor(private http: HttpClient) { }
   ```

2. Troque o corpo de cada método pela chamada indicada no comentário dele. Exemplo:

   ```ts
   /*GET /vendedores/{codigo}*/
   buscarVendedor(codigo: string): Observable<Vendedor | null> {
     return this.http.get<Vendedor>(`${this.apiUrl}/vendedores/${codigo}`).pipe(
       catchError((erro) => (erro.status === 404 ? of(null) : throwError(() => erro))),
     );
   }
   ```

3. Mensagens de erro: as telas exibem `erro.message`. Recomenda-se que o backend responda erros no formato `{ "mensagem": "..." }` e que o serviço converta para `new Error(resposta.error.mensagem)`.
4. Após integrar tudo, apague `vendas.mock.ts` e ajuste os testes que o importam.

As telas **não precisam mudar**: já trabalham com `Observable`.

> CORS: o backend já tem `@CrossOrigin` e `WebConfig`. Os novos controllers precisam da mesma liberação.

---

## Contrato da API (endpoints)

Base: `http://localhost:8080`. Corpo e respostas em JSON. Datas em ISO 8601. Valores monetários como número com 2 casas (`349.90`).

### Vendedores

| Método | URL | Resposta |
| ------ | --- | -------- |
| GET | `/vendedores` | `200` lista de `Vendedor` |
| GET | `/vendedores/{codigo}` | `200` `Vendedor` · `404` não encontrado |

```json
{ "codigo": "0GA8", "nome": "ORLANDO A", "email": "orlando@voxa.com", "telefone": "(11) 98888-1001" }
```

### Clientes

| Método | URL | Corpo | Resposta |
| ------ | --- | ----- | -------- |
| GET | `/clientes?cpf=32970069865` | — | `200` `Cliente` · `404` não cadastrado |
| POST | `/clientes` | `Cliente` com `"id": null` | `201` `Cliente` com id · `409` CPF já cadastrado · `400` CPF inválido |
| PUT | `/clientes/{id}` | `Cliente` | `200` `Cliente` |
| GET | `/clientes/{cpf}/cashback` | — | `200` `{ "saldo": 25.50 }` |

```json
{ "id": 1, "cpf": "32970069865", "nome": "ALEX CAMARGO", "email": "alex@email.com", "telefone": "(11) 97777-2001" }
```

### Produtos

| Método | URL | Resposta |
| ------ | --- | -------- |
| GET | `/produtos/variacoes/busca?termo=12345/42` | `200` `ProdutoVariacao` · `404` não encontrado |

O `termo` pode ser **REF/TAM** (`referencia/tamanho`, ex.: `12345/42`) ou **código de barras** (ex.: `12345142`). Lembre de codificar a barra na URL (`12345%2F42`), o `HttpClient` faz isso com `params`.

```json
{
  "id": 1,
  "produto": { "id": 1, "referencia": "12345", "nome": "Tênis Nike Zoom Fly", "marca": "Nike" },
  "codigoBarras": "12345142",
  "tamanho": "42",
  "cor": "Preto",
  "preco": 349.90,
  "imagemUrl": "https://.../12345-preto.jpg"
}
```

### Formas de pagamento

| Método | URL | Resposta |
| ------ | --- | -------- |
| GET | `/formas-pagamento` | `200` lista de `FormaPagamento` |

```json
{ "id": "CREDITO", "descricao": "CARTÃO CRÉDITO", "valorMinimo": 0, "maxParcelas": 10, "permiteTroco": false }
```

### Vendas

| Método | URL | Corpo | Resposta |
| ------ | --- | ----- | -------- |
| POST | `/vendas` | `Venda` (com `numero`, `data` = `null`) | `201` `Venda` com `numero`, `data` e `status` · `400` regra violada |
| GET | `/vendas` | — | `200` lista de `Venda`, mais recentes primeiro |
| PATCH | `/vendas/{numero}/cancelamento` | — | `200` `Venda` com `"status": "CANCELADA"` · `404` |

Exemplo do corpo do `POST /vendas` (é o que `VendaService.montarVenda()` gera):

```json
{
  "numero": null,
  "data": null,
  "vendedor": { "codigo": "0GA8", "nome": "ORLANDO A", "email": "orlando@voxa.com", "telefone": "(11) 98888-1001" },
  "cliente": { "id": 1, "cpf": "32970069865", "nome": "ALEX CAMARGO", "email": "alex@email.com", "telefone": "(11) 97777-2001" },
  "itens": [
    {
      "variacao": { "id": 1, "produto": { "id": 1, "referencia": "12345", "nome": "Tênis Nike Zoom Fly", "marca": "Nike" },
                    "codigoBarras": "12345142", "tamanho": "42", "cor": "Preto", "preco": 349.90, "imagemUrl": null },
      "quantidade": 1,
      "precoOriginal": 349.90,
      "precoUnitario": 299.90
    }
  ],
  "subtotal": 299.90,
  "desconto": { "tipo": "PERCENTUAL", "valor": 10 },
  "valorDesconto": 29.99,
  "cashback": 20.00,
  "total": 249.91,
  "pagamentos": [
    { "forma": { "id": "CREDITO", "descricao": "CARTÃO CRÉDITO", "valorMinimo": 0, "maxParcelas": 10, "permiteTroco": false },
      "valor": 249.91, "parcelas": 3 }
  ],
  "troco": 0,
  "status": "FINALIZADA"
}
```

> Sugestão: no backend, basta ler os **ids** (`vendedor.codigo`, `cliente.id`, `variacao.id`, `forma.id`) e **recalcular** subtotal, desconto, total e troco, para não confiar nos valores enviados pelo navegador.

---

## Entidades sugeridas no backend

Já existem `Produto` e `ProdutoVariacao`. Os campos abaixo são os que o frontend usa.

| Entidade | Campos | Observação |
| -------- | ------ | ---------- |
| `Produto` | id, referencia, nome, marca | **já existe** |
| `ProdutoVariacao` | id, produto (N:1), codigoBarras, tamanho, cor, preco, imagemUrl | **já existe**, mas faltam os campos codigoBarras, tamanho, cor, preco e imagemUrl |
| `Vendedor` | codigo (único), nome, email, telefone | pode ser ligado ao `Usuario` do login |
| `Cliente` | id, cpf (único, só números), nome, email, telefone | |
| `CashbackCliente` | cliente, saldo | ou um campo `saldoCashback` no Cliente |
| `FormaPagamento` | id, descricao, valorMinimo, maxParcelas, permiteTroco | |
| `Venda` | numero (gerado), data, vendedor, cliente (opcional), subtotal, descontoTipo, descontoValor, valorDesconto, cashback, total, troco, status | status: `FINALIZADA` / `CANCELADA` |
| `ItemVenda` | venda (N:1), variacao (N:1), quantidade, precoOriginal, precoUnitario | |
| `PagamentoVenda` | venda (N:1), formaPagamento (N:1), valor, parcelas | |

---

## Dados de exemplo para teste

Enquanto não há backend, estes dados funcionam nas telas (`vendas.mock.ts`):

| Tipo | Valor para digitar | Resultado |
| ---- | ------------------ | --------- |
| Vendedor | `0GA8`, `0GB2`, `0GC5` | ORLANDO A, MARIANA S, CARLOS M |
| Cliente | CPF `329.700.698-65` | ALEX CAMARGO (cashback R$ 25,50) |
| Cliente | CPF `529.982.247-25` | BEATRIZ LIMA (sem cashback) |
| CPF válido sem cadastro | `111.444.777-35` | "Cliente não cadastrado" → Novo cliente |
| Produto | `12345/42` ou `12345142` | Tênis Nike Zoom Fly Preto/42 — R$ 349,90 |
| Produto | `12345/40` | Tênis Nike Zoom Fly Preto/40 |
| Produto | `20010/M`, `20010/G` | Camiseta Básica Algodão — R$ 59,90 |
| Produto | `30020/40` | Calça Jeans Slim — R$ 189,90 |

Os dados ficam só na memória: recarregar a página apaga vendas e clientes novos.

---

## Pendências e decisões em aberto

- [ ] **Endpoints**: criar os controllers listados em [Contrato da API](#contrato-da-api-endpoints).
- [ ] **Autenticação**: as rotas `/vendas` ainda não exigem login (não há *guard*). O login atual (`POST /login`) só devolve texto.
- [ ] **Vendedor x usuário logado**: decidir se o vendedor vem automaticamente do login.
- [ ] **Estoque**: ao finalizar a venda, o backend deve dar baixa no estoque da variação.
- [ ] **Cashback**: definir regra de acúmulo (quanto o cliente ganha por venda) e se o resgate debita o saldo na finalização.
- [ ] **Permissão para alterar valor/desconto**: hoje qualquer vendedor pode; avaliar limite ou senha de gerente.
- [ ] **Imagens**: definir onde ficam as fotos dos produtos (`imagemUrl`).
- [ ] **Nota fiscal (NFC-e)**: emissão após finalizar a venda (módulo Notas Fiscais).
