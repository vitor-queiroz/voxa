class FuncionarioResumo {
  final String prontuario;
  final String nome;
  final String funcao;
  final String situacao;
  final String? fotoUrl;

  FuncionarioResumo({
    required this.prontuario,
    required this.nome,
    required this.funcao,
    required this.situacao,
    this.fotoUrl,
  });

  factory FuncionarioResumo.fromJson(Map<String, dynamic> json) {
    return FuncionarioResumo(
      prontuario: json['prontuario'] as String,
      nome: json['nome'] as String,
      funcao: json['funcao'] as String,
      situacao: json['situacao'] as String,
      fotoUrl: json['fotoUrl'] as String?,
    );
  }
}