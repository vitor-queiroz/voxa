import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerCodigoBarrasPage extends StatefulWidget {
  const ScannerCodigoBarrasPage({super.key});

  @override
  State<ScannerCodigoBarrasPage> createState() =>
      _ScannerCodigoBarrasPageState();
}

class _ScannerCodigoBarrasPageState
    extends State<ScannerCodigoBarrasPage> {
  static const navy = Color(0xFF142B4A);
  static const blue = Color(0xFF246BFD);

  late final MobileScannerController _controller;
  bool _codigoEncontrado = false;

  @override
  void initState() {
    super.initState();

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  Future<void> _aoDetectar(BarcodeCapture capture) async {
    if (_codigoEncontrado) return;

    for (final barcode in capture.barcodes) {
      final codigo = barcode.rawValue;

      if (codigo != null && codigo.trim().isNotEmpty) {
        _codigoEncontrado = true;

        await _controller.stop();

        if (!mounted) return;

        Navigator.pop(context, codigo.trim());
        return;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Escanear produto',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => _controller.toggleTorch(),
            icon: const Icon(Icons.flash_on_rounded),
            tooltip: 'Ligar ou desligar flash',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _aoDetectar,
          ),

          IgnorePointer(
            child: Center(
              child: Container(
                width: 290,
                height: 190,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: blue,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 55,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: navy.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Posicione o código de barras dentro da área de leitura.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
