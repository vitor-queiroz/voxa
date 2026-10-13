package com.voxa.backend.config;

import com.voxa.backend.model.FormaPagamento;
import com.voxa.backend.repository.FormaPagamentoRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/*
 * Mantém as formas de pagamento do PDV sincronizadas toda vez que o backend sobe:
 * - cria ou atualiza as formas da lista abaixo;
 * - formas antigas que saíram da lista são apagadas se nenhuma venda usou,
 *   ou ficam inativas (somem da tela, mas continuam no histórico).
 */
@Component
public class DadosIniciais implements CommandLineRunner {

    static final List<FormaPagamento> FORMAS = List.of(
            new FormaPagamento("DINHEIRO", "DINHEIRO", BigDecimal.ZERO, 1, true, 1),
            new FormaPagamento("PIX", "PIX", new BigDecimal("0.30"), 1, false, 2),
            new FormaPagamento("DEBITO_POS", "DÉBITO POS", BigDecimal.ZERO, 1, false, 3),
            new FormaPagamento("DEBITO_TEF", "DÉBITO TEF", BigDecimal.ZERO, 1, false, 4),
            new FormaPagamento("CREDITO_POS", "CRÉDITO POS", BigDecimal.ZERO, 10, false, 5),
            new FormaPagamento("CREDITO_TEF", "CRÉDITO TEF", BigDecimal.ZERO, 10, false, 6));

    private final FormaPagamentoRepository formaPagamentoRepository;

    public DadosIniciais(FormaPagamentoRepository formaPagamentoRepository) {
        this.formaPagamentoRepository = formaPagamentoRepository;
    }

    @Override
    @Transactional
    public void run(String... args) {
        for (FormaPagamento forma : FORMAS) {
            formaPagamentoRepository.findById(forma.getId()).ifPresentOrElse(
                    existente -> existente.atualizarCom(forma),
                    () -> formaPagamentoRepository.save(novaCopia(forma)));
        }

        Set<String> atuais = FORMAS.stream().map(FormaPagamento::getId).collect(Collectors.toSet());
        for (FormaPagamento antiga : formaPagamentoRepository.findAll()) {
            if (atuais.contains(antiga.getId())) {
                continue;
            }
            if (formaPagamentoRepository.contarUsos(antiga.getId()) == 0) {
                formaPagamentoRepository.delete(antiga);
            } else {
                antiga.setAtiva(false);
            }
        }
    }

    private FormaPagamento novaCopia(FormaPagamento modelo) {
        FormaPagamento nova = new FormaPagamento();
        nova.setId(modelo.getId());
        nova.atualizarCom(modelo);
        return nova;
    }
}
