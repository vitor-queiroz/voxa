# VOXA — Gestão de Estoque e Vendas

**Mais controle para o estoque. Mais integração para as vendas.**

O **VOXA** é um projeto de sistema de gestão desenvolvido com o objetivo de integrar e otimizar processos relacionados ao controle de estoque e às operações comerciais.

A proposta surgiu a partir da experiência prática com a rotina de estoque e da percepção de que processos como o registro de mercadorias, o controle de produtos e a comunicação entre estoque e vendas podem ser "vistos/utilizados" com uma pluraridade mais coerente.

Mais do que controlar entradas e saídas, a visão do VOXA é aproximar diferentes áreas da operação, centralizando informações e facilitando o acesso aos dados necessários para o dia a dia.

> 🚧 **Projeto em desenvolvimento.** O VOXA está sendo construído de forma incremental, com funcionalidades implementadas e outras ainda em planejamento.

---

## 🎯 Objetivos do projeto

- **Gestão de estoque:** organizar o registro de mercadorias, os produtos e as movimentações de estoque (tentar trazer ideias inovadoras de acordo com a experiência que foi passada.)
- **Integração com vendas:** aqui é praticamente um padrão para a construção desses sistemas.
- **Agilidade operacional:** tentar reduzir o máximo de tarefas manuais, facilitando atividades recorrentes.
- **Adaptação para vendedores:** desenvolver uma proposta de utilização mobile que facilite o acesso a informações e o atendimento aos clientes.
- **Centralização de informações:** construir uma base que permita consultar e administrar os dados de forma mais organizada.

## 💡 A proposta

O VOXA parte de uma ideia simples: estoque e vendas não devem funcionar como operações isoladas.

A proposta é desenvolver uma solução em que o registro de mercadorias, a disponibilidade de produtos e as atividades comerciais possam trabalhar de maneira integrada.

Com isso, o projeto busca contribuir para uma rotina mais organizada, com menos retrabalho e maior facilidade no acesso às informações.


## 📦 Funcionalidades e andamento

O desenvolvimento está sendo realizado por etapas, priorizando a construção gradual da estrutura do sistema.

### Em desenvolvimento

- **Entrada de mercadorias:** estrutura da tela para registrar e conferir informações de recebimento.
- **Importação de NF-e:** leitura de arquivo XML para preencher automaticamente informações da nota fiscal.
- **Consulta de fornecedores:** integração entre o frontend Angular e a API desenvolvida em Spring Boot.
- **Persistência de fornecedores:** estrutura inicial para armazenar e consultar fornecedores no banco de dados.

### Próximas etapas planejadas

- Lançamento de produtos vinculados à entrada de mercadorias.
- Registro de quantidades, tamanhos, cores e custos.
- Conferência dos itens lançados e dos valores da nota fiscal.
- Confirmação da entrada e atualização do estoque.
- Expansão dos recursos de gestão de estoque e vendas.
- Evolução da proposta mobile voltada aos vendedores.

*Esta lista representa o estágio atual e os objetivos planejados; nem todas as funcionalidades estão concluídas.*

## 🏗️ Arquitetura da aplicação

O projeto utiliza uma arquitetura separada entre frontend, backend e banco de dados.

- **Frontend:** aplicação Angular responsável pela interface com o usuário.
- **Backend:** aplicação Java com Spring Boot, responsável pelas regras de negócio e pela comunicação com o banco.
- **Banco de dados:** MySQL, utilizado para a persistência das informações.

Essa separação permite evoluir a interface e as regras de negócio de forma organizada, preparando a aplicação para novas funcionalidades.


### Pré-requisitos

- Node.js e npm.
- Angular CLI compatível com a versão do projeto.
- Java e Maven compatíveis com a configuração do backend.
- Instância MySQL acessível.


## 📚 Visão/Ideias

O desenvolvimento do **VOXA** envolve uma experiência prática. Conseguir desenvolver um sistema que facilite e consiga ter uma complexidade visível para pessoas que usam 
diariamente esses sistemas, sem dúvidas vale muito mais que uma entrega de um projeto acadêmico. Espero conseguir transfomar toda essa experiência em algo robusto e utilizável.
