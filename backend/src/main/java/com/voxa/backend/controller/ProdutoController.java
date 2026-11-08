package com.voxa.backend.controller;

import com.voxa.backend.dto.ProdutoVariacaoDto;
import com.voxa.backend.dto.ProdutoCadastroDto;
import com.voxa.backend.dto.ProdutoVariacaoCadastroDto;
import com.voxa.backend.model.ProdutoImagem;
import com.voxa.backend.service.ProdutoService;

import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.time.Duration;

@RestController
@RequestMapping("/produtos")
public class ProdutoController {

    private final ProdutoService produtoService;

    public ProdutoController(ProdutoService produtoService) {
        this.produtoService = produtoService;
    }

    @GetMapping("/variacoes")
    public List<ProdutoVariacaoDto> listarVariacoes() {
        return produtoService.listarVariacoes();
    }

    @PostMapping
    public List<ProdutoVariacaoDto> cadastrarProduto(
            @RequestBody ProdutoCadastroDto dto) {
        return produtoService.cadastrarProduto(dto);
    }

    // Adiciona tamanhos a uma cor já cadastrada
    @PostMapping("/cores/{produtoCorId}/variacoes")
    public List<ProdutoVariacaoDto> cadastrarVariacoesNaCor(
            @PathVariable Long produtoCorId,
            @RequestBody List<ProdutoVariacaoCadastroDto> variacoes) {
        return produtoService.cadastrarVariacoesNaCor(produtoCorId, variacoes);
    }

    /* POST /produtos/variacoes/{id}/imagem */
    @PostMapping(
            value = "/variacoes/{id}/imagem",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ProdutoVariacaoDto enviarImagem(
            @PathVariable Long id,
            @RequestParam("arquivo") MultipartFile arquivo) {
        return produtoService.salvarImagem(id, arquivo);
    }

    /* DELETE /produtos/variacoes/{id}/imagem */
    @DeleteMapping("/variacoes/{id}/imagem")
    public ProdutoVariacaoDto removerImagem(@PathVariable Long id) {
        return produtoService.removerImagem(id);
    }

    /* GET /produtos/imagens/{id} */
    @GetMapping("/imagens/{id}")
    public ResponseEntity<byte[]> imagem(@PathVariable Long id) {
        ProdutoImagem imagem = produtoService.buscarImagem(id);

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(imagem.getTipo()))
                .cacheControl(
                        CacheControl.maxAge(Duration.ofDays(365))
                                .cachePublic()
                                .immutable()
                )
                .header("X-Content-Type-Options", "nosniff")
                .body(imagem.getDados());
    }
}
