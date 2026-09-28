package com.voxa.backend.controller;

import com.voxa.backend.service.UsuarioService;
import com.voxa.backend.dto.LoginRequest;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@RestController
public class UsuarioController {

    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/login")
    public String login(@RequestBody LoginRequest loginRequest) {

        var usuario = usuarioService.buscarPorUsuario(loginRequest.getUsuario());

        if(usuario == null){
            return "Usuário não encontrado";

        }
        return "Usuário encontrado: " + loginRequest.getUsuario();
    }
}
