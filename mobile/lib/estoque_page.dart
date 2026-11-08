import 'package:flutter/material.dart';
import 'services/produto_service.dart';
import 'services/auth_service.dart';
import 'models/produto_variacao.dart';

class EstoquePage extends StatefulWidget {
  const EstoquePage({super.key});

  @override
  State<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends State<EstoquePage> {
  static const navy = Color(0xFF142B4A);
  static const blue = Color(0xFF246BFD);
  static const background = Color(0xFFF3F6FC);
  static const muted = Color(0xFF758198);

  final TextEditingController _searchController =
      TextEditingController();

  final ProdutoService _produtoService = ProdutoService();

  String _selectedFilter = 'Todos';
  String _searchText = '';
  int? _expandedProductId;

  List<Map<String, dynamic>> _products = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final variacoes = await _produtoService.listarVariacoes();

      final Map<int, Map<String, dynamic>> agrupados = {};

      for (final ProdutoVariacao variacao in variacoes) {
        final produtoId = variacao.produto.id;

        agrupados.putIfAbsent(produtoId, () {
          return {
            'id': produtoId,
            'name': variacao.produto.nome,
            'reference': variacao.produto.referencia,
            'color': variacao.cor,
            'quantity': 0,
            'image': Icons.directions_run_rounded,
            'imageUrl': variacao.imagemUrl,
            'sizes': <String, int>{},
          };
        });

        final produto = agrupados[produtoId]!;

        final quantidade = variacao.quantidade ?? 0;

        produto['sizes'][variacao.tamanho] = quantidade;

        produto['quantity'] =
            (produto['quantity'] as int) + quantidade;
      }

      if (!mounted) return;

      setState(() {
        _products = agrupados.values.toList();
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Leitor de código de barras será implementado futuramente.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredProducts {
    final query = _searchText.toLowerCase().trim();

    return _products.where((product) {
      final matchesSearch =
          product['name'].toString().toLowerCase().contains(query) ||
          product['reference'].toString().toLowerCase().contains(query) ||
          product['color'].toString().toLowerCase().contains(query);

      final quantity = product['quantity'] as int;

      final matchesFilter = switch (_selectedFilter) {
        'Baixo estoque' => quantity > 0 && quantity <= 5,
        'Zerados' => quantity == 0,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estoque',
                        style: TextStyle(
                          color: navy,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Consulte os produtos da loja',
                        style: TextStyle(
                          color: muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          color: navy,
                          size: 17,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Loja 01',
                          style: TextStyle(
                            color: navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Pesquisa e scanner
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                          _expandedProductId = null;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Nome, referência ou cor',
                        hintStyle: const TextStyle(
                          color: muted,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: muted,
                        ),
                        suffixIcon: _searchText.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchText = '';
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: muted,
                                  size: 19,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: navy,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      onTap: _openScanner,
                      borderRadius: BorderRadius.circular(15),
                      child: const SizedBox(
                        width: 54,
                        height: 54,
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Filtros
              const Text(
                'Filtrar produtos',
                style: TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Todos', 'Baixo estoque', 'Zerados'].map(
                    (filter) {
                      final selected = _selectedFilter == filter;

                      return Padding(
                        padding: const EdgeInsets.only(right: 9),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedFilter = filter;
                              _expandedProductId = null;
                            });
                          },
                          showCheckmark: false,
                          selectedColor: navy,
                          backgroundColor: Colors.white,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : navy,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Identificação dos resultados
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Produtos',
                    style: TextStyle(
                      color: navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _isLoading
                        ? 'Carregando...'
                        : '${products.length} ${products.length == 1 ? 'produto' : 'produtos'}',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Lista, carregamento ou erro
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: blue,
                        ),
                      )
                    : _errorMessage != null
                        ? _buildErrorState()
                        : products.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                padding: const EdgeInsets.only(bottom: 12),
                                itemCount: products.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  final expanded =
                                      _expandedProductId == product['id'];

                                  return _buildProductCard(
                                    product,
                                    expanded,
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> product,
    bool expanded,
  ) {
    final quantity = product['quantity'] as int;
    final sizes = product['sizes'] as Map<String, int>;

    final statusColor = quantity == 0
        ? Colors.red
        : quantity <= 5
            ? Colors.orange.shade800
            : Colors.green.shade700;

    final statusText = quantity == 0
        ? 'Sem estoque'
        : quantity <= 5
            ? 'Estoque baixo'
            : 'Disponível';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: expanded
              ? blue.withValues(alpha: 0.45)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedProductId =
                    expanded ? null : product['id'] as int;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: product['imageUrl'] != null &&
                             (product['imageUrl'] as String).isNotEmpty
                          ? Image.network(
                            '${AuthService.baseUrl}${product['imageUrl']}',
                            width: 66,
                            height: 66,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported_outlined,
                                color: muted,
                                size: 32,
                               );
                              },
                            )
                          : const Icon(
                              Icons.directions_run_rounded,
                              color: navy,
                              size: 32,
                            )
                      ),
                    ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'].toString(),
                          style: const TextStyle(
                            color: navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${product['color']} · REF. ${product['reference']}',
                          style: const TextStyle(
                            color: muted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          color: navy,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'unidades',
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: muted,
                        size: 21,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Grade de tamanhos
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildSizeGrid(sizes),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeGrid(Map<String, int> sizes) {
    final sortedSizes = sizes.entries.toList()
      ..sort((a, b) {
        final aNumber = double.tryParse(a.key);
        final bNumber = double.tryParse(b.key);

        if (aNumber != null && bNumber != null) {
          return aNumber.compareTo(bNumber);
        }

        return a.key.compareTo(b.key);
      });

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: background),
          const SizedBox(height: 8),
          const Text(
            'Quantidade por tamanho',
            style: TextStyle(
              color: navy,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: sortedSizes.map((entry) {
              final available = entry.value > 0;

              return Container(
                width: 62,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: available
                      ? background
                      : const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: available
                        ? background
                        : const Color(0xFFFFD6D6),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${entry.value} un.',
                      style: TextStyle(
                        color: available ? muted : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 38,
                  color: navy,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _searchText.isNotEmpty
                    ? 'Nenhum resultado encontrado'
                    : 'Nenhum produto nesta categoria',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchText.isNotEmpty
                    ? 'Confira o nome, a referência ou a cor pesquisada.'
                    : 'Não encontramos produtos para este filtro.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Não foi possível carregar o estoque',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Verifique sua conexão com o servidor.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _carregarProdutos,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: navy,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
