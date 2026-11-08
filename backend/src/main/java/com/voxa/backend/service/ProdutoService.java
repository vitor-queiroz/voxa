
package com.voxa.backend.service;

import com.voxa.backend.dto.ProdutoVariacaoDto;
import com.voxa.backend.dto.ProdutoCadastroDto;
import com.voxa.backend.dto.ProdutoCorCadastroDto;
import com.voxa.backend.dto.ProdutoVariacaoCadastroDto;
import com.voxa.backend.exception.NaoEncontradoException;
import com.voxa.backend.exception.RegraNegocioException;
import com.voxa.backend.model.Produto;
import com.voxa.backend.model.ProdutoCor;
import com.voxa.backend.model.ProdutoImagem;
import com.voxa.backend.model.ProdutoVariacao;
import com.voxa.backend.model.Estoque;
import com.voxa.backend.repository.ProdutoRepository;
import com.voxa.backend.repository.ProdutoCorRepository;
import com.voxa.backend.repository.ProdutoImagemRepository;
import com.voxa.backend.repository.ProdutoVariacaoRepository;
import com.voxa.backend.repository.EstoqueRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class ProdutoService {

    /* Endereço das imagens armazenadas no banco */
    public static final String URL_IMAGENS = "/produtos/imagens/";

    private static final long TAMANHO_MAXIMO = 1024 * 1024;

    private final ProdutoVariacaoRepository variacaoRepository;
    private final ProdutoImagemRepository imagemRepository;
    private final EstoqueRepository estoqueRepository;
    private final ProdutoRepository produtoRepository;
    private final ProdutoCorRepository produtoCorRepository;

    public ProdutoService(
            ProdutoVariacaoRepository variacaoRepository,
            ProdutoImagemRepository imagemRepository,
            EstoqueRepository estoqueRepository,
            ProdutoRepository produtoRepository,
            ProdutoCorRepository produtoCorRepository
    ) {
        this.variacaoRepository = variacaoRepository;
        this.imagemRepository = imagemRepository;
        this.estoqueRepository = estoqueRepository;
        this.produtoRepository = produtoRepository;
        this.produtoCorRepository = produtoCorRepository;
    }

    @Transactional
    public List<ProdutoVariacaoDto> cadastrarProduto(ProdutoCadastroDto dto) {

        if (dto == null
                || dto.nome() == null || dto.nome().isBlank()
                || dto.marca() == null || dto.marca().isBlank()) {
            throw new RegraNegocioException(
                    "Informe o nome e a marca do produto."
            );
        }

        if (dto.cores() == null || dto.cores().isEmpty()) {
            throw new RegraNegocioException(
                    "Cadastre pelo menos uma cor para o produto."
            );
        }

        Set<String> referenciasECores = new HashSet<>();
        Set<String> codigosBarras = new HashSet<>();

        // Valida todas as cores e variações antes de salvar
        for (ProdutoCorCadastroDto cor : dto.cores()) {

            if (cor == null
                    || cor.referencia() == null || cor.referencia().isBlank()
                    || cor.cor() == null || cor.cor().isBlank()) {
                throw new RegraNegocioException(
                        "Informe a referência e a cor do produto."
                );
            }

            if (cor.variacoes() == null || cor.variacoes().isEmpty()) {
                throw new RegraNegocioException(
                        "Cadastre pelo menos um tamanho para cada cor."
                );
            }

            String chaveCor = cor.referencia().trim().toLowerCase(Locale.ROOT)
                    + "|" + cor.cor().trim().toLowerCase(Locale.ROOT);

            if (!referenciasECores.add(chaveCor)) {
                throw new RegraNegocioException(
                        "Existe uma cor duplicada com a mesma referência."
                );
            }

            Set<String> tamanhos = new HashSet<>();

            for (ProdutoVariacaoCadastroDto variacao : cor.variacoes()) {

                if (variacao == null
                        || variacao.tamanho() == null || variacao.tamanho().isBlank()
                        || variacao.preco() == null
                        || variacao.preco().compareTo(java.math.BigDecimal.ZERO) <= 0
                        || variacao.quantidade() == null
                        || variacao.quantidade() < 0) {
                    throw new RegraNegocioException(
                            "Verifique tamanho, preço e quantidade das variações."
                    );
                }

                String tamanho = variacao.tamanho().trim().toLowerCase(Locale.ROOT);

                if (!tamanhos.add(tamanho)) {
                    throw new RegraNegocioException(
                            "Existe um tamanho duplicado na mesma cor."
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
        }

        // Cria o produto principal
        Produto produto = new Produto();
        produto.setNome(dto.nome().trim());
        produto.setMarca(dto.marca().trim());

        produto = produtoRepository.save(produto);

        List<ProdutoVariacaoDto> resultado = new ArrayList<>();

        // Cria cada cor e suas respectivas variações
        for (ProdutoCorCadastroDto dadosCor : dto.cores()) {

            ProdutoCor produtoCor = new ProdutoCor();
            produtoCor.setProduto(produto);
            produtoCor.setReferencia(dadosCor.referencia().trim());
            produtoCor.setCor(dadosCor.cor().trim());

            produtoCor = produtoCorRepository.save(produtoCor);

            for (ProdutoVariacaoCadastroDto dados : dadosCor.variacoes()) {

                ProdutoVariacao variacao = new ProdutoVariacao();

                // Mantém o relacionamento antigo durante a migração
                variacao.setProduto(produto);

                // Novo relacionamento
                variacao.setProdutoCor(produtoCor);

                variacao.setTamanho(dados.tamanho().trim());
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
        }

        return resultado;
    }

    /* Lista todas as variações e seus estoques */
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

    /* Salva a imagem associada à cor do produto */
    @Transactional
    public ProdutoVariacaoDto salvarImagem(Long variacaoId, MultipartFile arquivo) {

        ProdutoVariacao variacao = variacao(variacaoId);
        byte[] dados = lerArquivo(arquivo);

        String tipo = tipoDaImagem(dados)
                .orElseThrow(() -> new RegraNegocioException(
                        "Envie uma imagem JPG, PNG ou WEBP."
                ));

        ProdutoImagem imagem = imagemRepository.save(
                new ProdutoImagem(tipo, dados)
        );

        String novaUrl = URL_IMAGENS + imagem.getId();

        if (variacao.getProdutoCor() != null) {

            ProdutoCor produtoCor = variacao.getProdutoCor();
            produtoCor.setImagemUrl(novaUrl);
            produtoCorRepository.save(produtoCor);

        } else {
            // Compatibilidade com produtos antigos
            trocarImagemLegada(variacao, novaUrl);
        }

        return ProdutoVariacaoDto.de(variacao);
    }

    @Transactional
    public ProdutoVariacaoDto removerImagem(Long variacaoId) {

        ProdutoVariacao variacao = variacao(variacaoId);

        if (variacao.getProdutoCor() != null) {

            ProdutoCor produtoCor = variacao.getProdutoCor();
            produtoCor.setImagemUrl(null);
            produtoCorRepository.save(produtoCor);

        } else {
            // Compatibilidade com produtos antigos
            trocarImagemLegada(variacao, null);
        }

        return ProdutoVariacaoDto.de(variacao);
    }

    @Transactional(readOnly = true)
    public ProdutoImagem buscarImagem(Long id) {

        return imagemRepository.findById(id)
                .orElseThrow(() -> new NaoEncontradoException(
                        "Imagem " + id + " não encontrada."
                ));
    }

    private ProdutoVariacao variacao(Long id) {

        return variacaoRepository.findById(id)
                .orElseThrow(() -> new NaoEncontradoException(
                        "Produto " + id + " não encontrado."
                ));
    }

    /* Atualização da imagem na estrutura antiga */
    private void trocarImagemLegada(ProdutoVariacao variacao, String novaUrl) {

        List<ProdutoVariacao> mesmaCor = mesmaCorLegada(variacao);

        Set<String> antigas = mesmaCor.stream()
                .map(ProdutoVariacao::getImagemUrl)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        mesmaCor.forEach(v -> v.setImagemUrl(novaUrl));

        variacaoRepository.saveAllAndFlush(mesmaCor);

        antigas.forEach(this::apagarSeSemUso);
    }

    private List<ProdutoVariacao> mesmaCorLegada(ProdutoVariacao variacao) {

        if (variacao.getCor() == null || variacao.getCor().isBlank()) {
            return List.of(variacao);
        }

        return variacaoRepository.findByProdutoIdAndCorIgnoreCase(
                variacao.getProduto().getId(),
                variacao.getCor()
        );
    }

    /* Remove somente imagens antigas da estrutura legada que não estão em uso */
    private void apagarSeSemUso(String url) {

        if (!url.startsWith(URL_IMAGENS)
                || variacaoRepository.existsByImagemUrl(url)) {
            return;
        }

        try {
            imagemRepository.deleteById(
                    Long.valueOf(url.substring(URL_IMAGENS.length()))
            );
        } catch (NumberFormatException ignorada) {
            // URL preenchida manualmente: não altera
        }
    }

    private byte[] lerArquivo(MultipartFile arquivo) {

        if (arquivo == null || arquivo.isEmpty()) {
            throw new RegraNegocioException(
                    "Escolha uma imagem para enviar."
            );
        }

        if (arquivo.getSize() > TAMANHO_MAXIMO) {
            throw new RegraNegocioException(
                    "A imagem deve ter no máximo 1 MB."
            );
        }

        try {
            return arquivo.getBytes();
        } catch (IOException erro) {
            throw new RegraNegocioException(
                    "Não foi possível ler a imagem."
            );
        }
    }

    /* Identifica o formato pelos bytes do arquivo */
    private Optional<String> tipoDaImagem(byte[] dados) {

        if (comecaCom(dados, 0, 0xFF, 0xD8, 0xFF)) {
            return Optional.of("image/jpeg");
        }

        if (comecaCom(dados, 0, 0x89, 'P', 'N', 'G')) {
            return Optional.of("image/png");
        }

        if (dados.length >= 12
                && new String(
                Arrays.copyOfRange(dados, 0, 4),
                StandardCharsets.US_ASCII
        ).equals("RIFF")
                && new String(
                Arrays.copyOfRange(dados, 8, 12),
                StandardCharsets.US_ASCII
        ).equals("WEBP")) {
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

    /* Procura primeiro na estrutura nova e depois na antiga */
    private Optional<ProdutoVariacao> porReferenciaETamanho(String busca) {

        int barra = busca.lastIndexOf('/');

        if (barra <= 0 || barra == busca.length() - 1) {
            return Optional.empty();
        }

        String referencia = busca.substring(0, barra).trim();
        String tamanho = busca.substring(barra + 1).trim();

        Optional<ProdutoVariacao> novaEstrutura =
                variacaoRepository
                        .findFirstByProdutoCorReferenciaIgnoreCaseAndTamanhoIgnoreCase(
                                referencia,
                                tamanho
                        );

        if (novaEstrutura.isPresent()) {
            return novaEstrutura;
        }

        return variacaoRepository
                .findFirstByProdutoReferenciaIgnoreCaseAndTamanhoIgnoreCase(
                        referencia,
                        tamanho
                );
    }
}
