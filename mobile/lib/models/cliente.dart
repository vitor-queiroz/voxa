
class Cliente {
  final int id;
  final String? cpf;
  final String nome;
  final String? email;
  final String? telefone;
  final String? cep;
  final String? logradouro;
  final String? numero;
  final String? complemento;
  final String? bairro;
  final String? cidade;
  final String? estado;
  final double saldoCashback;
  final String? dataCadastro;
  final String? dataAtualizacao;

  Cliente({
    required this.id,
    this.cpf,
    required this.nome,
    this.email,
    this.telefone,
    this.cep,
    this.logradouro,
    this.numero,
    this.complemento,
    this.bairro,
    this.cidade,
    this.estado,
    required this.saldoCashback,
    this.dataCadastro,
    this.dataAtualizacao,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as int,
      cpf: json['cpf'] as String?,
      nome: json['nome'] as String,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      cep: json['cep'] as String?,
      logradouro: json['logradouro'] as String?,
      numero: json['numero'] as String?,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String?,
      cidade: json['cidade'] as String?,
      estado: json['estado'] as String?,
      saldoCashback: (json['saldoCashback'] as num?)?.toDouble() ?? 0,
      dataCadastro: json['dataCadastro'] as String?,
      dataAtualizacao: json['dataAtualizacao'] as String?,
    );
  }
}
