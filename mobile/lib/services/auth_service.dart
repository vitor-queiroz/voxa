import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/funcionario_resumo.dart';


class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080';

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
      return FuncionarioResumo.fromJson(dados);
    }

    throw Exception('Não foi possível realizar o login: ${response.body}');
  }
}