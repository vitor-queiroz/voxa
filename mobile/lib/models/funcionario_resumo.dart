class FuncionarioResumo {
  final String prontuario;
  final String nome;
  final String funcao;
  final String situacao;

  FuncionarioResumo({
    required this.prontuario,
    required this.nome,
    required this.funcao,
    required this.situacao,
  });

  factory FuncionarioResumo.fromJson(Map<String, dynamic> json) {
    return FuncionarioResumo(
      prontuario: json['prontuario'] as String,
      nome: json['nome'] as String,
      funcao: json['funcao'] as String,
      situacao: json['situacao'] as String,
    );
  }
}