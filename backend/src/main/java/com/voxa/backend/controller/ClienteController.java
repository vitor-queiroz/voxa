package com.voxa.backend.controller;

import com.voxa.backend.dto.ClienteDto;
import com.voxa.backend.dto.SaldoCashback;
import com.voxa.backend.service.ClienteService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/clientes")
public class ClienteController {

    private final ClienteService clienteService;

    public ClienteController(ClienteService clienteService) {
        this.clienteService = clienteService;
    }

    /*GET /clientes?cpf=32970069865*/
    @GetMapping
    public ClienteDto buscarPorCpf(@RequestParam String cpf) {
        return clienteService.buscarPorCpf(cpf);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ClienteDto cadastrar(@Valid @RequestBody ClienteDto cliente) {
        return clienteService.cadastrar(cliente);
    }

    @PutMapping("/{id}")
    public ClienteDto atualizar(@PathVariable Long id, @Valid @RequestBody ClienteDto cliente) {
        return clienteService.atualizar(id, cliente);
    }

    @GetMapping("/{cpf}/cashback")
    public SaldoCashback cashback(@PathVariable String cpf) {
        return new SaldoCashback(clienteService.saldoCashback(cpf));
    }
}
