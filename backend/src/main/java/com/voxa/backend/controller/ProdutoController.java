package com.voxa.backend.controller;

import com.voxa.backend.dto.ProdutoVariacaoDto;
import com.voxa.backend.service.ProdutoService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/produtos")
public class ProdutoController {

    private final ProdutoService produtoService;

    public ProdutoController(ProdutoService produtoService) {
        this.produtoService = produtoService;
    }

    /*GET /produtos/variacoes/busca?termo=12345142 ou ?termo=12345/42*/
    @GetMapping("/variacoes/busca")
    public ProdutoVariacaoDto buscarVariacao(@RequestParam String termo) {
        return produtoService.buscarVariacao(termo);
    }
}
