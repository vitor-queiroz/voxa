package com.voxa.backend.repository;

import com.voxa.backend.model.Produto;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProdutoRepository extends JpaRepository<Produto, Long> {

    Optional<Produto> findByReferenciaIgnoreCase(String referencia);
}