package com.voxa.backend.service;

import com.voxa.backend.dto.ProdutoVariacaoDto;
import com.voxa.backend.exception.NaoEncontradoException;
import com.voxa.backend.exception.RegraNegocioException;
import com.voxa.backend.model.ProdutoImagem;
import com.voxa.backend.model.ProdutoVariacao;
import com.voxa.backend.repository.ProdutoImagemRepository;
import com.voxa.backend.repository.ProdutoVariacaoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class ProdutoService {

    /*Endereço gravado em imagemUrl para as fotos guardadas no banco*/
    public static final String URL_IMAGENS = "/produtos/imagens/";

    private static final long TAMANHO_MAXIMO = 1024 * 1024; //1 MB (o PDV já reduz a foto antes de enviar)

    private final ProdutoVariacaoRepository variacaoRepository;
    private final ProdutoImagemRepository imagemRepository;

    public ProdutoService(ProdutoVariacaoRepository variacaoRepository, ProdutoImagemRepository imagemRepository) {
        this.variacaoRepository = variacaoRepository;
        this.imagemRepository = imagemRepository;
    }

    /*Termo = código de barras (12345142) ou REF/TAM (12345/42)*/
    @Transactional(readOnly = true)
    public ProdutoVariacaoDto buscarVariacao(String termo) {
        String busca = termo == null ? "" : termo.trim();
        return porCodigoDeBarras(busca)
                .or(() -> porReferenciaETamanho(busca))
                .map(ProdutoVariacaoDto::de)
                .orElseThrow(() -> new NaoEncontradoException("Código " + busca + " não encontrado."));
    }

    /*Grava a foto e liga em todas as variações do mesmo produto e cor (a foto não muda com o tamanho)*/
    @Transactional
    public ProdutoVariacaoDto salvarImagem(Long variacaoId, MultipartFile arquivo) {
        ProdutoVariacao variacao = variacao(variacaoId);
        byte[] dados = lerArquivo(arquivo);
        String tipo = tipoDaImagem(dados)
                .orElseThrow(() -> new RegraNegocioException("Envie uma imagem JPG, PNG ou WEBP."));

        ProdutoImagem imagem = imagemRepository.save(new ProdutoImagem(tipo, dados));
        trocarImagem(variacao, URL_IMAGENS + imagem.getId());
        return ProdutoVariacaoDto.de(variacao);
    }

    @Transactional
    public ProdutoVariacaoDto removerImagem(Long variacaoId) {
        ProdutoVariacao variacao = variacao(variacaoId);
        trocarImagem(variacao, null);
        return ProdutoVariacaoDto.de(variacao);
    }

    @Transactional(readOnly = true)
    public ProdutoImagem buscarImagem(Long id) {
        return imagemRepository.findById(id)
                .orElseThrow(() -> new NaoEncontradoException("Imagem " + id + " não encontrada."));
    }

    private ProdutoVariacao variacao(Long id) {
        return variacaoRepository.findById(id)
                .orElseThrow(() -> new NaoEncontradoException("Produto " + id + " não encontrado."));
    }

    private void trocarImagem(ProdutoVariacao variacao, String novaUrl) {
        List<ProdutoVariacao> mesmaCor = mesmaCor(variacao);
        Set<String> antigas = mesmaCor.stream()
                .map(ProdutoVariacao::getImagemUrl)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        mesmaCor.forEach(v -> v.setImagemUrl(novaUrl));
        variacaoRepository.saveAllAndFlush(mesmaCor);
        antigas.forEach(this::apagarSeSemUso);
    }

    private List<ProdutoVariacao> mesmaCor(ProdutoVariacao variacao) {
        if (variacao.getCor() == null || variacao.getCor().isBlank()) {
            return List.of(variacao);
        }
        return variacaoRepository.findByProdutoIdAndCorIgnoreCase(variacao.getProduto().getId(), variacao.getCor());
    }

    /*Foto antiga que nenhuma variação usa mais sai do banco*/
    private void apagarSeSemUso(String url) {
        if (!url.startsWith(URL_IMAGENS) || variacaoRepository.existsByImagemUrl(url)) {
            return;
        }
        try {
            imagemRepository.deleteById(Long.valueOf(url.substring(URL_IMAGENS.length())));
        } catch (NumberFormatException ignorada) {
            //imagemUrl preenchida à mão com outro formato: não mexe
        }
    }

    private byte[] lerArquivo(MultipartFile arquivo) {
        if (arquivo == null || arquivo.isEmpty()) {
            throw new RegraNegocioException("Escolha uma imagem para enviar.");
        }
        if (arquivo.getSize() > TAMANHO_MAXIMO) {
            throw new RegraNegocioException("A imagem deve ter no máximo 1 MB.");
        }
        try {
            return arquivo.getBytes();
        } catch (IOException erro) {
            throw new RegraNegocioException("Não foi possível ler a imagem.");
        }
    }

    /*Descobre o tipo pelos primeiros bytes do arquivo (não confia no nome nem no tipo enviado)*/
    private Optional<String> tipoDaImagem(byte[] dados) {
        if (comecaCom(dados, 0, 0xFF, 0xD8, 0xFF)) {
            return Optional.of("image/jpeg");
        }
        if (comecaCom(dados, 0, 0x89, 'P', 'N', 'G')) {
            return Optional.of("image/png");
        }
        if (dados.length >= 12
                && new String(Arrays.copyOfRange(dados, 0, 4), StandardCharsets.US_ASCII).equals("RIFF")
                && new String(Arrays.copyOfRange(dados, 8, 12), StandardCharsets.US_ASCII).equals("WEBP")) {
            return Optional.of("image/webp");
        }
        return Optional.empty();
    }

    private boolean comecaCom(byte[] dados, int inicio, int... bytes) {
        if (dados.length < inicio + bytes.length) {
            return false;
        }
        for (int i = 0; i < bytes.length; i++) {
            if ((dados[inicio + i] & 0xFF) != bytes[i]) {
                return false;
            }
        }
        return true;
    }

    private Optional<ProdutoVariacao> porCodigoDeBarras(String busca) {
        return variacaoRepository.findByCodigoBarras(busca);
    }

    private Optional<ProdutoVariacao> porReferenciaETamanho(String busca) {
        int barra = busca.lastIndexOf('/');
        if (barra <= 0 || barra == busca.length() - 1) {
            return Optional.empty();
        }
        String referencia = busca.substring(0, barra).trim();
        String tamanho = busca.substring(barra + 1).trim();
        return variacaoRepository.findFirstByProdutoReferenciaIgnoreCaseAndTamanhoIgnoreCase(referencia, tamanho);
    }
}
