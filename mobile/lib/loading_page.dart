import 'package:flutter/material.dart';
import 'home_page.dart';

class LoadingPage extends StatefulWidget {
  final String sellerName;
  final String? photoUrl;

  const LoadingPage({
    super.key,
    required this.sellerName,
    this.photoUrl,
  });

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  static const navy = Color(0xFF0B1B38);
  static const blue = Color(0xFF246BFD);

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Stack(
          children: [
            // Elementos circulares da identidade visual.
            Positioned(
              right: -100,
              top: -80,
              child: _circle(260),
            ),
            Positioned(
              left: -110,
              bottom: -90,
              child: _circle(260),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 45),

                  const Text(
                    'V O X A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),

                  const Spacer(),

                  // Foto do vendedor, quando a API fornecer a URL.
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: 150,
                        height: 150,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: blue.withValues(
                              alpha: 0.35 +
                                  (_controller.value * 0.65),
                            ),
                            width: 3,
                          ),
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF192E50),
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.photoUrl != null &&
                              widget.photoUrl!.isNotEmpty
                          ? Image.network(
                              widget.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _defaultAvatar(),
                            )
                          : _defaultAvatar(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Seja bem-vindo${_isFeminine(widget.sellerName) ? 'a' : ''}, '
                    '${widget.sellerName}!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Estamos preparando seu ambiente de trabalho...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFD2DDF0),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 30),

                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: _controller.value,
                          minHeight: 7,
                          backgroundColor: const Color(0xFF263B60),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4F83FF),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  const Row(
                    children: [
                      Text(
                        'Preparando seu perfil...',
                        style: TextStyle(
                          color: Color(0xFFD2DDF0),
                          fontSize: 11,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF82A7FF),
                        size: 17,
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text(
                      'VOXA MOBILE',
                      style: TextStyle(
                        color: Color(0xFF8296B9),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF1B3158),
          width: 1.2,
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return const Icon(
      Icons.person_outline_rounded,
      color: Color(0xFF8EADFF),
      size: 72,
    );
  }

  bool _isFeminine(String name) {
    // Apenas um ajuste visual para nomes terminados em "a".
    // Podemos substituir isso pelo tratamento definido no perfil da API.
    return name.trim().toLowerCase().endsWith('a');
  }
}
