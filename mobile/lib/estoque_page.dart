import 'package:flutter/material.dart';

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

  String _selectedFilter = 'Todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Estoque',
                    style: TextStyle(
                      color: navy,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Loja 01',
                    style: TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Referência, nome ou cor',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: navy,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Wrap(
                spacing: 9,
                children: ['Todos', 'Baixo estoque', 'Zerados'].map(
                  (filter) {
                    final selected = _selectedFilter == filter;

                    return ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: navy,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : navy,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Colors.white,
                    );
                  },
                ).toList(),
              ),

              const SizedBox(height: 24),

              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 55,
                        color: muted,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Sua consulta de estoque começa aqui',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Os produtos serão carregados do VOXA.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
