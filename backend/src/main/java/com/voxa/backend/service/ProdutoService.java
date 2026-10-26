package com.voxa.backend.service;

import com.voxa.backend.dto.ProdutoVariacaoDto;
import com.voxa.backend.exception.NaoEncontradoException;
import com.voxa.backend.model.ProdutoVariacao;
import com.voxa.backend.repository.ProdutoVariacaoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class ProdutoService {

    private final ProdutoVariacaoRepository variacaoRepository;

    public ProdutoService(ProdutoVariacaoRepository variacaoRepository) {
        this.variacaoRepository = variacaoRepository;
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
