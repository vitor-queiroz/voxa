package com.voxa.backend.dto;

import com.voxa.backend.model.Cliente;
import jakarta.validation.constraints.NotBlank;

/*Usado para receber (POST/PUT /clientes) e devolver clientes. id null = cliente novo*/
public record ClienteDto(
        Long id,
        @NotBlank(message = "Informe o CPF.") String cpf,
        @NotBlank(message = "Informe o nome.") String nome,
        String email,
        String telefone) {

    public static ClienteDto de(Cliente cliente) {
        return new ClienteDto(cliente.getId(), cliente.getCpf(), cliente.getNome(), cliente.getEmail(), cliente.getTelefone());
    }
}
