import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/cliente.dart';
import 'services/cliente_service.dart';

import 'cadastro_cliente_page.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({super.key});

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  final ClienteService _clienteService = ClienteService();
  final TextEditingController _cpfController = TextEditingController();

  Cliente? _clienteEncontrado;
  bool _carregando = false;
  bool _pesquisou = false;
  String? _mensagemErro;

  static const Color _navy = Color(0xFF172B4D);
  static const Color _blue = Color(0xFF246BFD);
  static const Color _background = Color(0xFFF5F7FB);

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  String get _cpfNumeros =>
      _cpfController.text.replaceAll(RegExp(r'\D'), '');

  bool _cpfValido(String cpf) {
    if (cpf.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return false;
    }

    int calcularDigito(String valor, int quantidade) {
      int soma = 0;

      for (int i = 0; i < quantidade; i++) {
        soma += int.parse(valor[i]) * (quantidade + 1 - i);
      }

      final resto = (soma * 10) % 11;
      return resto == 10 ? 0 : resto;
    }

    return calcularDigito(cpf, 9) == int.parse(cpf[9]) &&
        calcularDigito(cpf, 10) == int.parse(cpf[10]);
  }



  Future<void> _pesquisarCliente() async {
    FocusScope.of(context).unfocus();

    final cpf = _cpfNumeros;

    setState(() {
      _clienteEncontrado = null;
      _mensagemErro = null;
      _pesquisou = false;
    });

    if (!_cpfValido(cpf)) {
      setState(() {
        _mensagemErro = 'CPF inválido. Verifique os números digitados.';
        _pesquisou = true;
      });
      return;
    }

    setState(() => _carregando = true);

    try {
      final cliente = await _clienteService.buscarPorCpf(cpf);

      if (!mounted) return;

      setState(() {
        _clienteEncontrado = cliente;
        _pesquisou = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _mensagemErro = e.toString().replaceFirst('Exception: ', '');
        _pesquisou = true;
      });
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _selecionarCliente() {
    if (_clienteEncontrado != null) {
      Navigator.pop(context, _clienteEncontrado);
    }
  }

  void _continuarSemCadastro() {
    Navigator.pop(context, false);
  }

  Future<void> _abrirCadastro() async {
    final cliente = await Navigator.push<Cliente>(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroClientePage(
          cpfInicial: _cpfNumeros,
        ),
      ),
    );

  if (!mounted) return;

  if (cliente != null) {
    Navigator.pop(context, cliente);
  }
}

  Widget _buildCampoCpf() {
    return TextField(
      controller: _cpfController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CpfInputFormatter(),
      ],
      onChanged: (_) {
        setState(() {
          _clienteEncontrado = null;
          _mensagemErro = null;
          _pesquisou = false;
        });
      },
      decoration: InputDecoration(
        labelText: 'CPF do cliente',
        hintText: '000.000.000-00',
        prefixIcon: const Icon(Icons.badge_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE3E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildClienteEncontrado() {
    final cliente = _clienteEncontrado!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9E8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Cliente encontrado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            cliente.nome,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
          const SizedBox(height: 8),
          if (cliente.cpf != null)
            _linhaInformacao(Icons.badge_outlined, cliente.cpf!),
          if (cliente.telefone != null)
            _linhaInformacao(Icons.phone_outlined, cliente.telefone!),
          if (cliente.email != null)
            _linhaInformacao(Icons.email_outlined, cliente.email!),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selecionarCliente,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Selecionar cliente',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _linhaInformacao(IconData icone, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icone, size: 17, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClienteNaoEncontrado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E8F0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_search_outlined,
            size: 42,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 12),
          const Text(
            'Cliente não possui cadastro',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Você pode cadastrar este cliente ou continuar a venda sem cadastro.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _abrirCadastro,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Fazer cadastro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _continuarSemCadastro,
              style: OutlinedButton.styleFrom(
                foregroundColor: _navy,
                backgroundColor: Colors.white,
                side: const BorderSide(
                    color: Color(0xFFD9E1EC),
                    width: 1,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continuar sem cadastro',
                style: TextStyle(
                 fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        title: const Text(
          'Cliente / Cadastro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Identificar cliente',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Informe o CPF para localizar o cadastro do cliente.',
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 24),
              _buildCampoCpf(),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _pesquisarCliente,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          height: 21,
                          width: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Pesquisar cliente',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              if (_mensagemErro != null) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _mensagemErro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
              if (_pesquisou && _clienteEncontrado != null) ...[
                const SizedBox(height: 22),
                _buildClienteEncontrado(),
              ],
              if (_pesquisou &&
                  _clienteEncontrado == null &&
                  _mensagemErro == null) ...[
                const SizedBox(height: 22),
                _buildClienteNaoEncontrado(),
              ],
              const SizedBox(height: 28),
              Center(
                child: TextButton(
                  onPressed: _continuarSemCadastro,
                  child: const Text(
                    'Continuar sem informar cliente',
                    style: TextStyle(color: Colors.blueGrey),
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

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = newValue.text;
    final numeros = texto.replaceAll(RegExp(r'\D'), '');

    final cpf = numeros.length > 11 ? numeros.substring(0, 11) : numeros;

    final formatado = cpf.isEmpty
        ? ''
        : _formatar(cpf);

    return TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(offset: formatado.length),
    );
  }

  String _formatar(String cpf) {
    if (cpf.length <= 3) return cpf;
    if (cpf.length <= 6) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3)}';
    }
    if (cpf.length <= 9) {
      return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6)}';
    }
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }
}
