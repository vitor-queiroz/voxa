package com.voxa.backend.repository;

import com.voxa.backend.model.FormaPagamento;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FormaPagamentoRepository extends JpaRepository<FormaPagamento, String> {
}
