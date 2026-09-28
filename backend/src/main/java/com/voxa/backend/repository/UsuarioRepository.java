package com.voxa.backend.repository;

import com.voxa.backend.model.Usuario; //Traz para esse arquivo a classe "USUARIO"
import org.springframework.data.jpa.repository.JpaRepository; //Importa o JpaRepository fornecido pelo Spring Data JPA
import java.util.Optional; //Permite que o metodo indique que pode existir ou não um resultado


public interface UsuarioRepository extends JpaRepository<Usuario, Long> { //Usuario = a entidade que o repository manipula // Long == o tipo do ID dessa entidade.

    Optional<Usuario> findByUsuario(String usuario);
}
