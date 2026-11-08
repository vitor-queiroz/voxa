package com.voxa.backend.service;

import com.voxa.backend.model.Usuario;
import com.voxa.backend.repository.UsuarioRepository;
import org.springframework.stereotype.Service; //Aqui importa-a-anotação @Service do Spring.
import com.voxa.backend.dto.FuncionarioResumo;


@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;

    public UsuarioService(UsuarioRepository usuarioRepository){
        this.usuarioRepository = usuarioRepository;
    }

    public Usuario buscarPorUsuario(String usuario) {
        return usuarioRepository.findByUsuario(usuario).orElse(null); //busca o usuário
    }

    public Usuario buscarPorProntuario(String prontuario) {
        return usuarioRepository.findByFuncionario_Prontuario(prontuario).orElse(null);
    }

    // Autenticação do VOXA Mobile
    public FuncionarioResumo autenticarMobile(String prontuario, String senha) {

        Usuario usuario = buscarPorProntuario(prontuario);

        if (usuario == null) {
            throw new RuntimeException("Conta não encontrada.");
        }

        if (usuario.getSenha() == null || !usuario.getSenha().equals(senha)) {
            throw new RuntimeException("Senha inválida.");
        }

        if (usuario.getFuncionario() == null) {
            throw new RuntimeException("Nenhum funcionário vinculado a esta conta.");
        }

        if (!usuario.getFuncionario().podeVender()) {
            throw new RuntimeException("Acesso bloqueado. Funcionário não está trabalhando.");
        }

        return FuncionarioResumo.de(usuario.getFuncionario());
    }
  }

