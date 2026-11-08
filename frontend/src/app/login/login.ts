import { Component } from '@angular/core';
import { FormsModule, NgForm } from '@angular/forms';
import { AuthService } from '../auth/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule], /*FormsModule para o uso de [(ngModel)]...*/
  templateUrl: './login.html',
  styleUrl: './login.css',
})
export class Login {

  usuario = '';
  senha = '';

  constructor(private authService: AuthService) { }

  acessar(form: NgForm) {
    if (form.invalid) {
      return;
    }

    this.authService.login(this.usuario, this.senha).subscribe({
      next: (resposta) => {
        console.log(resposta);
      },
      error: (erro) => {
        console.error(erro);
      }
    });
  }
}