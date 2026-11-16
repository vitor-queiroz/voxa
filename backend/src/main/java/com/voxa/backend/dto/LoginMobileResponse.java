package com.voxa.backend.dto;

public record LoginMobileResponse(
        String token,
        String tokenType,
        FuncionarioResumo funcionario
) {
}
