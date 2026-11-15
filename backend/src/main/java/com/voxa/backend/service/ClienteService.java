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
import java.util.Objects;

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

        String cpf = normalizarCpf(dados.cpf());

        // CPF é opcional. Se informado, precisa ser válido.
        if (cpf != null) {
            if (!Cpf.valido(cpf)) {
                throw new RegraNegocioException("CPF inválido. Verifique os números digitados.");
            }

            if (clienteRepository.existsByCpf(cpf)) {
                throw new ConflitoException("Já existe um cliente com este CPF.");
            }
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

        String cpfInformado = normalizarCpf(dados.cpf());

        // O CPF de um cadastro existente não pode ser alterado.
        if (!Objects.equals(cpfInformado, cliente.getCpf())) {
            throw new RegraNegocioException(
                    "O CPF do cliente não pode ser alterado."
            );
        }

        preencher(cliente, dados);

        return ClienteDto.de(cliente);
    }

    public BigDecimal saldoCashback(String cpf) {
        return buscarEntidadePorCpf(cpf).getSaldoCashback();
    }

    private Cliente buscarEntidadePorCpf(String cpf) {

        String cpfNormalizado = normalizarCpf(cpf);

        if (cpfNormalizado == null || !Cpf.valido(cpfNormalizado)) {
            throw new RegraNegocioException("CPF inválido. Verifique os números digitados.");
        }

        return clienteRepository.findByCpf(cpfNormalizado)
                .orElseThrow(() -> new NaoEncontradoException("Cliente não cadastrado."));
    }

    private String normalizarCpf(String cpf) {

        String numeros = Cpf.somenteNumeros(cpf);

        return numeros.isBlank() ? null : numeros;
    }

    private void preencher(Cliente cliente, ClienteDto dados) {

        cliente.setNome(dados.nome().trim().toUpperCase());

        cliente.setEmail(vazioParaNulo(dados.email()));
        cliente.setTelefone(vazioParaNulo(dados.telefone()));

        cliente.setCep(vazioParaNulo(dados.cep()));
        cliente.setLogradouro(vazioParaNulo(dados.logradouro()));
        cliente.setNumero(vazioParaNulo(dados.numero()));
        cliente.setComplemento(vazioParaNulo(dados.complemento()));
        cliente.setBairro(vazioParaNulo(dados.bairro()));
        cliente.setCidade(vazioParaNulo(dados.cidade()));

        String estado = vazioParaNulo(dados.estado());
        cliente.setEstado(estado == null ? null : estado.toUpperCase());

        // Cashback e datas não são alterados pelos dados recebidos no DTO.
    }

    private String vazioParaNulo(String valor) {
        return valor == null || valor.isBlank() ? null : valor.trim();
    }
}
