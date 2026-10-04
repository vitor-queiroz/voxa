import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-manager',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './manager.html',
  styleUrl: './manager.css',
})
export class Manager {}
