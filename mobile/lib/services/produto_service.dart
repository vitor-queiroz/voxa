import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ProdutoService {
  Future<List<Map<String, dynamic>>> listarVariacoes() async {
    final url = Uri.parse('${AuthService.baseUrl}/produtos/variacoes');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dados = jsonDecode(response.body) as List<dynamic>;

      return dados
          .map((item) => item as Map<String, dynamic>)
          .toList();
    }

    throw Exception(
      'Não foi possível carregar os produtos: ${response.body}',
    );
  }
}