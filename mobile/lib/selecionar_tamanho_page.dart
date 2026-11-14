import 'package:flutter/material.dart';

import 'models/produto_variacao.dart';
import 'services/auth_service.dart';

class SelecionarTamanhoPage extends StatefulWidget {
  final List<ProdutoVariacao> variacoes;
  final Set<int> variacoesNoCarrinho;

  const SelecionarTamanhoPage({
    super.key,
    required this.variacoes,
    this.variacoesNoCarrinho = const {},
  });

  @override
  State<SelecionarTamanhoPage> createState() =>
      _SelecionarTamanhoPageState();
}

class _SelecionarTamanhoPageState
    extends State<SelecionarTamanhoPage> {
  static const navy = Color(0xFF142B4A);
  static const blue = Color(0xFF246BFD);
  static const background = Color(0xFFF3F6FC);
  static const muted = Color(0xFF758198);

  ProdutoVariacao? _variacaoSelecionada;

  List<ProdutoVariacao> get _variacoesOrdenadas {
    final lista = [...widget.variacoes];

    lista.sort((a, b) {
      final tamanhoA = double.tryParse(a.tamanho);
      final tamanhoB = double.tryParse(b.tamanho);

      if (tamanhoA != null && tamanhoB != null) {
        return tamanhoA.compareTo(tamanhoB);
      }

      return a.tamanho.compareTo(b.tamanho);
    });

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variacoes.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Nenhuma variação encontrada.'),
        ),
      );
    }

    final produto = widget.variacoes.first;
    final imagemUrl = produto.imagemUrl;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: navy,
        elevation: 0,
        title: const Text(
          'Selecionar tamanho',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE3E9F2),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 112,
                              height: 112,
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
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  produto.produto.nome,
                                  style: const TextStyle(
                                    color: navy,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  'Ref. ${produto.produto.referencia}',
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  produto.cor,
                                  style: const TextStyle(
                                    color: muted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  'R\$ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    color: blue,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'ESCOLHA O TAMANHO',
                      style: TextStyle(
                        color: navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Selecione uma opção disponível em estoque.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: _variacoesOrdenadas.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (context, index) {
                        final variacao =
                            _variacoesOrdenadas[index];

                        final quantidade =
                            variacao.quantidade ?? 0;
                        final esgotado = quantidade <= 0;

                        final selecionado =
                            _variacaoSelecionada?.id ==
                                variacao.id;

                        final noCarrinho =
                            widget.variacoesNoCarrinho
                                .contains(variacao.id);

                        final corFundo = esgotado
                            ? const Color(0xFFECEFF4)
                            : noCarrinho
                                ? const Color(0xFFFFF4D6)
                                : selecionado
                                    ? const Color(0xFFEAF0FF)
                                    : Colors.white;

                        final corBorda = noCarrinho
                            ? const Color(0xFFE5AD32)
                            : selecionado
                                ? blue
                                : const Color(0xFFE0E6F0);

                        return InkWell(
                          borderRadius:
                              BorderRadius.circular(14),
                          onTap: esgotado
                              ? null
                              : () {
                                  setState(() {
                                    _variacaoSelecionada =
                                        variacao;
                                  });
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: corFundo,
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                color: corBorda,
                                width:
                                    noCarrinho || selecionado
                                        ? 2
                                        : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  variacao.tamanho,
                                  style: TextStyle(
                                    color: esgotado
                                        ? muted
                                        : navy,
                                    fontSize: 23,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                if (esgotado)
                                  const Text(
                                    'Esgotado',
                                    style: TextStyle(
                                      color: Color(0xFFC52E42),
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  )
                                else if (noCarrinho)
                                  const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_rounded,
                                        color:
                                            Color(0xFFC58A13),
                                        size: 13,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        'No carrinho',
                                        style: TextStyle(
                                          color:
                                              Color(0xFF9A6900),
                                          fontSize: 10,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    '$quantidade disponível',
                                    style: const TextStyle(
                                      color: Color(0xFF168653),
                                      fontSize: 10,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                if (selecionado && !noCarrinho)
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(top: 4),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: blue,
                                      size: 17,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                16,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE3E9F2),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _variacaoSelecionada == null
                      ? null
                      : () {
                          Navigator.pop(
                            context,
                            _variacaoSelecionada,
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    disabledBackgroundColor:
                        const Color(0xFFCAD3E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
