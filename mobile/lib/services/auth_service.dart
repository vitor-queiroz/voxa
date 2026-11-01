import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<String> login({
    required String prontuario,
    required String senha,
  }) async {
    final url = Uri.parse('$baseUrl/login');

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

    return response.body;
  }
}