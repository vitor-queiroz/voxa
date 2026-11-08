class ProdutoResumo {
  final int id;
  final String referencia;
  final String nome;
  final String marca;

  ProdutoResumo({
    required this.id,
    required this.referencia,
    required this.nome,
    required this.marca,
  });

  factory ProdutoResumo.fromJson(Map<String, dynamic> json) {
    return ProdutoResumo(
      id: json['id'] as int,
      referencia: json['referencia'] as String,
      nome: json['nome'] as String,
      marca: json['marca'] as String,
    );
  }
}

class ProdutoVariacao {
  final int id;
  final ProdutoResumo produto;
  final String? codigoBarras;
  final String tamanho;
  final String cor;
  final double preco;
  final String? imagemUrl;
  final int? quantidade;

  ProdutoVariacao({
    required this.id,
    required this.produto,
    this.codigoBarras,
    required this.tamanho,
    required this.cor,
    required this.preco,
    this.imagemUrl,
    this.quantidade,
  });

  factory ProdutoVariacao.fromJson(Map<String, dynamic> json) {
    return ProdutoVariacao(
      id: json['id'] as int,
      produto: ProdutoResumo.fromJson(
        json['produto'] as Map<String, dynamic>,
      ),
      codigoBarras: json['codigoBarras'] as String?,
      tamanho: json['tamanho'] as String,
      cor: json['cor'] as String,
      preco: (json['preco'] as num).toDouble(),
      imagemUrl: json['imagemUrl'] as String?,
      quantidade: (json['quantidade'] as num?)?.toInt(),
    );
  }
}
