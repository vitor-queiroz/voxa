import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/funcionario_resumo.dart';
import 'token_storage.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  final TokenStorage _tokenStorage = TokenStorage();

  Future<FuncionarioResumo> login({
    required String prontuario,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/mobile/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'usuario': prontuario,
        'senha': senha,
      }),
    );

    if (response.statusCode == 200) {
      final dados = jsonDecode(response.body) as Map<String, dynamic>;

      // Recupera o token JWT retornado pelo backend.
      final token = dados['token'] as String;

      // Salva o token com armazenamento seguro.
      await _tokenStorage.salvarToken(token);

      // Recupera os dados do funcionário.
      final funcionario =
          dados['funcionario'] as Map<String, dynamic>;

      return FuncionarioResumo.fromJson(funcionario);
    }

    throw Exception(
      'Não foi possível realizar o login: ${response.body}',
    );
  }
}
