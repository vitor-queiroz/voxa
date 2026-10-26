package com.voxa.backend.repository;

import com.voxa.backend.model.FormaPagamento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface FormaPagamentoRepository extends JpaRepository<FormaPagamento, String> {

    /*Formas que aparecem na tela de pagamento, na ordem cadastrada*/
    List<FormaPagamento> findByAtivaTrueOrderByOrdemAsc();

    /*Quantos pagamentos de venda usam esta forma (para saber se pode apagar)*/
    @Query("select count(p) from PagamentoVenda p where p.forma.id = :id")
    long contarUsos(@Param("id") String id);
}
