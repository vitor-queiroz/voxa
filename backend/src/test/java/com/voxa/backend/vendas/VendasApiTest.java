package com.voxa.backend.vendas;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import java.math.BigDecimal;
import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/*Registro, consulta, cancelamento de vendas e painel de comissões*/
class VendasApiTest extends BaseApiTest {

    /*Venda como o frontend envia: totais errados de propósito, o backend deve recalcular*/
    private String venda(String prontuario, String clienteId, String itens, String desconto, String cashback, String pagamentos) {
        return """
                {
                  "numero": null, "data": null,
                  "vendedor": { "prontuario": "%s", "nome": "ignorado" },
                  "cliente": %s,
                  "itens": [%s],
                  "subtotal": 1, "desconto": %s, "valorDesconto": 1, "cashback": %s, "total": 1,
                  "pagamentos": [%s],
                  "troco": 999, "percentualComissao": 50, "valorComissao": 999, "status": "CANCELADA"
                }
                """.formatted(prontuario, clienteId == null ? "null" : "{ \"id\": " + clienteId + " }",
                itens, desconto, cashback, pagamentos);
    }

    private String item(Long variacaoId, int quantidade, String preco) {
        return "{ \"variacao\": { \"id\": %d, \"preco\": 1 }, \"quantidade\": %d, \"precoOriginal\": 1, \"precoUnitario\": %s }"
                .formatted(variacaoId, quantidade, preco);
    }

    private String pagamento(String forma, String valor, int parcelas) {
        return "{ \"forma\": { \"id\": \"%s\" }, \"valor\": %s, \"parcelas\": %d }".formatted(forma, valor, parcelas);
    }

    private Long registrar(String json) throws Exception {
        String resposta = mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON).content(json))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return ((Number) JsonPath.read(resposta, "$.numero")).longValue();
    }

    @Test
    void registraVendaRecalculandoTodosOsValores() throws Exception {
        // tênis alterado para 300,00 + 2 camisetas de 59,90 = 419,80
        // desconto 10% = 41,98 · cashback 20,00 · total 357,82 · comissão 3% = 10,73
        String json = venda("0001", alex.getId().toString(),
                item(tenis42.getId(), 1, "300.00") + "," + item(camisetaM.getId(), 2, "59.90"),
                "{ \"tipo\": \"PERCENTUAL\", \"valor\": 10 }",
                "20",
                pagamento("CREDITO_POS", "300", 3) + "," + pagamento("DINHEIRO", "100", 1));

        mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON).content(json))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.numero").isNumber())
                .andExpect(jsonPath("$.data").isString())
                .andExpect(jsonPath("$.status").value("FINALIZADA"))
                .andExpect(jsonPath("$.vendedor.nome").value("Carlos Eduardo Silva"))
                .andExpect(jsonPath("$.vendedor.cpf").doesNotExist())
                .andExpect(jsonPath("$.cliente.nome").value("ALEX CAMARGO"))
                .andExpect(jsonPath("$.itens", hasSize(2)))
                .andExpect(jsonPath("$.itens[0].precoOriginal").value(349.90))
                .andExpect(jsonPath("$.itens[0].precoUnitario").value(300.00))
                .andExpect(jsonPath("$.itens[0].variacao.produto.referencia").value("12345"))
                .andExpect(jsonPath("$.subtotal").value(419.80))
                .andExpect(jsonPath("$.desconto.tipo").value("PERCENTUAL"))
                .andExpect(jsonPath("$.valorDesconto").value(41.98))
                .andExpect(jsonPath("$.cashback").value(20.00))
                .andExpect(jsonPath("$.total").value(357.82))
                .andExpect(jsonPath("$.troco").value(42.18))
                .andExpect(jsonPath("$.percentualComissao").value(3))
                .andExpect(jsonPath("$.valorComissao").value(10.73))
                .andExpect(jsonPath("$.pagamentos[0].forma.descricao").value("CRÉDITO POS"))
                .andExpect(jsonPath("$.pagamentos[0].parcelas").value(3));

        assertThat(clienteRepository.findByCpf("32970069865").orElseThrow().getSaldoCashback())
                .isEqualByComparingTo("5.50");
    }

    @Test
    void recusaVendedorAfastadoOuSemProntuario() throws Exception {
        String itens = item(camisetaM.getId(), 1, "59.90");
        String pagamentos = pagamento("PIX", "59.90", 1);

        mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON)
                        .content(venda("0004", null, itens, "null", "0", pagamentos)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Ana Lima está \"Afastado\" e não pode ser vinculado à venda."));

        mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON)
                        .content(venda("", null, itens, "null", "0", pagamentos)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Informe o prontuário do vendedor."));
    }

    @Test
    void recusaPagamentoIncompletoOuTrocoForaDoDinheiro() throws Exception {
        String itens = item(camisetaM.getId(), 1, "59.90");

        mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON)
                        .content(venda("0001", null, itens, "null", "0", pagamento("PIX", "50", 1))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Ainda há valor restante a pagar."));

        mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON)
                        .content(venda("0001", null, itens, "null", "0", pagamento("PIX", "60", 1))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Só pagamento em dinheiro pode passar do total (troco)."));

        mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON)
                        .content(venda("0001", null, itens, "null", "0", pagamento("DEBITO_TEF", "59.90", 2))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("DÉBITO TEF permite de 1 a 1 parcela(s)."));
    }

    @Test
    void recusaCashbackSemClienteOuAcimaDoSaldo() throws Exception {
        String itens = item(tenis42.getId(), 1, "349.90");

        mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON)
                        .content(venda("0001", null, itens, "null", "10", pagamento("DINHEIRO", "349.90", 1))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Cashback exige cliente identificado."));

        mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON)
                        .content(venda("0001", alex.getId().toString(), itens, "null", "30", pagamento("DINHEIRO", "349.90", 1))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Cashback acima do saldo do cliente."));
    }

    @Test
    void listaComFiltrosECancelaDevolvendoCashback() throws Exception {
        Long doCarlos = registrar(venda("0001", alex.getId().toString(), item(tenis42.getId(), 1, "349.90"),
                "null", "25.50", pagamento("CREDITO_TEF", "324.40", 2)));
        registrar(venda("0003", null, item(camisetaM.getId(), 1, "59.90"), "null", "0", pagamento("PIX", "59.90", 1)));

        String hoje = LocalDate.now().toString();
        String amanha = LocalDate.now().plusDays(1).toString();
        mvc.perform(get("/vendas").param("prontuario", "0001")).andExpect(jsonPath("$", hasSize(1)));
        mvc.perform(get("/vendas").param("de", hoje).param("ate", hoje))
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].vendedor.prontuario").value("0003")); // mais recente primeiro
        mvc.perform(get("/vendas").param("de", amanha)).andExpect(jsonPath("$", hasSize(0)));

        mvc.perform(patch("/vendas/" + doCarlos + "/cancelamento"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CANCELADA"));
        assertThat(clienteRepository.findByCpf("32970069865").orElseThrow().getSaldoCashback())
                .isEqualByComparingTo(new BigDecimal("25.50"));

        mvc.perform(patch("/vendas/" + doCarlos + "/cancelamento"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Venda nº " + doCarlos + " já está cancelada."));
        mvc.perform(patch("/vendas/999999/cancelamento")).andExpect(status().isNotFound());
    }

    @Test
    void painelDeComissoesPorProntuarioSemContarCanceladas() throws Exception {
        registrar(venda("0001", null, item(tenis42.getId(), 1, "349.90"), "null", "0", pagamento("DINHEIRO", "349.90", 1)));
        Long cancelada = registrar(venda("0001", null, item(camisetaM.getId(), 1, "59.90"), "null", "0",
                pagamento("PIX", "59.90", 1)));
        registrar(venda("0003", null, item(camisetaM.getId(), 2, "59.90"), "null", "0", pagamento("DEBITO_POS", "119.80", 1)));
        mvc.perform(patch("/vendas/" + cancelada + "/cancelamento")).andExpect(status().isOk());

        String hoje = LocalDate.now().toString();
        mvc.perform(get("/comissoes").param("de", hoje).param("ate", hoje))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(3))) // todos os funcionários, mesmo sem vendas
                .andExpect(jsonPath("$[?(@.vendedor.prontuario == '0001')].quantidadeVendas").value(1))
                .andExpect(jsonPath("$[?(@.vendedor.prontuario == '0001')].pecas").value(1))
                .andExpect(jsonPath("$[?(@.vendedor.prontuario == '0001')].totalVendido").value(349.90))
                .andExpect(jsonPath("$[?(@.vendedor.prontuario == '0001')].valorComissao").value(10.50))
                .andExpect(jsonPath("$[?(@.vendedor.prontuario == '0003')].pecas").value(2))
                .andExpect(jsonPath("$[?(@.vendedor.prontuario == '0003')].valorComissao").value(1.80))
                .andExpect(jsonPath("$[?(@.vendedor.prontuario == '0004')].quantidadeVendas").value(0))
                .andExpect(jsonPath("$[?(@.vendedor.prontuario == '0004')].totalVendido").value(0.0));

        mvc.perform(get("/comissoes").param("de", hoje).param("ate", LocalDate.now().minusDays(1).toString()))
                .andExpect(status().isBadRequest());
    }
}
