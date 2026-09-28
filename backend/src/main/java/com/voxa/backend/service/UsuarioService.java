package com.voxa.backend.service;

import com.voxa.backend.model.Usuario;
import com.voxa.backend.repository.UsuarioRepository;
import org.springframework.stereotype.Service; //Aqui importa-a-anotação @Service do Spring.

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;

    public UsuarioService(UsuarioRepository usuarioRepository){
        this.usuarioRepository = usuarioRepository;
    }

    public Usuario buscarPorUsuario(String usuario) {
        return usuarioRepository.findByUsuario(usuario).orElse(null); //busca o usuário
    }
}
