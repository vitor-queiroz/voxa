
import 'package:flutter/material.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  void _message(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature será integrado nas próximas etapas.',
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHome(),
            _buildPlaceholder(
              Icons.inventory_2_outlined,
              'Estoque',
              'Consulte produtos, referências e variantes.',
            ),
            _buildScanner(),
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
            selectedIcon: Icon(Icons.shopping_cart_rounded),
            label: 'Carrinho',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        // Cabeçalho e cartão sobreposto.
        SliverToBoxAdapter(
          child: SizedBox(
            // Altura total reservada para o cabeçalho + cartão.
            height: 310,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 235,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    22, 18, 22, 0,
                  ),
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
                      const Text(
                        'Olá, Gisele!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Código do vendedor: 0042 (exemplo)',
                        style: TextStyle(
                          color: Color(0xFFD2DFF3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // O cartão ultrapassa o limite inferior do azul.
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

        // Conteúdo principal.
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

              // Ação principal de escaneamento.
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
                        onTap: () {
                          setState(() => _selectedIndex = 2);
                        },
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

              // Atalhos.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.search_rounded,
                      title: 'Buscar produto',
                      subtitle: 'Por referência',
                      onTap: () => _message('Busca por referência'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.inventory_2_outlined,
                      title: 'Consultar',
                      subtitle: 'Estoque',
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Atalho para o dashboard completo.
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

  Widget _buildScanner() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: blue.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: blue,
                size: 46,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Escanear produto',
              style: TextStyle(
                color: navy,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Escolha como deseja localizar o produto.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _message('Leitura pela câmera'),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Ler código pela câmera'),
                style: FilledButton.styleFrom(
                  backgroundColor: blue,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _message('Busca manual por referência'),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Buscar por referência'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: navy,
                  padding: const EdgeInsets.all(16),
                ),
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
