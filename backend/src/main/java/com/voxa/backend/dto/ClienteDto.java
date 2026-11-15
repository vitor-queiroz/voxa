package com.voxa.backend.dto;

import com.voxa.backend.model.Cliente;
import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/* Usado para receber (POST/PUT /clientes)
 * e devolver os dados dos clientes */
public record ClienteDto(
        Long id,
        String cpf,
        @NotBlank(message = "Informe o nome.") String nome,
        String email,
        String telefone,
        String cep,
        String logradouro,
        String numero,
        String complemento,
        String bairro,
        String cidade,
        String estado,
        BigDecimal saldoCashback,
        LocalDateTime dataCadastro,
        LocalDateTime dataAtualizacao
) {

    public static ClienteDto de(Cliente cliente) {
        return new ClienteDto(
                cliente.getId(),
                cliente.getCpf(),
                cliente.getNome(),
                cliente.getEmail(),
                cliente.getTelefone(),
                cliente.getCep(),
                cliente.getLogradouro(),
                cliente.getNumero(),
                cliente.getComplemento(),
                cliente.getBairro(),
                cliente.getCidade(),
                cliente.getEstado(),
                cliente.getSaldoCashback(),
                cliente.getDataCadastro(),
                cliente.getDataAtualizacao()
        );
    }
}
