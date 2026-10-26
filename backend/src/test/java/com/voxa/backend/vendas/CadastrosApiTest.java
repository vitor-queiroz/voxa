package com.voxa.backend.vendas;

import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/*Funcionários, produtos, clientes e formas de pagamento*/
class CadastrosApiTest extends BaseApiTest {

    @Test
    void funcionarioNaoExpoeCpfNemRg() throws Exception {
        mvc.perform(get("/funcionarios/0001"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.prontuario").value("0001"))
                .andExpect(jsonPath("$.nome").value("Carlos Eduardo Silva"))
                .andExpect(jsonPath("$.situacao").value("Trabalhando"))
                .andExpect(jsonPath("$.cpf").doesNotExist())
                .andExpect(jsonPath("$.rg").doesNotExist());

        mvc.perform(get("/funcionarios")).andExpect(jsonPath("$", hasSize(3)));
        mvc.perform(get("/funcionarios/9999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.mensagem").value("Prontuário 9999 não encontrado."));
    }

    @Test
    void naoExpoeOPercentualDeComissao() throws Exception {
        mvc.perform(get("/funcionarios/0001/comissao")).andExpect(status().isNotFound());
        mvc.perform(get("/funcionarios/0001")).andExpect(jsonPath("$.percentualComissao").doesNotExist());
    }

    @Test
    void buscaProdutoPorCodigoDeBarrasOuRefTam() throws Exception {
        mvc.perform(get("/produtos/variacoes/busca").param("termo", "12345142"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.produto.nome").value("Tênis Nike Zoom Fly"))
                .andExpect(jsonPath("$.tamanho").value("42"))
                .andExpect(jsonPath("$.preco").value(349.90));

        mvc.perform(get("/produtos/variacoes/busca").param("termo", "20010/m"))
                .andExpect(jsonPath("$.codigoBarras").value("20010001"));

        mvc.perform(get("/produtos/variacoes/busca").param("termo", "00000"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.mensagem").value("Código 00000 não encontrado."));
    }

    @Test
    void buscaCadastraEAtualizaCliente() throws Exception {
        mvc.perform(get("/clientes").param("cpf", "329.700.698-65"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nome").value("ALEX CAMARGO"));
        mvc.perform(get("/clientes").param("cpf", "11144477735")).andExpect(status().isNotFound());

        String novo = """
                { "id": null, "cpf": "111.444.777-35", "nome": "joana souza", "email": "", "telefone": "(11) 9999-0000" }
                """;
        mvc.perform(post("/clientes").contentType(MediaType.APPLICATION_JSON).content(novo))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNumber())
                .andExpect(jsonPath("$.cpf").value("11144477735"))
                .andExpect(jsonPath("$.nome").value("JOANA SOUZA"))
                .andExpect(jsonPath("$.email").doesNotExist());

        mvc.perform(post("/clientes").contentType(MediaType.APPLICATION_JSON).content(novo))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.mensagem").value("Já existe um cliente com este CPF."));

        String atualizado = """
                { "id": %d, "cpf": "32970069865", "nome": "Alex Camargo Jr", "email": "alex@email.com", "telefone": null }
                """.formatted(alex.getId());
        mvc.perform(put("/clientes/" + alex.getId()).contentType(MediaType.APPLICATION_JSON).content(atualizado))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nome").value("ALEX CAMARGO JR"))
                .andExpect(jsonPath("$.email").value("alex@email.com"));
    }

    @Test
    void recusaClienteComCpfInvalidoOuSemNome() throws Exception {
        mvc.perform(post("/clientes").contentType(MediaType.APPLICATION_JSON)
                        .content("{ \"cpf\": \"11144477700\", \"nome\": \"Teste\" }"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("CPF inválido."));

        mvc.perform(post("/clientes").contentType(MediaType.APPLICATION_JSON)
                        .content("{ \"cpf\": \"11144477735\", \"nome\": \"\" }"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Informe o nome."));
    }

    @Test
    void saldoDeCashback() throws Exception {
        mvc.perform(get("/clientes/32970069865/cashback")).andExpect(jsonPath("$.saldo").value(25.50));
    }

    @Test
    void formasDePagamentoPosETef() throws Exception {
        mvc.perform(get("/formas-pagamento"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(6)))
                .andExpect(jsonPath("$[*].descricao").value(org.hamcrest.Matchers.contains(
                        "DINHEIRO", "PIX", "DÉBITO POS", "DÉBITO TEF", "CRÉDITO POS", "CRÉDITO TEF")))
                .andExpect(jsonPath("$[?(@.id == 'CREDITO_TEF')].maxParcelas").value(10))
                .andExpect(jsonPath("$[?(@.id == 'DEBITO_POS')].maxParcelas").value(1))
                .andExpect(jsonPath("$[?(@.id == 'DINHEIRO')].permiteTroco").value(true));
    }
}
