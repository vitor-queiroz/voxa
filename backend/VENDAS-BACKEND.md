# Backend do módulo de Vendas

Endpoints que as telas de vendas (`frontend/src/app/.../vendas`) usam. Spring Boot 4 + JPA + MySQL, no mesmo padrão do login (model → repository → service → controller).

## O que foi criado

| Pasta | Arquivos |
| ----- | -------- |
| `model/` | `Funcionario` (mapeia a tabela **funcionario** que já existe), `Cliente`, `FormaPagamento`, `Venda`, `ItemVenda`, `PagamentoVenda`, enums `StatusVenda` e `TipoDesconto`. **`ProdutoVariacao` ganhou** `codigoBarras`, `tamanho`, `cor`, `preco` e `imagemUrl` |
| `dto/` | O que entra e sai em JSON, com os mesmos nomes do frontend. `FuncionarioResumo` **não tem CPF/RG** (LGPD) |
| `repository/` | Um por entidade. `VendaRepository` tem as consultas do painel (GROUP BY prontuário) |
| `service/` | Regras. `VendaService` **recalcula** subtotal, desconto, cashback, total, troco e comissão (não confia no navegador) |
| `controller/` | `/funcionarios`, `/produtos`, `/clientes`, `/formas-pagamento`, `/vendas`, `/comissoes` |
| `exception/` | Erros viram `{ "mensagem": "..." }` com status 400, 404 ou 409 — o frontend mostra a mensagem |
| `config/` | `WebConfig` agora libera **PATCH** (cancelamento). `DadosIniciais` sincroniza as formas de pagamento (Dinheiro, PIX, Débito POS/TEF, Crédito POS/TEF) toda vez que o backend sobe; formas antigas são apagadas, ou só inativadas se alguma venda usou |
| `util/` | `Dinheiro` (2 casas, arredonda metade para cima) e `Cpf` (validação) |

## Banco de dados

O `application.properties` usa `spring.jpa.hibernate.ddl-auto=update`: **ao subir o backend, o Hibernate cria sozinho** as tabelas `cliente`, `forma_pagamento`, `venda`, `item_venda` e `pagamento_venda`, e acrescenta as colunas novas em `produto_variacao` e `funcionario` (`percentual_comissao`, opcional). A tabela `funcionario` e os dados dela são mantidos.

Depois de subir uma vez, **preencha as variações de produto** (as linhas antigas ficam com as colunas novas vazias):

```sql
UPDATE produto_variacao SET codigo_barras = '12345142', tamanho = '42', cor = 'Preto', preco = 349.90 WHERE id = 1;
```

Produto sem `preco` não pode ser vendido (o backend avisa).

## Comissão

- Percentual padrão: `voxa.comissao.percentual-padrao=3` no `application.properties`.
- Percentual por funcionário (opcional): `UPDATE funcionario SET percentual_comissao = 1.5 WHERE prontuario = '0003';`
- Calculada sobre o **total** (depois de desconto e cashback) e **gravada na venda**.
- Só vendas **FINALIZADAS** contam no painel. Cancelar devolve o cashback ao cliente e tira a venda da comissão.

## Regras validadas no backend

- Prontuário obrigatório; funcionário com situação **Trabalhando**.
- Ao menos 1 item; quantidade > 0; valor do item > 0.
- Desconto: % até 100, ou valor até o subtotal.
- Cashback: exige cliente; até o saldo dele e até o valor da venda. É **debitado** do saldo ao vender.
- Pagamento: valor ≥ mínimo da forma; parcelas de 1 até o máximo; total pago ≥ total; só **dinheiro** pode passar do total (troco).
- Cliente: CPF válido e único (409 se repetido); o CPF não pode ser alterado.

## Testes

```
./mvnw test
```

Rodam com **H2 em memória** (`src/test/resources/application.properties`), sem precisar do MySQL. Por isso o `pom.xml` ganhou a dependência `com.h2database:h2` com `scope test` (não vai para produção).

Exemplos de chamadas para o VS Code / IntelliJ estão em `teste.http`.

## Pendências

- **Estoque**: ainda não existe quantidade em estoque na `ProdutoVariacao`; quando existir, dar baixa no `VendaService.registrar` e devolver no `cancelar`.
- **Acúmulo de cashback**: hoje o backend só debita/devolve; falta a regra de quanto o cliente ganha por compra.
- **Login**: as rotas de vendas ainda não exigem autenticação.
