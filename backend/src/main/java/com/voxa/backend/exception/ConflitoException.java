package com.voxa.backend.exception;

/*Registro duplicado (ex.: CPF já cadastrado) → HTTP 409*/
public class ConflitoException extends RuntimeException {

    public ConflitoException(String mensagem) {
        super(mensagem);
    }
}
