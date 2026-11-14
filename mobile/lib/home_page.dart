import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'estoque_page.dart';
import 'identificar_produto_page.dart';
import 'models/produto_variacao.dart';
import 'services/auth_service.dart';

class HomePage extends StatefulWidget {
  final String sellerName;
  final String sellerCode;

  const HomePage({
    super.key,
    required this.sellerName,
    required this.sellerCode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const navy = Color(0xFF142B4A);
  static const blue = Color(0xFF246BFD);
  static const background = Color(0xFFF3F6FC);
  static const muted = Color(0xFF758198);
  static const green = Color(0xFF21C779);

  int _selectedIndex = 0;

  // Carrinho compartilhado entre as telas.
  final Map<int, _ItemCarrinho> _itensCarrinho = {};

  void _message(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature será integrado nas próximas etapas.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const DashboardPage(),
      ),
    );
  }

  void _openIdentificarProduto() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _openEstoque() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  // Adiciona uma variação ao carrinho.
  void _adicionarAoCarrinho(ProdutoVariacao variacao) {
    final estoqueDisponivel = variacao.quantidade ?? 0;

    if (estoqueDisponivel <= 0) {
      _message('Produto sem estoque');
      return;
    }

  // Não permite adicionar a mesma variação duas vezes.
    if (_itensCarrinho.containsKey(variacao.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este produto já está no carrinho. Ajuste a quantidade por lá.',
          ),
        behavior: SnackBarBehavior.floating,
       ),
     );
     return;
    }

    setState(() {
      _itensCarrinho[variacao.id] = _ItemCarrinho(
        variacao: variacao,
        quantidade: 1,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produto adicionado ao carrinho!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Formata valores em reais.
  String _formatarMoeda(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final inteiro = partes[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

    return 'R\$ $inteiro,${partes[1]}';
  }

  // Confirma a remoção de um produto.
  Future<void> _confirmarRemocao(_ItemCarrinho item) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Remover produto?',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Deseja realmente remover '
            '${item.variacao.produto.nome} do carrinho?',
            style: const TextStyle(
              color: muted,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: muted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && mounted) {
      setState(() {
        _itensCarrinho.remove(item.variacao.id);
      });
    }
  }

  // Diminui a quantidade ou pede confirmação para remover.
  void _diminuirQuantidade(_ItemCarrinho item) {
    if (item.quantidade == 1) {
      _confirmarRemocao(item);
      return;
    }

    setState(() {
      item.quantidade--;
    });
  }

  // Aumenta respeitando o estoque disponível.
  void _aumentarQuantidade(_ItemCarrinho item) {
    final estoqueDisponivel = item.variacao.quantidade ?? 0;

    if (item.quantidade >= estoqueDisponivel) {
      _message('Limite de estoque atingido');
      return;
    }

    setState(() {
      item.quantidade++;
    });
  }

  // Exibe a imagem do produto.
  Widget _buildImagemCarrinho(ProdutoVariacao produto) {
    final caminho = produto.imagemUrl;

    final imagemUrl = caminho == null
        ? null
        : caminho.startsWith('http')
            ? caminho
            : '${AuthService.baseUrl}$caminho';

    return Container(
      width: 86,
      height: 86,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: imagemUrl == null
          ? const Icon(
              Icons.shopping_bag_outlined,
              color: muted,
              size: 35,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.network(
                imagemUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported_outlined,
                    color: muted,
                    size: 32,
                  );
                },
              ),
            ),
    );
  }

  // Controle visual de quantidade.
  Widget _buildControleQuantidade(_ItemCarrinho item) {
    final estoqueDisponivel = item.variacao.quantidade ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _diminuirQuantidade(item),
            icon: const Icon(Icons.remove_rounded),
            color: navy,
            iconSize: 19,
            constraints: const BoxConstraints(
              minWidth: 38,
              minHeight: 38,
            ),
          ),
          SizedBox(
            width: 25,
            child: Text(
              '${item.quantidade}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: item.quantidade >= estoqueDisponivel
                ? null
                : () => _aumentarQuantidade(item),
            icon: const Icon(Icons.add_rounded),
            color: blue,
            disabledColor: muted,
            iconSize: 19,
            constraints: const BoxConstraints(
              minWidth: 38,
              minHeight: 38,
            ),
          ),
        ],
      ),
    );
  }

  // Cartão individual do produto.
  Widget _buildCardCarrinho(_ItemCarrinho item) {
    final produto = item.variacao;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE8EDF5),
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildImagemCarrinho(produto),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        produto.produto.nome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _confirmarRemocao(item),
                      icon: const Icon(Icons.close_rounded),
                      color: muted,
                      iconSize: 20,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${produto.cor} • Tamanho ${produto.tamanho}',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    _buildControleQuantidade(item),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        _formatarMoeda(
                          produto.preco * item.quantidade,
                        ),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHome(),
            const EstoquePage(),
            IdentificarProdutoPage(
              variacoesNoCarrinho: _itensCarrinho.keys.toSet(),
              onAdicionarCarrinho: _adicionarAoCarrinho,
            ),
            _buildCarrinho(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: blue.withValues(alpha: 0.12),
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2_rounded),
            label: 'Estoque',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Escanear',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart_rounded),
            label: 'Carrinho',
          ),
        ],
      ),
    );
  }

  // TELA INICIAL
  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 310,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 235,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  decoration: const BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'V O X A   M O B I L E',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.circle,
                            color: green,
                            size: 8,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Conexão',
                            style: TextStyle(
                              color: green,
                              fontSize: 11,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _message('Perfil'),
                            tooltip: 'Perfil do vendedor',
                            icon: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Olá, ${widget.sellerName}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Código do vendedor: ${widget.sellerCode}',
                        style: const TextStyle(
                          color: Color(0xFFD2DFF3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 174,
                  left: 20,
                  right: 20,
                  child: _buildSalesCard(),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              const Text(
                'O que você deseja fazer?',
                style: TextStyle(
                  color: navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Material(
                      color: blue,
                      elevation: 6,
                      shadowColor: blue.withValues(alpha: 0.22),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _openIdentificarProduto,
                        child: const SizedBox(
                          width: 132,
                          height: 132,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Colors.white,
                                size: 47,
                              ),
                              SizedBox(height: 9),
                              Text(
                                'ESCANEAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Leia o código de um produto',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.search_rounded,
                      title: 'Buscar produto',
                      subtitle: 'Por referência',
                      onTap: _openIdentificarProduto,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.inventory_2_outlined,
                      title: 'Consultar',
                      subtitle: 'Estoque',
                      onTap: _openEstoque,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: _openDashboard,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE5EAF3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EEFF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            color: blue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Desempenho de vendas',
                                style: TextStyle(
                                  color: navy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Gráfico e indicadores do dia',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'V O X A   M O B I L E',
                  style: TextStyle(
                    color: Color(0xFF8CA0C1),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  // CARD DE VENDAS
  Widget _buildSalesCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(19, 17, 19, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE9EDF5),
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.13),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: blue,
                size: 21,
              ),
              SizedBox(width: 8),
              Text(
                'Total vendido hoje',
                style: TextStyle(
                  color: Color(0xFF58739C),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'R\$ 830,00',
            style: TextStyle(
              color: navy,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: const Color(0xFFDCE5F4),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF58739C),
                size: 19,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Vendas realizadas',
                  style: TextStyle(
                    color: Color(0xFF58739C),
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '9',
                style: TextStyle(
                  color: navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Valores demonstrativos',
            style: TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ATALHOS DA HOME
  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5EAF3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8EEFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: blue, size: 23),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CARRINHO
  Widget _buildCarrinho() {
    if (_itensCarrinho.isEmpty) {
      return _buildPlaceholder(
        Icons.shopping_cart_outlined,
        'Carrinho vazio',
        'Os produtos selecionados aparecerão aqui.',
      );
    }

    final total = _itensCarrinho.values.fold<double>(
      0,
      (soma, item) =>
          soma + item.variacao.preco * item.quantidade,
    );

    final totalUnidades = _itensCarrinho.values.fold<int>(
      0,
      (soma, item) => soma + item.quantidade,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Carrinho',
                      style: TextStyle(
                        color: navy,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_itensCarrinho.length} produtos • '
                      '$totalUnidades '
                      '${totalUnidades == 1 ? 'unidade' : 'unidades'}',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: blue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  color: blue,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            itemCount: _itensCarrinho.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _itensCarrinho.values.elementAt(index);
              return _buildCardCarrinho(item);
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 19, 20, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total da compra',
                      style: TextStyle(
                        color: navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatarMoeda(total),
                    style: const TextStyle(
                      color: blue,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: OutlinedButton.icon(
                  onPressed: () => _message('Cliente / Cadastro'),
                  icon: const Icon(
                    Icons.person_add_alt_1_rounded,
                  ),
                  label: const Text('Cliente / Cadastro'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: navy,
                    side: const BorderSide(
                      color: Color(0xFFB8C8E0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 51,
                child: ElevatedButton.icon(
                  onPressed: () => _message('Finalizar venda'),
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                  ),
                  label: const Text('Finalizar venda'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // PLACEHOLDER
  Widget _buildPlaceholder(
    IconData icon,
    String title,
    String description,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 62, color: blue),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: navy,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Interface em desenvolvimento',
              style: TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MODELO INTERNO DO CARRINHO
class _ItemCarrinho {
  final ProdutoVariacao variacao;
  int quantidade;

  _ItemCarrinho({
    required this.variacao,
    required this.quantidade,
  });
}
