import 'package:flutter/material.dart';

import 'services/produto_service.dart';
import 'services/auth_service.dart';
import 'models/produto_variacao.dart';

class IdentificarProdutoPage extends StatefulWidget {
  final VoidCallback onBack;

  const IdentificarProdutoPage({
    super.key,
    required this.onBack,
  });

  @override
  State<IdentificarProdutoPage> createState() =>
      _IdentificarProdutoPageState();
}

class _IdentificarProdutoPageState
    extends State<IdentificarProdutoPage> {
  static const navy = Color(0xFF142B4A);
  static const blue = Color(0xFF246BFD);
  static const background = Color(0xFFF3F6FC);
  static const muted = Color(0xFF758198);

  final TextEditingController _referenciaController =
      TextEditingController();

  final ProdutoService _produtoService = ProdutoService();

  List<ProdutoVariacao> _variacoes = [];

  bool _carregando = true;
  String? _erro;
  String _pesquisa = '';

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  @override
  void dispose() {
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _carregarProdutos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final dados = await _produtoService.listarVariacoes();

      if (!mounted) return;

      setState(() {
        _variacoes = dados;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  List<_ProdutoPesquisa> get _produtosEncontrados {
    final termo = _pesquisa.trim().toLowerCase();

    if (termo.isEmpty) return [];

    // Agrupa as variações pelo ID do produto.
    final Map<int, List<ProdutoVariacao>> agrupados = {};

    for (final variacao in _variacoes) {
      agrupados
          .putIfAbsent(variacao.produto.id, () => [])
          .add(variacao);
    }

    final resultados = <_ProdutoPesquisa>[];

    for (final grupo in agrupados.values) {
      final produto = grupo.first.produto;

      // Pesquisa somente pela referência.
      if (!produto.referencia.toLowerCase().contains(termo)) {
        continue;
      }

      final quantidadeTotal = grupo.fold<int>(
        0,
        (total, variacao) =>
            total + (variacao.quantidade ?? 0),
      );

      final imagem = grupo
          .map((v) => v.imagemUrl)
          .firstWhere(
            (url) => url != null && url.isNotEmpty,
            orElse: () => null,
          );

      resultados.add(
        _ProdutoPesquisa(
          id: produto.id,
          nome: produto.nome,
          referencia: produto.referencia,
          cor: grupo.first.cor,
          imagemUrl: imagem,
          quantidade: quantidadeTotal,
        ),
      );
    }

    // IDs maiores como aproximação dos cadastros mais recentes.
    resultados.sort((a, b) => b.id.compareTo(a.id));

    return resultados;
  }

  void _selecionarProduto(_ProdutoPesquisa produto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Produto ${produto.referencia} selecionado. '
          'A próxima etapa será a escolha do tamanho.',
        ),
      ),
    );
  }

  Widget _buildImagemProduto(_ProdutoPesquisa produto) {
    final imagemUrl = produto.imagemUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xFFF0F2F6),
          child: imagemUrl == null
              ? const Icon(
                  Icons.image_not_supported_outlined,
                  size: 38,
                  color: muted,
                )
              : Image.network(
                  '${AuthService.baseUrl}$imagemUrl',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      size: 38,
                      color: muted,
                    );
                  },
                ),
        ),

        if (produto.quantidade == 0) ...[
          // Camada suave sobre a imagem.
          Container(
            color: Colors.white.withValues(alpha: 0.48),
          ),

          // Cadeado centralizado.
          Center(
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Color(0xFFC52E42),
                size: 27,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCardProduto(_ProdutoPesquisa produto) {
    final esgotado = produto.quantidade == 0;

    return Opacity(
      opacity: esgotado ? 0.85 : 1,
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFE3E9F2),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: esgotado
              ? null
              : () => _selecionarProduto(produto),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: _buildImagemProduto(produto),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        produto.nome,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Ref. ${produto.referencia}',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        produto.cor,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (esgotado)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8EB),
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ESGOTADO',
                            style: TextStyle(
                              color: Color(0xFFC52E42),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        )
                      else
                        Text(
                          '${produto.quantidade} '
                          '${produto.quantidade == 1 ? 'unidade disponível' : 'unidades disponíveis'}',
                          style: const TextStyle(
                            color: Color(0xFF168653),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),

                if (!esgotado)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: muted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultados() {
    if (_pesquisa.trim().isEmpty) {
      return const Center(
        child: Text(
          'Digite uma referência para pesquisar produtos.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: muted,
            fontSize: 12,
          ),
        ),
      );
    }

    if (_carregando) {
      return const Center(
        child: CircularProgressIndicator(
          color: blue,
        ),
      );
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: muted,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'Não foi possível carregar os produtos.',
              style: TextStyle(
                color: navy,
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: _carregarProdutos,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final produtos = _produtosEncontrados;

    if (produtos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum produto encontrado para essa referência.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: muted,
            fontSize: 12,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: produtos.length,
      itemBuilder: (context, index) {
        return _buildCardProduto(produtos[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Finalizar venda'),
                style: TextButton.styleFrom(
                  foregroundColor: navy,
                  padding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Identifique o produto',
                style: TextStyle(
                  color: navy,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Escaneie o código de barras ou busque pela referência.',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF07172F),
                  borderRadius: BorderRadius.circular(22),
                  gradient: const RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      Color(0xFF102B55),
                      Color(0xFF07172F),
                    ],
                  ),
                ),
                child: const CustomPaint(
                  painter: ScannerVisualPainter(),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vamos conectar o leitor de código de barras na próxima etapa.',
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(24, 24),
                        painter: BarcodeIconPainter(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('Escanear código de barras'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OU',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 14),

              const Text(
                'DIGITE A REFERÊNCIA',
                style: TextStyle(
                  color: navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _referenciaController,
                keyboardType: TextInputType.text,
                onChanged: (valor) {
                  setState(() {
                    _pesquisa = valor;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Ex.: 12350011-1',
                  prefixIcon: const Icon(
                    Icons.tag,
                    color: muted,
                    size: 19,
                  ),
                  suffixIcon: _pesquisa.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _referenciaController.clear();
                            setState(() {
                              _pesquisa = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: muted,
                          ),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0E6F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0E6F0),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (_pesquisa.isNotEmpty)
                const Text(
                  'RESULTADOS DA PESQUISA',
                  style: TextStyle(
                    color: navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),

              const SizedBox(height: 8),

              Expanded(
                child: _buildResultados(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProdutoPesquisa {
  final int id;
  final String nome;
  final String referencia;
  final String cor;
  final String? imagemUrl;
  final int quantidade;

  _ProdutoPesquisa({
    required this.id,
    required this.nome,
    required this.referencia,
    required this.cor,
    required this.imagemUrl,
    required this.quantidade,
  });
}

class ScannerVisualPainter extends CustomPainter {
  const ScannerVisualPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final glowPaint = Paint()
      ..color = const Color(0xFF1683FF).withValues(alpha: 0.65)
      ..strokeWidth = 5
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        12,
      );

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      glowPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFF39A5FF)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      linePaint,
    );

    const barWidths = [
      7.0, 5.0, 9.0, 5.0, 7.0,
      5.0, 9.0, 5.0, 7.0,
    ];

    const gap = 7.0;
    const barHeight = 64.0;

    final totalWidth =
        barWidths.reduce((a, b) => a + b) +
        gap * (barWidths.length - 1);

    double x = centerX - totalWidth / 2;

    final barcodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final barWidth in barWidths) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          centerY - barHeight / 2,
          barWidth,
          barHeight,
        ),
        const Radius.circular(1.5),
      );

      canvas.drawRRect(rect, barcodePaint);
      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant ScannerVisualPainter oldDelegate) {
    return false;
  }
}

class BarcodeIconPainter extends CustomPainter {
  final Color color;

  BarcodeIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const bars = [
      2.0, 1.0, 3.0, 1.0, 2.0,
      1.0, 3.0, 1.0, 2.0, 1.0,
    ];

    const gap = 1.2;
    double x = 2;

    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.square;

    for (final barWidth in bars) {
      paint.strokeWidth = barWidth;

      canvas.drawLine(
        Offset(x, 3),
        Offset(x, 21),
        paint,
      );

      x += barWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant BarcodeIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
