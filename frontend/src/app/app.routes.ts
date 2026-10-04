import { Routes } from '@angular/router';
import { Login } from './login/login';
import { Manager } from './manager/manager';
import { Estoque } from './estoque/estoque';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full'
  },
  {
    path: 'login',
    component: Login
  },
    {
    path: 'manager',
    component: Manager
  },
  {
    path: 'estoque',
    component: Estoque
  }
];