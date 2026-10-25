import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const navy = Color(0xFF142B4A);
  static const blue = Color(0xFF246BFD);
  static const background = Color(0xFFF5F7FB);
  static const muted = Color(0xFF758198);
  static const orange = Color(0xFFFFA51F);

  int _selectedIndex = 0;

  void _showPreviewMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature estará disponível nas próximas etapas.',
        ),
        behavior: SnackBarBehavior.floating,
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
            _buildDashboard(),
            _buildPlaceholder(
              Icons.inventory_2_outlined,
              'Estoque',
              'Pesquise produtos e consulte suas variantes.',
            ),
            _buildPlaceholder(
              Icons.qr_code_scanner_rounded,
              'Escanear produto',
              'A leitura de códigos será integrada nas próximas etapas.',
            ),
            _buildPlaceholder(
              Icons.shopping_cart_outlined,
              'Carrinho',
              'Os produtos selecionados aparecerão aqui.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: blue.withValues(alpha: 0.12),
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
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
            label: 'Carrinho',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Aviso para não confundir a prévia com dados reais.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: blue,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Prévia visual • Dados demonstrativos',
                        style: TextStyle(
                          color: navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cabeçalho do vendedor.
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: blue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'V',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, vendedor!',
                          style: TextStyle(
                            color: navy,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bem-vindo ao VOXA Mobile',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showPreviewMessage('Perfil'),
                    icon: const Icon(
                      Icons.person_outline_rounded,
                      color: navy,
                    ),
                    tooltip: 'Perfil',
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text(
                'Resumo de vendas',
                style: TextStyle(
                  color: navy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Acompanhe o desempenho do dia.',
                style: TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Cartão de vendas.
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: navy,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Total vendido hoje',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'R\$ 830,00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _buildSalesMetric('Vendas', '9'),
                        const SizedBox(width: 28),
                        _buildSalesMetric('Ticket médio', 'R\$ 92,22'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Gráfico por horário.
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE7EBF2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vendas por horário',
                      style: TextStyle(
                        color: navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 100,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar(30, '9h', false),
                          _buildBar(30, '10h', false),
                          _buildBar(48, '11h', false),
                          _buildBar(100, '13h', true),
                          _buildBar(55, '14h', false),
                          _buildBar(15, '15h', false),
                          _buildBar(32, '16h', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Exemplo ilustrativo de distribuição das vendas.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Alerta de estoque.
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estoque mínimo',
                            style: TextStyle(
                              color: navy,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Exemplo de alerta de reposição',
                            style: TextStyle(
                              color: navy,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 34,
                      color: navy,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Acesso destacado ao escaneamento.
              SizedBox(
                height: 62,
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() => _selectedIndex = 2);
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text(
                    'Escanear produto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'VOXA MOBILE',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String label, bool highlight) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: highlight
                        ? blue
                        : const Color(0xFFCBD7FA),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
