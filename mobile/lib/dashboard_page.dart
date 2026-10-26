import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const navy = Color(0xFF142B4A);
  static const blue = Color(0xFF246BFD);
  static const background = Color(0xFFF5F7FB);
  static const muted = Color(0xFF758198);
  static const green = Color(0xFF27966A);
  static const cyan = Color(0xFF08A9D6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Visão geral',
              style: TextStyle(
                color: navy,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Acompanhe o desempenho das suas vendas.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
            const SizedBox(height: 22),

            // Indicadores principais
            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    title: 'Vendas realizadas',
                    value: '9',
                    subtitle: 'Hoje',
                    color: blue,
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _metricCard(
                    title: 'Faturamento',
                    value: 'R\$ 830',
                    subtitle: 'Hoje',
                    color: cyan,
                    icon: Icons.attach_money_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _metricCard(
              title: 'Ticket médio',
              value: 'R\$ 92,22',
              subtitle: 'Valor médio por venda',
              color: green,
              icon: Icons.trending_up_rounded,
              horizontal: true,
            ),
            const SizedBox(height: 24),

            // Gráfico de faturamento
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vendas por horário',
                    style: TextStyle(
                      color: navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Distribuição ilustrativa ao longo do dia',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 165,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _bar(42, '09h'),
                        _bar(65, '10h'),
                        _bar(48, '11h'),
                        _bar(105, '12h'),
                        _bar(140, '13h', highlight: true),
                        _bar(82, '14h'),
                        _bar(58, '15h'),
                        _bar(32, '16h'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: Color(0xFFE7EBF2)),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: muted,
                        size: 17,
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Gráfico demonstrativo. Os dados reais '
                          'serão integrados à API.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Resumo adicional
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _cardDecoration(),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo do dia',
                    style: TextStyle(
                      color: navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14),
                  _SummaryRow(
                    icon: Icons.receipt_long_outlined,
                    label: 'Vendas concluídas',
                    value: '9',
                  ),
                  SizedBox(height: 14),
                  _SummaryRow(
                    icon: Icons.payments_outlined,
                    label: 'Faturamento total',
                    value: 'R\$ 830,00',
                  ),
                  SizedBox(height: 14),
                  _SummaryRow(
                    icon: Icons.calculate_outlined,
                    label: 'Ticket médio',
                    value: 'R\$ 92,22',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
          ],
        ),
      ),
    );
  }

  static BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE7EBF2)),
    );
  }

  static Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
    bool horizontal = false,
  }) {
    if (horizontal) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 23),
          const SizedBox(height: 17),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bar(
    double height,
    String label, {
    bool highlight = false,
  }) {
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
                    color: highlight ? blue : const Color(0xFFCBD7FA),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: muted, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: DashboardPage.blue, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: DashboardPage.muted,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: DashboardPage.navy,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}