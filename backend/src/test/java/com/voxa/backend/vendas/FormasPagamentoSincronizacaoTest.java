package com.voxa.backend.vendas;

import com.voxa.backend.config.DadosIniciais;
import com.voxa.backend.model.FormaPagamento;
import com.voxa.backend.repository.FormaPagamentoRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/*Banco que já tinha as formas antigas CREDITO e DEBITO (antes do POS/TEF)*/
class FormasPagamentoSincronizacaoTest extends BaseApiTest {

    @Autowired
    private FormaPagamentoRepository formaPagamentoRepository;

    @Autowired
    private DadosIniciais dadosIniciais;

    private String vendaCom(String forma) {
        return """
                { "vendedor": { "prontuario": "0001" },
                  "itens": [ { "variacao": { "id": %d }, "quantidade": 1, "precoUnitario": 59.90 } ],
                  "pagamentos": [ { "forma": { "id": "%s" }, "valor": 59.90, "parcelas": 1 } ] }
                """.formatted(camisetaM.getId(), forma);
    }

    @Test
    void apagaFormaAntigaSemUsoEInativaAQueTemVenda() throws Exception {
        formaPagamentoRepository.save(new FormaPagamento("CREDITO", "CARTÃO CRÉDITO", BigDecimal.ZERO, 10, false, null));
        formaPagamentoRepository.save(new FormaPagamento("DEBITO", "CARTÃO DÉBITO", BigDecimal.ZERO, 1, false, null));
        mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON).content(vendaCom("CREDITO")))
                .andExpect(status().isCreated());

        dadosIniciais.run();

        assertThat(formaPagamentoRepository.findById("DEBITO")).isEmpty();
        assertThat(formaPagamentoRepository.findById("CREDITO")).get()
                .extracting(FormaPagamento::estaAtiva).isEqualTo(false);

        mvc.perform(get("/formas-pagamento"))
                .andExpect(jsonPath("$", hasSize(6)))
                .andExpect(jsonPath("$[?(@.id == 'CREDITO')]").isEmpty());
        mvc.perform(post("/vendas").contentType(MediaType.APPLICATION_JSON).content(vendaCom("CREDITO")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("CARTÃO CRÉDITO não está mais disponível."));
        mvc.perform(get("/vendas").param("prontuario", "0001"))
                .andExpect(jsonPath("$[0].pagamentos[0].forma.descricao").value("CARTÃO CRÉDITO")); // histórico preservado
    }
}
