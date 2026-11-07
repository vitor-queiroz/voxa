package com.voxa.backend.repository;

import com.voxa.backend.model.Estoque;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface EstoqueRepository extends JpaRepository<Estoque, Long> {

    Optional<Estoque> findByProdutoVariacaoId(Long produtoVariacaoId);

    List<Estoque> findAllByProdutoVariacaoIdIn(List<Long> ids);

}