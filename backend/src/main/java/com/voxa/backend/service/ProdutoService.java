package com.voxa.backend.service;

import com.voxa.backend.dto.ProdutoVariacaoDto;
import com.voxa.backend.exception.NaoEncontradoException;
import com.voxa.backend.exception.RegraNegocioException;
import com.voxa.backend.model.ProdutoImagem;
import com.voxa.backend.model.ProdutoVariacao;
import com.voxa.backend.repository.ProdutoImagemRepository;
import com.voxa.backend.repository.ProdutoVariacaoRepository;
import com.voxa.backend.repository.EstoqueRepository;
import com.voxa.backend.model.Estoque;
import com.voxa.backend.repository.ProdutoRepository;
import com.voxa.backend.model.Produto;
import com.voxa.backend.dto.ProdutoCadastroDto;
import com.voxa.backend.dto.ProdutoVariacaoCadastroDto;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashSet;
import java.util.ArrayList;
import java.util.Locale;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.Map;

@Service
public class ProdutoService {

    /*Endereço gravado em imagemUrl para as fotos guardadas no banco*/
    public static final String URL_IMAGENS = "/produtos/imagens/";

    private static final long TAMANHO_MAXIMO = 1024 * 1024; //1 MB (o PDV já reduz a foto antes de enviar)

    private final ProdutoVariacaoRepository variacaoRepository;
    private final ProdutoImagemRepository imagemRepository;
    private final EstoqueRepository estoqueRepository;
    private final ProdutoRepository produtoRepository;


    public ProdutoService(ProdutoVariacaoRepository variacaoRepository, ProdutoImagemRepository imagemRepository, EstoqueRepository estoqueRepository,
                          ProdutoRepository produtoRepository) {

        this.variacaoRepository = variacaoRepository;
        this.imagemRepository = imagemRepository;
        this.estoqueRepository = estoqueRepository;
        this.produtoRepository = produtoRepository;
    }

    @Transactional
    public List<ProdutoVariacaoDto> cadastrarProduto(ProdutoCadastroDto dto) {

        // Validação dos dados principais
        if (dto == null
                || dto.referencia() == null || dto.referencia().isBlank()
                || dto.nome() == null || dto.nome().isBlank()
                || dto.marca() == null || dto.marca().isBlank()) {
            throw new RegraNegocioException(
                    "Informe a referência, o nome e a marca do produto."
            );
        }

        String referencia = dto.referencia().trim();


        if (dto.variacoes() == null || dto.variacoes().isEmpty()) {
            throw new RegraNegocioException(
                    "Cadastre pelo menos uma variação para o produto."
            );
        }

        Set<String> tamanhosECores = new HashSet<>();
        Set<String> codigosBarras = new HashSet<>();

        // Valida todas as variações antes de salvar
        for (ProdutoVariacaoCadastroDto variacao : dto.variacoes()) {

            if (variacao == null
                    || variacao.tamanho() == null || variacao.tamanho().isBlank()
                    || variacao.cor() == null || variacao.cor().isBlank()
                    || variacao.preco() == null
                    || variacao.preco().compareTo(java.math.BigDecimal.ZERO) <= 0
                    || variacao.quantidade() == null
                    || variacao.quantidade() < 0) {
                throw new RegraNegocioException(
                        "Verifique tamanho, cor, preço e quantidade das variações."
                );
            }

            String chave = variacao.cor().trim().toLowerCase(Locale.ROOT)
                    + "|" + variacao.tamanho().trim().toLowerCase(Locale.ROOT);

            if (!tamanhosECores.add(chave)) {
                throw new RegraNegocioException(
                        "Existe uma variação duplicada de cor e tamanho."
                );
            }

            String codigo = variacao.codigoBarras();

            if (codigo != null && !codigo.isBlank()) {

                codigo = codigo.trim();

                if (!codigosBarras.add(codigo)) {
                    throw new RegraNegocioException(
                            "O mesmo código de barras foi informado mais de uma vez."
                    );
                }

                if (variacaoRepository.findByCodigoBarras(codigo).isPresent()) {
                    throw new RegraNegocioException(
                            "O código de barras " + codigo + " já está cadastrado."
                    );
                }
            }
        }

        // Cria o produto principal
        Produto produto = new Produto();
        produto.setReferencia(referencia);
        produto.setNome(dto.nome().trim());
        produto.setMarca(dto.marca().trim());

        produto = produtoRepository.save(produto);

        List<ProdutoVariacaoDto> resultado = new ArrayList<>();

        // Cria as variações e seus respectivos estoques
        for (ProdutoVariacaoCadastroDto dados : dto.variacoes()) {

            ProdutoVariacao variacao = new ProdutoVariacao();

            variacao.setProduto(produto);
            variacao.setTamanho(dados.tamanho().trim());
            variacao.setCor(dados.cor().trim());
            variacao.setPreco(dados.preco());

            String codigo = dados.codigoBarras();

            variacao.setCodigoBarras(
                    codigo == null || codigo.isBlank()
                            ? null
                            : codigo.trim()
            );

            variacao = variacaoRepository.save(variacao);

            Estoque estoque = new Estoque();
            estoque.setProdutoVariacao(variacao);
            estoque.setQuantidade(dados.quantidade());

            estoqueRepository.save(estoque);

            resultado.add(
                    ProdutoVariacaoDto.de(variacao, estoque.getQuantidade())
            );
        }

        return resultado;
    }

    /*Termo = código de barras (12345142) ou REF/TAM (12345/42)*/
    @Transactional(readOnly = true)
    public List<ProdutoVariacaoDto> listarVariacoes() {

        List<ProdutoVariacao> variacoes = variacaoRepository.findAll();

        if (variacoes.isEmpty()) {
            return List.of();
        }

        List<Long> ids = variacoes.stream()
                .map(ProdutoVariacao::getId)
                .toList();

        Map<Long, Integer> quantidades = estoqueRepository
                .findAllByProdutoVariacaoIdIn(ids)
                .stream()
                .collect(Collectors.toMap(
                        estoque -> estoque.getProdutoVariacao().getId(),
                        Estoque::getQuantidade
                ));

        return variacoes.stream()
                .map(variacao -> ProdutoVariacaoDto.de(
                        variacao,
                        quantidades.getOrDefault(variacao.getId(), 0)
                ))
                .toList();
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
