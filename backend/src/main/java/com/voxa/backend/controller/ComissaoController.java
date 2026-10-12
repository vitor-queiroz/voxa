package com.voxa.backend.controller;

import com.voxa.backend.dto.ResumoComissao;
import com.voxa.backend.service.ComissaoService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/comissoes")
public class ComissaoController {

    private final ComissaoService comissaoService;

    public ComissaoController(ComissaoService comissaoService) {
        this.comissaoService = comissaoService;
    }

    /*GET /comissoes?de=2026-10-01&ate=2026-10-31 — uma linha por funcionário*/
    @GetMapping
    public List<ResumoComissao> resumo(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate de,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate ate) {
        return comissaoService.resumo(de, ate);
    }
}
