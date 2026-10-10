
import { Injectable } from '@angular/core'; /*permite que o Angular gerencie essa classe como um serviço e disponibilize suas dependências. */
import { HttpClient } from '@angular/common/http'; /*permite enviar requisições HTTP para o backend Spring Boot (como o próprio GET)*/
import { Observable } from 'rxjs';

export interface Fornecedor { /*Aqui estamos definindo o formato dos dados de um fornecedor no frontend.*/
  id?: number;
  cnpj: string;
  razaoSocial: string;
  nomeFantasia?: string; /* O ? significa que a propriedade é opcional.*/
}

@Injectable({
  providedIn: 'root', /*faz com que o Angular disponibilize o serviço na aplicação inteira, sem precisar registrá-lo manualmente em cada componente.*/
})
export class FornecedorService {
  private readonly apiUrl = 'http://localhost:8080/api/fornecedores'; /*(readonly) impede que o valor seja reatribuído depois da inicialização.*/

  constructor(private http: HttpClient) {}

  listarTodos(): Observable<Fornecedor[]> { /* Observable<Fornecedor[]>: indica que o método retorna uma resposta assíncrona contendo uma lista de fornecedores.*/
    return this.http.get<Fornecedor[]>(this.apiUrl);
  }
}
