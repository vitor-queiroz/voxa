import { DEFAULT_CURRENCY_CODE, LOCALE_ID } from '@angular/core';
import { registerLocaleData } from '@angular/common';
import localePt from '@angular/common/locales/pt';
import { Routes } from '@angular/router';
import { Vendas } from './vendas';

registerLocaleData(localePt); /*formata moeda e datas no padrão brasileiro (R$ 1.234,56)*/

/*Rotas do módulo de vendas. Para usar: { path: 'vendas', loadChildren: () => import('./vendas/vendas.routes').then((m) => m.VENDAS_ROUTES) }*/
export const VENDAS_ROUTES: Routes = [
  {
    path: '',
    component: Vendas,
    providers: [
      { provide: LOCALE_ID, useValue: 'pt-BR' },
      { provide: DEFAULT_CURRENCY_CODE, useValue: 'BRL' }
    ],
    children: [
      {
        path: '',
        redirectTo: 'pdv',
        pathMatch: 'full'
      },
      {
        path: 'pdv',
        loadComponent: () => import('./pdv/pdv').then((m) => m.Pdv)
      },
      {
        path: 'pagamento',
        loadComponent: () => import('./pagamento/pagamento').then((m) => m.Pagamento)
      },
      {
        path: 'consulta',
        loadComponent: () => import('./consulta/consulta-vendas').then((m) => m.ConsultaVendas)
      }
    ]
  }
];
