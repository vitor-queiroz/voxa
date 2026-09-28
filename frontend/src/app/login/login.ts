import { Component } from '@angular/core';
import { FormsModule, NgForm } from '@angular/forms';

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

  acessar(form: NgForm) {
    if (form.invalid) {
      return;
    }
  }

}
