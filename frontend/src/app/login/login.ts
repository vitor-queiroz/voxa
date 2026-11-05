import { Component } from '@angular/core';
import { FormsModule, NgForm } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../auth/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './login.html',
  styleUrls: ['./login.css']
})
export class Login {
  usuario = '';
  senha = '';

  constructor(
    private authService: AuthService,
    private router: Router
  ) { }

  acessar(form: NgForm): void {
    if (form.invalid) {
      return;
    }

    this.authService.login(this.usuario, this.senha).subscribe({
      next: (resposta) => {
        console.log('RESPOSTA EXATA DO BANCO/BACKEND:', resposta);

        // Vamos forçar a barra: se a resposta do teu backend vier vazia, nula ou disser que falhou, bloqueia!
        const resStr = String(resposta).toLowerCase();

        if (!resposta || resStr.includes('incorreto') || resStr.includes('inválid') || resStr.includes('erro') || resStr.includes('nao encontrado') || resStr.includes('false')) {
          alert('Usuário ou senha não encontrados no banco de dados!');
        } else {
          // Se passou, vai para o manager
          this.router.navigate(['/manager']);
        }
      },
      error: (erro) => {
        console.error('ERRO HTTP RETORNADO:', erro);
        alert('Acesso negado pelo servidor!');
      }
    });
  }
}
