import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'models/cliente.dart';
import 'services/cliente_service.dart';

class CadastroClientePage extends StatefulWidget {
  final String? cpfInicial;
  final Cliente? cliente;

  const CadastroClientePage({
    super.key,
    this.cpfInicial,
    this.cliente,
  });

  @override
  State<CadastroClientePage> createState() =>
      _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formKey = GlobalKey<FormState>();
  final ClienteService _clienteService = ClienteService();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();

  String? _estadoSelecionado;

  bool _consultandoCep = false;
  bool _salvando = false;

  // Guarda se o último CEP consultado foi identificado como inexistente.
  String? _cepInvalido;

  static const Color _navy = Color(0xFF172B4D);
  static const Color _blue = Color(0xFF246BFD);
  static const Color _background = Color(0xFFF5F7FB);

  static const List<String> _estados = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF',
    'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA',
    'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS',
    'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  ];

  @override
  void initState() {
    super.initState();

    final cliente = widget.cliente;

    if (cliente != null) {
      _nomeController.text = cliente.nome;
      _cpfController.text = cliente.cpf ?? '';
      _telefoneController.text = cliente.telefone ?? '';
      _emailController.text = cliente.email ?? '';
      _cepController.text = cliente.cep ?? '';
      _logradouroController.text = cliente.logradouro ?? '';
      _numeroController.text = cliente.numero ?? '';
      _complementoController.text = cliente.complemento ?? '';
      _bairroController.text = cliente.bairro ?? '';
      _cidadeController.text = cliente.cidade ?? '';

      _estadoSelecionado = cliente.estado;
    } else {
      _cpfController.text = widget.cpfInicial ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();

    super.dispose();
  }

  String? _textoOuNull(String valor) {
    final texto = valor.trim();
    return texto.isEmpty ? null : texto;
  }

  String? _validarEmail(String? valor) {
    final email = valor?.trim() ?? '';

    if (email.isEmpty) {
      return null;
    }

    final regex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!regex.hasMatch(email) || email.contains('..')) {
      return 'Informe um e-mail válido (ex.: nome@dominio.com).';
    }

    return null;
  }

  void _limparEnderecoDoCep() {
    _logradouroController.clear();
    _bairroController.clear();
    _cidadeController.clear();
    _estadoSelecionado = null;
  }

  void _aoAlterarCep(String valor) {
    final cep = valor.replaceAll(RegExp(r'\D'), '');

    setState(() {
      if (cep.isEmpty) {
        _limparEnderecoDoCep();
        _cepInvalido = null;
      } else if (_cepInvalido != null && _cepInvalido != cep) {
        _cepInvalido = null;
      }
    });
  }

  Future<void> _consultarCep() async {
    FocusScope.of(context).unfocus();

    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');

    if (cep.length != 8) {
      _mostrarMensagem(
        'Informe um CEP com exatamente 8 números.',
        erro: true,
      );
      return;
    }

    setState(() {
      _consultandoCep = true;
      _cepInvalido = null;
    });

    try {
      final url = Uri.parse(
        'https://viacep.com.br/ws/$cep/json/',
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode != 200) {
        _mostrarMensagem(
          'Não foi possível consultar o CEP. Preencha o endereço manualmente.',
          erro: true,
        );
        return;
      }

      final dados = jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;

      // O ViaCEP informa explicitamente quando o CEP não existe.
      if (dados['erro'] == true) {
        setState(() {
          _cepInvalido = cep;
        });

        _mostrarMensagem(
          'CEP inexistente. Confira os números e tente novamente.',
          erro: true,
        );
        return;
      }

      final logradouro =
          dados['logradouro']?.toString().trim() ?? '';

      final bairro =
          dados['bairro']?.toString().trim() ?? '';

      final cidade =
          dados['localidade']?.toString().trim() ?? '';

      final uf = dados['uf']?.toString().trim() ?? '';

      // Verifica se a consulta trouxe alguma informação útil.
      final possuiDados = logradouro.isNotEmpty ||
          bairro.isNotEmpty ||
          cidade.isNotEmpty ||
          uf.isNotEmpty;

      if (!possuiDados) {
        setState(() {
          _cepInvalido = cep;
        });

        _mostrarMensagem(
          'Não foi possível localizar dados para esse CEP. Confira o número.',
          erro: true,
        );
        return;
      }

      setState(() {
        // Substitui os dados anteriores pelos dados do novo CEP.
        _logradouroController.text = logradouro;
        _bairroController.text = bairro;
        _cidadeController.text = cidade;

        _estadoSelecionado =
            _estados.contains(uf) ? uf : null;

        _cepInvalido = null;
      });

      final enderecoCompleto = logradouro.isNotEmpty &&
          bairro.isNotEmpty &&
          cidade.isNotEmpty &&
          _estados.contains(uf);

      if (enderecoCompleto) {
        _mostrarMensagem('Endereço preenchido pelo CEP.');
      } else {
        _mostrarMensagem(
          'CEP localizado, mas o endereço está incompleto. Confira e complete os dados.',
          erro: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _mostrarMensagem(
          'Não foi possível consultar o CEP. Você pode preencher o endereço manualmente.',
          erro: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _consultandoCep = false);
      }
    }
  }

  String? _validarEndereco() {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');

    final logradouro = _logradouroController.text.trim();
    final numero = _numeroController.text.trim();
    final complemento = _complementoController.text.trim();
    final bairro = _bairroController.text.trim();
    final cidade = _cidadeController.text.trim();
    final estado = _estadoSelecionado;

    final enderecoIniciado = cep.isNotEmpty ||
        logradouro.isNotEmpty ||
        numero.isNotEmpty ||
        complemento.isNotEmpty ||
        bairro.isNotEmpty ||
        cidade.isNotEmpty ||
        estado != null;

    // O cliente pode ser cadastrado sem endereço.
    if (!enderecoIniciado) {
      return null;
    }

    if (cep.isEmpty) {
      return 'Informe o CEP para cadastrar o endereço.';
    }

    if (cep.length != 8) {
      return 'O CEP deve conter exatamente 8 números.';
    }

    if (_cepInvalido == cep) {
      return 'Esse CEP não foi localizado. Confira o número antes de salvar.';
    }

    if (logradouro.isEmpty) {
      return 'Informe a rua ou o logradouro.';
    }

    if (bairro.isEmpty) {
      return 'Informe o bairro.';
    }

    if (cidade.isEmpty) {
      return 'Informe a cidade.';
    }

    if (estado == null || !_estados.contains(estado)) {
      return 'Selecione o estado do endereço.';
    }

    return null;
  }

  Future<void> _salvarCliente() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final erroEndereco = _validarEndereco();

    if (erroEndereco != null) {
      _mostrarMensagem(erroEndereco, erro: true);
      return;
    }

    setState(() => _salvando = true);

    try {
      final cpf = _textoOuNull(_cpfController.text);
      final clienteExistente = widget.cliente;

      late final Cliente cliente;

      if (clienteExistente == null) {
        cliente = await _clienteService.cadastrar(
          nome: _nomeController.text.trim(),
          cpf: cpf,
          telefone: _textoOuNull(_telefoneController.text),
          email: _textoOuNull(_emailController.text),
          cep: _textoOuNull(_cepController.text),
          logradouro: _textoOuNull(_logradouroController.text),
          numero: _textoOuNull(_numeroController.text),
          complemento: _textoOuNull(_complementoController.text),
          bairro: _textoOuNull(_bairroController.text),
          cidade: _textoOuNull(_cidadeController.text),
          estado: _estadoSelecionado,
        );
      } else {
        cliente = await _clienteService.atualizar(
          id: clienteExistente.id,
          nome: _nomeController.text.trim(),
          cpf: cpf,
          telefone: _textoOuNull(_telefoneController.text),
          email: _textoOuNull(_emailController.text),
          cep: _textoOuNull(_cepController.text),
          logradouro: _textoOuNull(_logradouroController.text),
          numero: _textoOuNull(_numeroController.text),
          complemento: _textoOuNull(_complementoController.text),
          bairro: _textoOuNull(_bairroController.text),
          cidade: _textoOuNull(_cidadeController.text),
          estado: _estadoSelecionado,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, cliente);
    } catch (e) {
      if (!mounted) return;

      _mostrarMensagem(
        e.toString().replaceFirst('Exception: ', ''),
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  void _mostrarMensagem(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro ? Colors.red : _navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _decoracao(
    String label, {
    String? hint,
    IconData? icone,
    Widget? sufixo,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icone != null ? Icon(icone) : null,
      suffixIcon: sufixo,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE3E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _blue,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _campoTexto(
    String label,
    TextEditingController controller, {
    String? hint,
    IconData? icone,
    TextInputType? tipoTeclado,
    List<TextInputFormatter>? formatadores,
    String? Function(String?)? validador,
    int maxLinhas = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: tipoTeclado,
      inputFormatters: formatadores,
      maxLines: maxLinhas,
      validator: validador,
      decoration: _decoracao(
        label,
        hint: hint,
        icone: icone,
      ),
    );
  }

  Widget _tituloSecao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 22,
        bottom: 12,
      ),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _navy,
        ),
      ),
    );
  }

  Widget _buildCep() {
    return TextFormField(
      controller: _cepController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
      ],
      decoration: _decoracao(
        'CEP',
        hint: '00000000',
        icone: Icons.location_on_outlined,
        sufixo: IconButton(
          onPressed: _consultandoCep ? null : _consultarCep,
          icon: _consultandoCep
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.search,
                  color: _blue,
                ),
          tooltip: 'Consultar CEP',
        ),
      ),
      onChanged: _aoAlterarCep,
      onFieldSubmitted: (_) => _consultarCep(),
    );
  }

  Widget _buildEstado() {
    return DropdownButtonFormField<String>(
      initialValue: _estadoSelecionado,
      decoration: _decoracao(
        'Estado',
        icone: Icons.map_outlined,
      ),
      hint: const Text('UF'),
      isExpanded: true,
      items: _estados.map((estado) {
        return DropdownMenuItem(
          value: estado,
          child: Text(estado),
        );
      }).toList(),
      onChanged: (valor) {
        setState(() => _estadoSelecionado = valor);
      },
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
        title: Text(
          widget.cliente == null
              ? 'Cadastrar cliente'
              : 'Editar cliente',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dados do cliente',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: _navy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.cliente == null
                      ? 'Preencha os dados para cadastrar o cliente.'
                      : 'Atualize as informações cadastrais do cliente.',
                  style: const TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),

                _tituloSecao('Informações pessoais'),

                _campoTexto(
                  'Nome completo *',
                  _nomeController,
                  icone: Icons.person_outline,
                  validador: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o nome do cliente.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                _campoTexto(
                  'CPF (opcional)',
                  _cpfController,
                  hint: 'Somente números',
                  icone: Icons.badge_outlined,
                  tipoTeclado: TextInputType.number,
                  formatadores: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),

                const SizedBox(height: 14),

                _campoTexto(
                  'Telefone',
                  _telefoneController,
                  tipoTeclado: TextInputType.phone,
                  icone: Icons.phone_outlined,
                ),

                const SizedBox(height: 14),

                _campoTexto(
                  'E-mail',
                  _emailController,
                  tipoTeclado: TextInputType.emailAddress,
                  icone: Icons.email_outlined,
                  validador: _validarEmail,
                ),

                _tituloSecao('Endereço'),

                _buildCep(),

                const SizedBox(height: 14),

                _campoTexto(
                  'Rua / Logradouro',
                  _logradouroController,
                  icone: Icons.signpost_outlined,
                ),

                const SizedBox(height: 14),

                _campoTexto(
                  'Número',
                  _numeroController,
                  tipoTeclado: TextInputType.text,
                  icone: Icons.home_outlined,
                ),

                const SizedBox(height: 14),

                _campoTexto(
                  'Complemento',
                  _complementoController,
                  icone: Icons.apartment_outlined,
                ),

                const SizedBox(height: 14),

                _campoTexto(
                  'Bairro',
                  _bairroController,
                  icone: Icons.location_city_outlined,
                ),

                const SizedBox(height: 14),

                _campoTexto(
                  'Cidade',
                  _cidadeController,
                  icone: Icons.location_city,
                ),

                const SizedBox(height: 14),

                _buildEstado(),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _salvando ? null : _salvarCliente,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          _blue.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _salvando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.cliente == null
                                ? 'Salvar cliente'
                                : 'Salvar alterações',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
