import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-estoque',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './estoque.html',
  styleUrl: './estoque.css',
})
export class Estoque {}
