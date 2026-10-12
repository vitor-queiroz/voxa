package com.voxa.backend.dto;

import com.voxa.backend.model.Funcionario;

/*O que vai do funcionário para o frontend: sem CPF, RG e datas (LGPD)*/
public record FuncionarioResumo(String prontuario, String nome, String funcao, String situacao) {

    public static FuncionarioResumo de(Funcionario funcionario) {
        return new FuncionarioResumo(
                funcionario.getProntuario(),
                funcionario.getNome(),
                funcionario.getFuncao(),
                funcionario.getSituacao());
    }
}
