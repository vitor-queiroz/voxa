package com.voxa.backend.repository;

import com.voxa.backend.model.Funcionario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FuncionarioRepository extends JpaRepository<Funcionario, String> { //String = tipo do prontuário

    List<Funcionario> findAllByOrderByNomeAsc();
}
