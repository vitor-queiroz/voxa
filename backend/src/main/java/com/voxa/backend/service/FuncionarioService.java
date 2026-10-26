package com.voxa.backend.service;

import com.voxa.backend.dto.FuncionarioResumo;
import com.voxa.backend.exception.NaoEncontradoException;
import com.voxa.backend.model.Funcionario;
import com.voxa.backend.repository.FuncionarioRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class FuncionarioService {

    private final FuncionarioRepository funcionarioRepository;
    private final BigDecimal percentualComissaoPadrao;

    public FuncionarioService(FuncionarioRepository funcionarioRepository,
                              @Value("${voxa.comissao.percentual-padrao:3}") BigDecimal percentualComissaoPadrao) {
        this.funcionarioRepository = funcionarioRepository;
        this.percentualComissaoPadrao = percentualComissaoPadrao;
    }

    public List<FuncionarioResumo> listar() {
        return funcionarioRepository.findAllByOrderByNomeAsc().stream().map(FuncionarioResumo::de).toList();
    }

    public FuncionarioResumo buscar(String prontuario) {
        return FuncionarioResumo.de(buscarEntidade(prontuario));
    }

    public Funcionario buscarEntidade(String prontuario) {
        return funcionarioRepository.findById(prontuario)
                .orElseThrow(() -> new NaoEncontradoException("Prontuário " + prontuario + " não encontrado."));
    }

    /*
     * Percentual do funcionário (coluna percentual_comissao) ou o padrão de application.properties.
     * Uso interno: a comissão é gravada na venda, mas não é exposta pela API.
     */
    public BigDecimal percentualComissao(Funcionario funcionario) {
        return funcionario.getPercentualComissao() != null
                ? funcionario.getPercentualComissao()
                : percentualComissaoPadrao;
    }
}
