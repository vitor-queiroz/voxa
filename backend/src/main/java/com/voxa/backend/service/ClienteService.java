package com.voxa.backend.service;

import com.voxa.backend.dto.ClienteDto;
import com.voxa.backend.exception.ConflitoException;
import com.voxa.backend.exception.NaoEncontradoException;
import com.voxa.backend.exception.RegraNegocioException;
import com.voxa.backend.model.Cliente;
import com.voxa.backend.repository.ClienteRepository;
import com.voxa.backend.util.Cpf;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
public class ClienteService {

    private final ClienteRepository clienteRepository;

    public ClienteService(ClienteRepository clienteRepository) {
        this.clienteRepository = clienteRepository;
    }

    public ClienteDto buscarPorCpf(String cpf) {
        return ClienteDto.de(buscarEntidadePorCpf(cpf));
    }

    @Transactional
    public ClienteDto cadastrar(ClienteDto dados) {
        String cpf = Cpf.somenteNumeros(dados.cpf());
        if (!Cpf.valido(cpf)) {
            throw new RegraNegocioException("CPF inválido.");
        }
        if (clienteRepository.existsByCpf(cpf)) {
            throw new ConflitoException("Já existe um cliente com este CPF.");
        }
        Cliente cliente = new Cliente();
        cliente.setCpf(cpf);
        preencher(cliente, dados);
        return ClienteDto.de(clienteRepository.save(cliente));
    }

    @Transactional
    public ClienteDto atualizar(Long id, ClienteDto dados) {
        Cliente cliente = clienteRepository.findById(id)
                .orElseThrow(() -> new NaoEncontradoException("Cliente não encontrado."));
        if (!Cpf.somenteNumeros(dados.cpf()).equals(cliente.getCpf())) {
            throw new RegraNegocioException("O CPF do cliente não pode ser alterado.");
        }
        preencher(cliente, dados);
        return ClienteDto.de(cliente);
    }

    public BigDecimal saldoCashback(String cpf) {
        return buscarEntidadePorCpf(cpf).getSaldoCashback();
    }

    private Cliente buscarEntidadePorCpf(String cpf) {
        return clienteRepository.findByCpf(Cpf.somenteNumeros(cpf))
                .orElseThrow(() -> new NaoEncontradoException("Cliente não cadastrado."));
    }

    private void preencher(Cliente cliente, ClienteDto dados) {
        cliente.setNome(dados.nome().trim().toUpperCase());
        cliente.setEmail(vazioParaNulo(dados.email()));
        cliente.setTelefone(vazioParaNulo(dados.telefone()));
    }

    private String vazioParaNulo(String valor) {
        return valor == null || valor.isBlank() ? null : valor.trim();
    }
}
