import { Routes } from '@angular/router';
import { Login } from './login/login';
import { Manager } from './manager/manager';

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
  }
];