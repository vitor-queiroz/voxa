package com.voxa.backend.controller;

import com.voxa.backend.dto.VendaRequest;
import com.voxa.backend.dto.VendaResponse;
import com.voxa.backend.service.VendaService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/vendas")
public class VendaController {

    private final VendaService vendaService;

    public VendaController(VendaService vendaService) {
        this.vendaService = vendaService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public VendaResponse registrar(@RequestBody VendaRequest venda) {
        return vendaService.registrar(venda);
    }

    /*GET /vendas?de=2026-10-01&ate=2026-10-31&prontuario=0001 (todos opcionais)*/
    @GetMapping
    public List<VendaResponse> listar(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate de,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate ate,
            @RequestParam(required = false) String prontuario) {
        return vendaService.listar(de, ate, prontuario);
    }

    @PatchMapping("/{numero}/cancelamento")
    public VendaResponse cancelar(@PathVariable Long numero) {
        return vendaService.cancelar(numero);
    }
}
