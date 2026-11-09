import 'package:flutter/material.dart';

class IdentificarProdutoPage extends StatefulWidget {
  const IdentificarProdutoPage({super.key});

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

  @override
  void dispose() {
    _referenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
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

              // Área visual do scanner
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1C3D),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.barcode_reader,
                      color: Colors.white,
                      size: 100,
                    ),
                    Positioned(
                      top: 18,
                      right: 18,
                      child: Icon(
                        Icons.circle_outlined,
                        color: blue.withValues(alpha: 0.3),
                        size: 100,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Vamos conectar o leitor de código de barras nesta etapa.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Escanear código de barras'),
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

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

              const SizedBox(height: 16),

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
                decoration: InputDecoration(
                  hintText: 'Ex.: 12350011-1',
                  prefixIcon: const Icon(
                    Icons.tag,
                    color: muted,
                    size: 19,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // Pesquisa será implementada na próxima etapa.
                    },
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: navy,
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
            ],
          ),
        ),
      ),
    );
  }
}
