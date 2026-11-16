package com.voxa.backend.controller;

import com.voxa.backend.dto.LoginRequest;
import com.voxa.backend.dto.LoginMobileResponse;
import com.voxa.backend.dto.FuncionarioResumo;
import com.voxa.backend.model.Usuario;
import com.voxa.backend.service.UsuarioService;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.CrossOrigin;

@CrossOrigin
@RestController
public class UsuarioController {

    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/login")
    public String login(@RequestBody LoginRequest loginRequest) {

        var usuario = usuarioService.buscarPorUsuario(
                loginRequest.getUsuario()
        );

        if (usuario == null) {
            return "Usuário não encontrado";
        }

        if (!usuario.getSenha().equals(loginRequest.getSenha())) {
            return "Senha Inválida";
        }

        return "Login Autorizado";
    }

    @PostMapping("/mobile/login")
    public LoginMobileResponse loginMobile(
            @RequestBody LoginRequest loginRequest
    ) {

        // Valida as credenciais e verifica a situação do funcionário
        FuncionarioResumo funcionario = usuarioService.autenticarMobile(
                loginRequest.getUsuario(),
                loginRequest.getSenha()
        );

        // Gera o JWT para o funcionário autenticado
        String token = usuarioService.gerarTokenMobile(funcionario);

        // Retorna o token e os dados do funcionário
        return new LoginMobileResponse(
                token,
                "Bearer",
                funcionario
        );
    }
}