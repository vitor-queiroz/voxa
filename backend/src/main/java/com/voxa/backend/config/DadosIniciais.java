package com.voxa.backend.config;

import com.voxa.backend.model.FormaPagamento;
import com.voxa.backend.repository.FormaPagamentoRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;

/*Cadastra as formas de pagamento na primeira vez que o backend sobe (tabela vazia)*/
@Component
public class DadosIniciais implements CommandLineRunner {

    private final FormaPagamentoRepository formaPagamentoRepository;

    public DadosIniciais(FormaPagamentoRepository formaPagamentoRepository) {
        this.formaPagamentoRepository = formaPagamentoRepository;
    }

    @Override
    public void run(String... args) {
        if (formaPagamentoRepository.count() > 0) {
            return;
        }
        formaPagamentoRepository.saveAll(List.of(
                new FormaPagamento("DINHEIRO", "DINHEIRO", BigDecimal.ZERO, 1, true),
                new FormaPagamento("PIX", "PIX", new BigDecimal("0.30"), 1, false),
                new FormaPagamento("DEBITO", "CARTÃO DÉBITO", BigDecimal.ZERO, 1, false),
                new FormaPagamento("CREDITO", "CARTÃO CRÉDITO", BigDecimal.ZERO, 10, false)));
    }
}
