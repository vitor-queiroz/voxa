import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
    providedIn: 'root'
})
export class AuthService {

    private apiUrl = 'http://localhost:8080';
    constructor(private http: HttpClient) { }


    login(usuario: string, senha: string) {
        return this.http.post(`${this.apiUrl}/login`, {
            usuario: usuario,
            senha: senha
        }, {
            responseType: 'text'
        });
    }
}