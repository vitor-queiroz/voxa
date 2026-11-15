import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cliente.dart';
import 'auth_service.dart';

class ClienteService {
  Future<Cliente?> buscarPorCpf(String cpf) async {
    final cpfNumeros = cpf.replaceAll(RegExp(r'\D'), '');

    final url = Uri.parse('${AuthService.baseUrl}/clientes').replace(
      queryParameters: {'cpf': cpfNumeros},
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dados = jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;

      return Cliente.fromJson(dados);
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(
      _mensagemErro(utf8.decode(response.bodyBytes)),
    );
  }

  Future<Cliente> cadastrar({
    required String nome,
    String? cpf,
    String? email,
    String? telefone,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
  }) async {
    final url = Uri.parse('${AuthService.baseUrl}/clientes');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: utf8.encode(jsonEncode(_dadosCliente(
        nome: nome,
        cpf: cpf,
        email: email,
        telefone: telefone,
        cep: cep,
        logradouro: logradouro,
        numero: numero,
        complemento: complemento,
        bairro: bairro,
        cidade: cidade,
        estado: estado,
      ))),
    );

    if (response.statusCode == 201) {
      final resultado =
          jsonDecode(utf8.decode(response.bodyBytes))
              as Map<String, dynamic>;

      return Cliente.fromJson(resultado);
    }

    throw Exception(
      _mensagemErro(utf8.decode(response.bodyBytes)),
    );
  }

  Future<Cliente> atualizar({
    required int id,
    required String nome,
    String? cpf,
    String? email,
    String? telefone,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
  }) async {
    final url = Uri.parse('${AuthService.baseUrl}/clientes/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: utf8.encode(jsonEncode(_dadosCliente(
        nome: nome,
        cpf: cpf,
        email: email,
        telefone: telefone,
        cep: cep,
        logradouro: logradouro,
        numero: numero,
        complemento: complemento,
        bairro: bairro,
        cidade: cidade,
        estado: estado,
      ))),
    );

    if (response.statusCode == 200) {
      final resultado =
          jsonDecode(utf8.decode(response.bodyBytes))
              as Map<String, dynamic>;

      return Cliente.fromJson(resultado);
    }

    throw Exception(
      _mensagemErro(utf8.decode(response.bodyBytes)),
    );
  }

  Map<String, dynamic> _dadosCliente({
    required String nome,
    String? cpf,
    String? email,
    String? telefone,
    String? cep,
    String? logradouro,
    String? numero,
    String? complemento,
    String? bairro,
    String? cidade,
    String? estado,
  }) {
    return {
      'nome': nome,
      'cpf': cpf?.replaceAll(RegExp(r'\D'), ''),
      'email': email,
      'telefone': telefone,
      'cep': cep?.replaceAll(RegExp(r'\D'), ''),
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
    };
  }

  String _mensagemErro(String resposta) {
    try {
      final dados = jsonDecode(resposta) as Map<String, dynamic>;

      return dados['mensagem']?.toString() ??
          dados['message']?.toString() ??
          'Não foi possível realizar a operação.';
    } catch (_) {
      return 'Não foi possível realizar a operação.';
    }
  }
}
