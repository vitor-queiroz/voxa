package com.voxa.backend.dto;

/*Formato de todos os erros da API: { "mensagem": "..." } — o frontend mostra essa mensagem*/
public record ErroResponse(String mensagem) {
}
