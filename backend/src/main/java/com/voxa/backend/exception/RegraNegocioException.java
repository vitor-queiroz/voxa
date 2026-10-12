package com.voxa.backend.exception;

/*Regra de negócio violada → HTTP 400*/
public class RegraNegocioException extends RuntimeException {

    public RegraNegocioException(String mensagem) {
        super(mensagem);
    }
}
