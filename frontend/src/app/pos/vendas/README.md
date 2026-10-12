# Módulo de Vendas (frontend)

Telas de venda do VOXA: **Nova venda (PDV)**, **Pagamento**, **Consulta de vendas** e **Painel de vendedores** (comissões por prontuário).

O vendedor de cada venda é um **funcionário** (tabela `funcionario`), identificado pelo **prontuário**. A comissão de cada venda vai para o prontuário do vendedor.

> As telas usam o **backend Spring Boot** (endpoints em [Contrato da API](#contrato-da-api-endpoints)).
> Para testar sem backend, mude `USAR_DADOS_DE_EXEMPLO` para `true` em `vendas.config.ts`: as telas passam a usar os dados de `vendas.mock.ts`.

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
| `/vendas/painel-vendedores` | Painel de vendedores (vendas e comissão por prontuário) |

O módulo já configura sozinho o formato brasileiro de moeda e data (`R$ 1.234,56`) em `vendas.routes.ts`, carrega as fontes do design (IBM Plex) e tira a margem do `body` só enquanto as telas de vendas estão abertas.

---

## Estrutura de pastas

Cada componente segue o padrão do Angular CLI: `.ts` (lógica), `.html` (template), `.css` (estilo) e `.spec.ts` (testes).

```
vendas/
├── README.md                  ← este documento
├── vendas.routes.ts           ← rotas do módulo + formato pt-BR
├── vendas.ts/.html/.css/.spec ← tela base (barra VOXA + menu) + estilos de layout
├── vendas-componentes.css     ← peças visuais do design (cartões, campos, botões, tabelas)
├── vendas.model.ts            ← interfaces (contrato de dados com o backend)
├── vendas.config.ts           ← endereço do backend e a chave USAR_DADOS_DE_EXEMPLO
├── vendas-api.service.ts      ← ÚNICO ponto de comunicação com o backend (HTTP)
├── vendas-api.mock.ts         ← versão de exemplo da API (testes e uso sem backend)
├── vendas.mock.ts             ← dados de exemplo usados pela versão de exemplo
├── venda.service.ts           ← estado da venda em andamento + cálculos
├── cpf.ts                     ← validação e máscara de CPF
├── pdv/                       ← tela Nova venda | Ponto de venda
│   ├── ajuste-valor/          ← janela do símbolo de moeda (valor do item / desconto total)
│   ├── cadastro-cliente/      ← janela Novo cliente / Editar cadastro
│   └── cashback/              ← janela Acesso ao cashback
├── pagamento/                 ← tela de pagamento e finalização
├── consulta/                  ← tela de consulta de vendas
├── painel-vendedores/         ← painel de vendas e comissões por prontuário
└── compartilhado/
    ├── barra-acoes/           ← rodapé fixo: dicas + ações com tecla de atalho
    ├── etapas/                ← indicador 1 Itens e cliente · 2 Pagamento · 3 Concluída
    ├── vendedor-prontuario/   ← campo "Prontuário do vendedor" (PDV e pagamento)
    ├── dialogo/               ← janela modal genérica
    ├── icone/                 ← ícones SVG
    └── resumo-venda/          ← resumo do pagamento (coluna lateral)
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
| **Prontuário do vendedor**| Digita o prontuário (ex.: `1` vira `0001`) e Enter. Mostra nome e função e **vincula** a venda ao funcionário, com o percentual de comissão dele. Só funcionário com situação **Trabalhando** é aceito. |
| **Dados do cliente**      | Digita o CPF (máscara automática). Ao completar 11 dígitos, valida e mostra *CPF válido/inválido*. CPF válido → busca o cliente. Sem cliente = *Consumidor final*. |
| **Acesso ao cashback**    | Habilitado com cliente identificado. Mostra o saldo e permite resgatar parte dele na venda.                       |
| **Item selecionado**      | Foto do item selecionado (ou do último incluído), na coluna lateral. Usa `imagemUrl` da variação.                 |
| **Lançar produtos**       | Campo "Bipe o código aqui": **REF/TAM** (ex.: `12345/42`) ou **código de barras** + Enter. Cada leitura cria uma linha nova; a "Última leitura" confirma o item. |
| **Linha do item**         | Nº, descrição, cor/tamanho, referência, quantidade (editável), **símbolo de moeda = alterar valor do item**, valor e lixeira (remover). Valor alterado mostra o original riscado. |
| **Aplicar desconto total**| **Símbolo de moeda abaixo dos itens = desconto geral** da venda, em R$ ou %. Informar 0 remove o desconto.          |
| **Totais da venda**       | Total, peças, subtotal, descontos, cashback e a **comissão** do vendedor vinculado.                              |

**Barra de atalhos:**

| Botão              | Tecla | Ação                                                       |
| ------------------ | ----- | ---------------------------------------------------------- |
| Sair               | —     | Descarta a venda e volta para o login.                     |
| Novo cliente       | F4    | Abre o cadastro de cliente (já traz o CPF não cadastrado). |
| Editar cadastro    | F8    | Edita o cliente identificado.                              |
| Limpar carrinho    | F6    | Remove itens, desconto, cashback e pagamentos.             |
| Cancelar venda     | F7    | Descarta a venda inteira (mantém o vendedor).              |
| Ir para pagamento  | F2    | Vai para a tela de pagamento (exige prontuário e itens).   |

Também: **Del** remove a linha selecionada e **Esc** fecha janelas. Os atalhos não funcionam enquanto há uma janela aberta.

### Pagamento (`pagamento/`)

Começa pelo **Prontuário do vendedor** (vem preenchido do PDV e pode ser trocado): é o vínculo que leva a comissão para o funcionário. Depois lista as formas de pagamento, permite combinar várias (ex.: crédito 3x + dinheiro), calcula falta pagar e troco e **finaliza** a venda (`POST /vendas`). Atalhos: Voltar (F3), Cancelar venda (F7), Finalizar venda (F2).

### Consulta de vendas (`consulta/`)

Lista as vendas (`GET /vendas`), com busca por nº, prontuário, vendedor, cliente ou CPF, filtro por situação, detalhe da venda (itens, pagamentos e comissão) e cancelamento (`PATCH /vendas/{numero}/cancelamento`).

### Painel de vendedores (`painel-vendedores/`)

Mostra, para o período escolhido (hoje, 7 dias, 30 dias, este mês ou datas livres), uma linha por funcionário com **vendas, peças, total vendido e comissão**, e os totais do período (total vendido, comissões a pagar, vendas e ticket médio). Clicando em um vendedor, aparecem as vendas dele no período. Vem de `GET /comissoes` e `GET /vendas?prontuario=`.

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
| Vendedor | Funcionário encontrado pelo prontuário e com situação **Trabalhando**. Prontuário só com números é completado com zeros à esquerda até 4 dígitos (`1` → `0001`). |
| Comissão | `total × percentualComissao / 100`, calculada sobre o total **depois** de descontos e cashback. O percentual e o valor ficam gravados na venda. |
| Comissão no painel | Só vendas **FINALIZADAS** contam. Venda cancelada sai da comissão. |
| Finalizar | Exige ao menos 1 item, vendedor (prontuário) válido e restante = 0. |
| Arredondamento | Todos os valores em 2 casas decimais. |
| CPF | Validado pelos dígitos verificadores antes de consultar o backend (`cpf.ts`). Enviado **somente com números**. |

---

## Integração com o backend

Já está pronta. Resumo de como funciona:

- `vendas-api.service.ts` faz as chamadas HTTP para `API_URL` (`vendas.config.ts`, padrão `http://localhost:8080`).
- Erros do backend chegam no formato `{ "mensagem": "..." }` e viram `Error(mensagem)`; as telas mostram essa mensagem. Sem backend ligado, aparece "Sem conexão com o servidor".
- Buscas que dão **404** (prontuário, cliente, produto) devolvem `null`, e a tela mostra "não encontrado".
- `USAR_DADOS_DE_EXEMPLO = true` troca a API pela versão de exemplo (`vendas-api.mock.ts`), sem precisar do backend.
- Nos testes (`.spec.ts`), os componentes usam `provideVendasApiMock()`; o serviço HTTP tem o próprio teste com `HttpTestingController`.

> CORS: o `WebConfig` do backend libera `http://localhost:4200` com `GET, POST, PUT, PATCH, DELETE`. O `PATCH` é necessário para o cancelamento.

---

## Contrato da API (endpoints)

Base: `http://localhost:8080`. Corpo e respostas em JSON. Datas em ISO 8601. Valores monetários como número com 2 casas (`349.90`).

### Funcionários (vendedores)

Lidos da tabela `funcionario`. **Não envie CPF, RG nem data de nascimento** para o frontend: as telas só precisam destes 4 campos.

| Método | URL | Resposta |
| ------ | --- | -------- |
| GET | `/funcionarios` | `200` lista de `Funcionario` |
| GET | `/funcionarios/{prontuario}` | `200` `Funcionario` · `404` não encontrado |
| GET | `/funcionarios/{prontuario}/comissao` | `200` `{ "percentual": 3 }` |

```json
{ "prontuario": "0001", "nome": "Carlos Eduardo Silva", "funcao": "Vendedor", "situacao": "Trabalhando" }
```

| Coluna no banco (`funcionario`) | Campo no JSON |
| ------------------------------- | ------------- |
| `prontuario` | `prontuario` |
| `nome` | `nome` |
| `funcao` | `funcao` |
| `situacao` | `situacao` |
| `cpf`, `rg`, `data_nascimento`, `data_admissao` | não vão para o frontend |

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
| GET | `/vendas?de=2026-10-01&ate=2026-10-31&prontuario=0001` | — | `200` lista de `Venda`, mais recentes primeiro (todos os filtros são opcionais) |
| PATCH | `/vendas/{numero}/cancelamento` | — | `200` `Venda` com `"status": "CANCELADA"` · `404` |

### Comissões (painel de vendedores)

| Método | URL | Resposta |
| ------ | --- | -------- |
| GET | `/comissoes?de=2026-10-01&ate=2026-10-31` | `200` lista de `ResumoComissao`, uma linha por funcionário (inclusive quem não vendeu) |

```json
{
  "vendedor": { "prontuario": "0001", "nome": "Carlos Eduardo Silva", "funcao": "Vendedor", "situacao": "Trabalhando" },
  "quantidadeVendas": 2,
  "pecas": 3,
  "totalVendido": 729.70,
  "valorComissao": 21.89
}
```

Exemplo do corpo do `POST /vendas` (é o que `VendaService.montarVenda()` gera):

```json
{
  "numero": null,
  "data": null,
  "vendedor": { "prontuario": "0001", "nome": "Carlos Eduardo Silva", "funcao": "Vendedor", "situacao": "Trabalhando" },
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
  "percentualComissao": 3,
  "valorComissao": 7.50,
  "status": "FINALIZADA"
}
```

> Sugestão: no backend, basta ler os **ids** (`vendedor.prontuario`, `cliente.id`, `variacao.id`, `forma.id`) e **recalcular** subtotal, desconto, total, troco e comissão, para não confiar nos valores enviados pelo navegador.

---

## Entidades sugeridas no backend

Já existem `Produto` e `ProdutoVariacao`. Os campos abaixo são os que o frontend usa.

| Entidade | Campos | Observação |
| -------- | ------ | ---------- |
| `Produto` | id, referencia, nome, marca | **já existe** |
| `ProdutoVariacao` | id, produto (N:1), codigoBarras, tamanho, cor, preco, imagemUrl | **já existe**, mas faltam os campos codigoBarras, tamanho, cor, preco e imagemUrl |
| `Funcionario` | prontuario (PK), nome, cpf, rg, dataNascimento, funcao, dataAdmissao, situacao | **já existe no banco** (tabela `funcionario`); falta a entidade Java. Opcional: `percentualComissao` |
| `Cliente` | id, cpf (único, só números), nome, email, telefone | |
| `CashbackCliente` | cliente, saldo | ou um campo `saldoCashback` no Cliente |
| `FormaPagamento` | id, descricao, valorMinimo, maxParcelas, permiteTroco | |
| `Venda` | numero (gerado), data, vendedor (→ funcionario.prontuario), cliente (opcional), subtotal, descontoTipo, descontoValor, valorDesconto, cashback, total, troco, percentualComissao, valorComissao, status | status: `FINALIZADA` / `CANCELADA` |
| `ItemVenda` | venda (N:1), variacao (N:1), quantidade, precoOriginal, precoUnitario | |
| `PagamentoVenda` | venda (N:1), formaPagamento (N:1), valor, parcelas | |

### SQL sugerido (MySQL)

A tabela `funcionario` já existe. As demais ligam nela pelo prontuário:

```sql
-- Opcional: percentual de comissão por funcionário (senão, usar um padrão no backend)
ALTER TABLE funcionario ADD COLUMN percentual_comissao DECIMAL(5,2) NOT NULL DEFAULT 3.00;

CREATE TABLE cliente (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  cpf            VARCHAR(11)  NOT NULL UNIQUE,
  nome           VARCHAR(100) NOT NULL,
  email          VARCHAR(100),
  telefone       VARCHAR(20),
  saldo_cashback DECIMAL(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE forma_pagamento (
  id            VARCHAR(20) PRIMARY KEY,
  descricao     VARCHAR(50) NOT NULL,
  valor_minimo  DECIMAL(10,2) NOT NULL DEFAULT 0,
  max_parcelas  INT NOT NULL DEFAULT 1,
  permite_troco BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE venda (
  numero              BIGINT AUTO_INCREMENT PRIMARY KEY,
  data                DATETIME NOT NULL,
  prontuario_vendedor VARCHAR(10) NOT NULL,
  cliente_id          BIGINT NULL,
  subtotal            DECIMAL(10,2) NOT NULL,
  desconto_tipo       VARCHAR(10) NULL,
  desconto_valor      DECIMAL(10,2) NULL,
  valor_desconto      DECIMAL(10,2) NOT NULL DEFAULT 0,
  cashback            DECIMAL(10,2) NOT NULL DEFAULT 0,
  total               DECIMAL(10,2) NOT NULL,
  troco               DECIMAL(10,2) NOT NULL DEFAULT 0,
  percentual_comissao DECIMAL(5,2)  NOT NULL,
  valor_comissao      DECIMAL(10,2) NOT NULL,
  status              VARCHAR(12)   NOT NULL,
  FOREIGN KEY (prontuario_vendedor) REFERENCES funcionario (prontuario),
  FOREIGN KEY (cliente_id) REFERENCES cliente (id),
  INDEX idx_venda_vendedor_data (prontuario_vendedor, data)
);

CREATE TABLE item_venda (
  id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  venda_numero   BIGINT NOT NULL,
  variacao_id    BIGINT NOT NULL,
  quantidade     INT NOT NULL,
  preco_original DECIMAL(10,2) NOT NULL,
  preco_unitario DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (venda_numero) REFERENCES venda (numero),
  FOREIGN KEY (variacao_id) REFERENCES produto_variacao (id)
);

CREATE TABLE pagamento_venda (
  id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
  venda_numero       BIGINT NOT NULL,
  forma_pagamento_id VARCHAR(20) NOT NULL,
  valor              DECIMAL(10,2) NOT NULL,
  parcelas           INT NOT NULL DEFAULT 1,
  FOREIGN KEY (venda_numero) REFERENCES venda (numero),
  FOREIGN KEY (forma_pagamento_id) REFERENCES forma_pagamento (id)
);
```

Consulta do painel (`GET /comissoes`), uma linha por funcionário:

```sql
SELECT f.prontuario, f.nome, f.funcao, f.situacao,
       COUNT(v.numero)                   AS quantidade_vendas,
       COALESCE(SUM(p.pecas), 0)         AS pecas,
       COALESCE(SUM(v.total), 0)         AS total_vendido,
       COALESCE(SUM(v.valor_comissao), 0) AS valor_comissao
FROM funcionario f
LEFT JOIN venda v
       ON v.prontuario_vendedor = f.prontuario
      AND v.status = 'FINALIZADA'
      AND DATE(v.data) BETWEEN :de AND :ate
LEFT JOIN (SELECT venda_numero, SUM(quantidade) AS pecas
           FROM item_venda GROUP BY venda_numero) p
       ON p.venda_numero = v.numero
GROUP BY f.prontuario, f.nome, f.funcao, f.situacao;
```

---

## Dados de exemplo para teste

Com `USAR_DADOS_DE_EXEMPLO = true`, estes dados funcionam nas telas (`vendas.mock.ts`). Com o backend, use os dados do seu banco.

| Tipo | Valor para digitar | Resultado |
| ---- | ------------------ | --------- |
| Prontuário | `0001` (ou `1`), `0002`, `0003` | Carlos Eduardo Silva, Mariana Souza, João Pereira (gerente, comissão 1,5%) |
| Prontuário bloqueado | `0004` | Ana Lima, **Afastado**: não pode ser vinculado |
| Cliente | CPF `329.700.698-65` | ALEX CAMARGO (cashback R$ 25,50) |
| Cliente | CPF `529.982.247-25` | BEATRIZ LIMA (sem cashback) |
| CPF válido sem cadastro | `111.444.777-35` | "Cliente não cadastrado" → Novo cliente |
| Produto | `12345/42` ou `12345142` | Tênis Nike Zoom Fly Preto/42 — R$ 349,90 |
| Produto | `12345/40` | Tênis Nike Zoom Fly Preto/40 |
| Produto | `20010/M`, `20010/G` | Camiseta Básica Algodão — R$ 59,90 |
| Produto | `30020/40` | Calça Jeans Slim — R$ 189,90 |

Já existem 6 vendas de exemplo nos últimos 12 dias (uma cancelada), para a consulta e o painel não começarem vazios. Os dados ficam só na memória: recarregar a página volta ao início.

---

## Pendências e decisões em aberto

- [ ] **Endpoints**: criar os controllers listados em [Contrato da API](#contrato-da-api-endpoints).
- [ ] **Autenticação**: as rotas `/vendas` ainda não exigem login (não há *guard*). O login atual (`POST /login`) só devolve texto.
- [ ] **Vendedor x usuário logado**: decidir se o prontuário vem automaticamente do login.
- [ ] **Regra de comissão**: confirmar se o percentual é único (padrão 3%) ou por funcionário (`percentual_comissao`), e se incide sobre o total líquido (como está) ou sobre o subtotal.
- [ ] **Pagamento da comissão**: definir fechamento mensal e se o painel deve marcar comissões como pagas.
- [ ] **Dados pessoais**: a API não deve expor CPF/RG dos funcionários (LGPD).
- [ ] **Estoque**: ao finalizar a venda, o backend deve dar baixa no estoque da variação.
- [ ] **Cashback**: definir regra de acúmulo (quanto o cliente ganha por venda) e se o resgate debita o saldo na finalização.
- [ ] **Permissão para alterar valor/desconto**: hoje qualquer vendedor pode; avaliar limite ou senha de gerente.
- [ ] **Imagens**: definir onde ficam as fotos dos produtos (`imagemUrl`).
- [ ] **Nota fiscal (NFC-e)**: emissão após finalizar a venda (módulo Notas Fiscais).
