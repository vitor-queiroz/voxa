package com.voxa.backend.exception;

/*Registro não existe → HTTP 404*/
public class NaoEncontradoException extends RuntimeException {

    public NaoEncontradoException(String mensagem) {
        super(mensagem);
    }
}
