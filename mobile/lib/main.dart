import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const VoxaApp());
}

class VoxaApp extends StatelessWidget {
  const VoxaApp({super.key});

  static const navy = Color(0xFF0B1B38);
  static const blue = Color(0xFF246BFD);
  static const background = Color(0xFFF5F7FC);
  static const muted = Color(0xFF758198);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VOXA Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          primary: blue,
        ),
        fontFamily: 'Roboto',
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _sellerCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberCode = false;

  @override
  void dispose() {
    _sellerCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    _showMessage(
      'A autenticação será integrada ao backend na próxima etapa.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cabeçalho azul-marinho.
                    SizedBox(
                      height: 280,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Positioned.fill(
                            child: Container(color: VoxaApp.navy),
                          ),
                          Positioned(
                            right: -65,
                            top: -105,
                            child: Container(
                              width: 225,
                              height: 225,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1B3158),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -35,
                            top: -75,
                            child: Container(
                              width: 165,
                              height: 165,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1B3158),
                                  width: 1.2,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              25, 30, 25, 28,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'V O X A',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.7,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Feche suas vendas\ncom agilidade.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 29,
                                    height: 1.13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Acesso exclusivo para vendedores.',
                                  style: TextStyle(
                                    color: Color(0xFFD2DDF0),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Formulário.
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        24, 25, 24, 30,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Bem-vindo de volta!',
                              style: TextStyle(
                                color: VoxaApp.navy,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Entre com suas credenciais de vendedor.',
                              style: TextStyle(
                                color: VoxaApp.muted,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 26),

                            _fieldLabel('CÓDIGO DO VENDEDOR'),
                            const SizedBox(height: 9),

                            TextFormField(
                              controller: _sellerCodeController,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration(
                                hint: 'Digite seu código',
                                icon: Icons.badge_outlined,
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Digite seu código de vendedor.';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            _fieldLabel('SENHA'),
                            const SizedBox(height: 9),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              style: const TextStyle(fontSize: 14),
                              decoration: _inputDecoration(
                                hint: 'Digite sua senha',
                                icon: Icons.lock_outline_rounded,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Mostrar senha'
                                      : 'Ocultar senha',
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 21,
                                    color: VoxaApp.muted,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Digite sua senha.';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberCode,
                                  activeColor: VoxaApp.blue,
                                  side: const BorderSide(
                                    color: Color(0xFFB8C2D2),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberCode = value ?? false;
                                    });
                                  },
                                ),
                                const Expanded(
                                  child: Text(
                                    'Lembrar meu código',
                                    style: TextStyle(
                                      color: VoxaApp.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              height: 54,
                              child: FilledButton(
                                onPressed: _login,
                                style: FilledButton.styleFrom(
                                  backgroundColor: VoxaApp.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: VoxaApp.blue.withValues(
                                    alpha: 0.25,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            Center(
                              child: TextButton(
                                onPressed: () {
                                  _showMessage(
                                    'A recuperação de senha será integrada '
                                    'ao backend.',
                                  );
                                },
                                child: const Text(
                                  'Esqueci minha senha',
                                  style: TextStyle(
                                    color: VoxaApp.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Center(
                              child: Text(
                                'Precisa de ajuda? Fale com seu gestor.',
                                style: TextStyle(
                                  color: VoxaApp.muted,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: VoxaApp.navy,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8A96AA),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF71809A),
        size: 21,
      ),
      filled: true,
      fillColor: const Color(0xFFF2F5FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE1E8F4),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE1E8F4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: VoxaApp.blue,
          width: 1.5,
        ),
      ),
      errorMaxLines: 2,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
