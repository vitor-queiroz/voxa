import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

import '../models/produto_variacao.dart';

class ProdutoService {
  Future<List<ProdutoVariacao>> listarVariacoes() async {
    final url = Uri.parse('${AuthService.baseUrl}/produtos/variacoes');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dados = jsonDecode(response.body) as List<dynamic>;

      return dados.map((item) {
        return ProdutoVariacao.fromJson(
         item as Map<String, dynamic>
         );
      }).toList();
    }

    throw Exception(
      'Não foi possível carregar os produtos: ${response.body}',
    );
  }
}