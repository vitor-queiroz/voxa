package com.voxa.backend.controller;

import com.voxa.backend.dto.FuncionarioResumo;
import com.voxa.backend.dto.PercentualComissao;
import com.voxa.backend.service.FuncionarioService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/funcionarios")
public class FuncionarioController {

    private final FuncionarioService funcionarioService;

    public FuncionarioController(FuncionarioService funcionarioService) {
        this.funcionarioService = funcionarioService;
    }

    @GetMapping
    public List<FuncionarioResumo> listar() {
        return funcionarioService.listar();
    }

    @GetMapping("/{prontuario}")
    public FuncionarioResumo buscar(@PathVariable String prontuario) {
        return funcionarioService.buscar(prontuario);
    }

    @GetMapping("/{prontuario}/comissao")
    public PercentualComissao comissao(@PathVariable String prontuario) {
        return new PercentualComissao(funcionarioService.percentualComissao(prontuario));
    }
}
