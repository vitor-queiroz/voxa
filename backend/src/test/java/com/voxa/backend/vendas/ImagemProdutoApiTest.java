package com.voxa.backend.vendas;

import com.voxa.backend.model.Produto;
import com.voxa.backend.model.ProdutoVariacao;
import com.voxa.backend.repository.ProdutoImagemRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockMultipartFile;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class ImagemProdutoApiTest extends BaseApiTest {

    /*Início de um JPG de verdade (o backend olha os primeiros bytes)*/
    private static final byte[] JPG = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xE0, 0, 0x10, 'J', 'F', 'I', 'F'};

    @Autowired
    private ProdutoImagemRepository imagemRepository;

    @Test
    void enviaAFotoParaTodosOsTamanhosDaMesmaCorEMostraNoPdv() throws Exception {
        ProdutoVariacao tenis40 = novaVariacao(tenis42.getProduto(), "12345140", "40", "preto");
        ProdutoVariacao tenis41Branco = novaVariacao(tenis42.getProduto(), "12345141", "41", "Branco");

        String resposta = mvc.perform(multipart("/produtos/variacoes/{id}/imagem", tenis42.getId())
                        .file(new MockMultipartFile("arquivo", "foto.jpg", "image/jpeg", JPG)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.imagemUrl").value(startsWith("/produtos/imagens/")))
                .andReturn().getResponse().getContentAsString();
        String url = resposta.replaceAll(".*\"imagemUrl\":\"([^\"]+)\".*", "$1");

        em.clear();
        assertThat(variacaoRepository.findById(tenis40.getId()).orElseThrow().getImagemUrl()).isEqualTo(url);
        assertThat(variacaoRepository.findById(tenis41Branco.getId()).orElseThrow().getImagemUrl()).isNull();

        mvc.perform(get("/produtos/variacoes/busca").param("termo", "12345/40"))
                .andExpect(jsonPath("$.imagemUrl").value(url));
        mvc.perform(get(url))
                .andExpect(status().isOk())
                .andExpect(header().string("Content-Type", "image/jpeg"))
                .andExpect(content().bytes(JPG));
    }

    @Test
    void trocarERemoverAFotoApagaAImagemAntigaDoBanco() throws Exception {
        enviar(tenis42, JPG);
        enviar(tenis42, JPG);
        assertThat(imagemRepository.count()).isEqualTo(1); // a primeira foto foi apagada

        mvc.perform(delete("/produtos/variacoes/{id}/imagem", tenis42.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.imagemUrl").doesNotExist());
        assertThat(imagemRepository.count()).isZero();
    }

    @Test
    void recusaArquivoQueNaoEImagem() throws Exception {
        mvc.perform(multipart("/produtos/variacoes/{id}/imagem", camisetaM.getId())
                        .file(new MockMultipartFile("arquivo", "foto.jpg", "image/jpeg", "<html>".getBytes())))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Envie uma imagem JPG, PNG ou WEBP."));

        mvc.perform(multipart("/produtos/variacoes/{id}/imagem", 9999)
                        .file(new MockMultipartFile("arquivo", "foto.jpg", "image/jpeg", JPG)))
                .andExpect(status().isNotFound());

        mvc.perform(get("/produtos/imagens/9999")).andExpect(status().isNotFound());
    }

    private void enviar(ProdutoVariacao variacao, byte[] dados) throws Exception {
        mvc.perform(multipart("/produtos/variacoes/{id}/imagem", variacao.getId())
                        .file(new MockMultipartFile("arquivo", "foto.jpg", "image/jpeg", dados)))
                .andExpect(status().isOk());
    }

    private ProdutoVariacao novaVariacao(Produto produto, String codigo, String tamanho, String cor) {
        ProdutoVariacao v = new ProdutoVariacao();
        v.setProduto(produto);
        v.setCodigoBarras(codigo);
        v.setTamanho(tamanho);
        v.setCor(cor);
        v.setPreco(new BigDecimal("349.90"));
        return variacaoRepository.save(v);
    }
}
