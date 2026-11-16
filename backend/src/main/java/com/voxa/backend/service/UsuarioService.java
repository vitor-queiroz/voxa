package com.voxa.backend.service;

import com.voxa.backend.dto.FuncionarioResumo;
import com.voxa.backend.model.Usuario;
import com.voxa.backend.repository.UsuarioRepository;
import com.voxa.backend.security.JwtService;
import org.springframework.stereotype.Service;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final JwtService jwtService;

    public UsuarioService(
            UsuarioRepository usuarioRepository,
            JwtService jwtService
    ) {
        this.usuarioRepository = usuarioRepository;
        this.jwtService = jwtService;
    }

    public Usuario buscarPorUsuario(String usuario) {
        return usuarioRepository.findByUsuario(usuario).orElse(null);
    }

    public Usuario buscarPorProntuario(String prontuario) {
        return usuarioRepository
                .findByFuncionario_Prontuario(prontuario)
                .orElse(null);
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
            throw new RuntimeException(
                    "Nenhum funcionário vinculado a esta conta."
            );
        }

        if (!usuario.getFuncionario().podeVender()) {
            throw new RuntimeException(
                    "Acesso bloqueado. Funcionário não está trabalhando."
            );
        }

        return FuncionarioResumo.de(usuario.getFuncionario());
    }

    // Gera o token JWT após autenticar o funcionário
    public String gerarTokenMobile(FuncionarioResumo funcionario) {
        return jwtService.gerarToken(funcionario);
    }
}
