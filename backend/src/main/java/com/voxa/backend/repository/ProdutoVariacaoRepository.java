package com.voxa.backend.repository;

import com.voxa.backend.model.ProdutoVariacao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProdutoVariacaoRepository extends JpaRepository<ProdutoVariacao, Long> {

    Optional<ProdutoVariacao> findByCodigoBarras(String codigoBarras);

    /*Busca por REF/TAM, ex.: referência "12345" e tamanho "42"*/
    Optional<ProdutoVariacao> findFirstByProdutoReferenciaIgnoreCaseAndTamanhoIgnoreCase(String referencia, String tamanho);
}
