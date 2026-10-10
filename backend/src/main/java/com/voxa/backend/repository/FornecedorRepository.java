package com.voxa.backend.repository;

import com.voxa.backend.model.Fornecedor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FornecedorRepository extends JpaRepository<Fornecedor, Long> { //fornece operações básicas para cadastrar, consultar, atualizar e excluir fornecedores.

    Optional<Fornecedor> findByCnpj(String cnpj); //(findBy...cnpj) = permite pesquisar um fornecedor pelo CNPJ. ---------- Optional... = representa um resultado que pode existir ou não, permitindo tratar CNPJs que não estejam cadastrados.

}