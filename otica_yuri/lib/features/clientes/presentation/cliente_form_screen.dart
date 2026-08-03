import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../data/cliente_model.dart';
import '../data/cliente_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_avatar.dart';

class ClienteFormScreen extends ConsumerStatefulWidget {
  final Cliente? cliente;

  const ClienteFormScreen({super.key, this.cliente});

  @override
  ConsumerState<ClienteFormScreen> createState() =>
      _ClienteFormScreenState();
}

class _ClienteFormScreenState extends ConsumerState<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _cpfCtrl;
  late final TextEditingController _rgCtrl;
  late final TextEditingController _telefoneCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _enderecoCtrl;
  late final TextEditingController _dataNascCtrl;
  DateTime? _dataNascimento;
  File? _fotoFile;
  bool _loading = false;
  String? _errorMessage;

  bool get _isEditing => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nomeCtrl = TextEditingController(text: c?.nome ?? '');
    _cpfCtrl = TextEditingController(text: c?.cpf ?? '');
    _rgCtrl = TextEditingController(text: c?.rg ?? '');
    _telefoneCtrl = TextEditingController(text: c?.telefone ?? '');
    _whatsappCtrl = TextEditingController(text: c?.whatsapp ?? '');
    _enderecoCtrl = TextEditingController(text: c?.endereco ?? '');
    _dataNascimento = c?.dataNascimento;
    _dataNascCtrl = TextEditingController(
      text: c?.dataNascimento != null
          ? DateFormat('dd/MM/yyyy').format(c!.dataNascimento!)
          : '',
    );
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _rgCtrl.dispose();
    _telefoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _enderecoCtrl.dispose();
    _dataNascCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFoto(ImageSource source) async {
    Navigator.pop(context);
    final picked = await ImagePicker()
        .pickImage(source: source, imageQuality: 80);
    if (picked != null && mounted) {
      setState(() => _fotoFile = File(picked.path));
    }
  }

  Future<void> _pickData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(1985),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _dataNascimento = picked;
        _dataNascCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(clienteRepositoryProvider);
      final data = <String, dynamic>{
        'nome': _nomeCtrl.text.trim(),
        'cpf': _cpfCtrl.text.trim(),
        if (_rgCtrl.text.trim().isNotEmpty) 'rg': _rgCtrl.text.trim(),
        'telefone': _telefoneCtrl.text.trim(),
        if (_whatsappCtrl.text.trim().isNotEmpty)
          'whatsapp': _whatsappCtrl.text.trim(),
        if (_dataNascimento != null) 'dataNascimento': _dataNascimento,
        if (_enderecoCtrl.text.trim().isNotEmpty)
          'endereco': _enderecoCtrl.text.trim(),
      };

      if (_isEditing) {
        if (_fotoFile != null) {
          final url =
              await repo.uploadFoto(widget.cliente!.id, _fotoFile!);
          data['fotoUrl'] = url;
        }
        await repo.atualizar(widget.cliente!.id, data);
      } else {
        final newId = await repo.criar(data);
        if (_fotoFile != null) {
          final url = await repo.uploadFoto(newId, _fotoFile!);
          await repo.atualizar(newId, {'fotoUrl': url});
        }
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Erro ao salvar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cliente' : 'Novo Cliente'),
        actions: [
          if (!_loading)
            TextButton(
              onPressed: _salvar,
              child: const Text(
                'SALVAR',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFotoSection(),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(_errorMessage!,
                          style:
                              const TextStyle(color: AppColors.error)),
                    ],
                    const SizedBox(height: 24),
                    _buildSection('Dados Pessoais', [
                      _field(
                        _nomeCtrl,
                        'Nome completo *',
                        Icons.person_outline,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Nome é obrigatório'
                                : null,
                      ),
                      _field(
                        _cpfCtrl,
                        'CPF *',
                        Icons.badge_outlined,
                        inputFormatters: [_CpfInputFormatter()],
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'CPF é obrigatório';
                          }
                          return _cpfValido(v) ? null : 'CPF inválido';
                        },
                      ),
                      _field(_rgCtrl, 'RG',
                          Icons.credit_card_outlined),
                      _dataNascimentoField(),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Contato', [
                      _field(
                        _telefoneCtrl,
                        'Telefone *',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Telefone é obrigatório'
                                : null,
                      ),
                      _field(
                        _whatsappCtrl,
                        'WhatsApp',
                        Icons.message_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection('Endereço', [
                      _field(
                        _enderecoCtrl,
                        'Endereço completo',
                        Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                    ]),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFotoSection() => Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: _showFotoOptions,
              child: Stack(
                children: [
                  _fotoFile != null
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(_fotoFile!),
                        )
                      : AppAvatar(
                          fotoUrl: widget.cliente?.fotoUrl,
                          nome: _nomeCtrl.text,
                          radius: 60,
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toque para adicionar foto',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );

  void _showFotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () => _pickFoto(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => _pickFoto(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> fields) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...fields.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12), child: f)),
        ],
      );

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
            labelText: label, prefixIcon: Icon(icon)),
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
      );

  Widget _dataNascimentoField() => GestureDetector(
        onTap: _pickData,
        child: AbsorbPointer(
          child: TextFormField(
            controller: _dataNascCtrl,
            decoration: const InputDecoration(
              labelText: 'Data de nascimento',
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
          ),
        ),
      );

  bool _cpfValido(String value) {
    final d = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length != 11) return false;
    if (d.split('').every((c) => c == d[0])) return false;
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(d[i]) * (10 - i);
    }
    int r1 = (soma * 10) % 11;
    if (r1 == 10 || r1 == 11) r1 = 0;
    if (r1 != int.parse(d[9])) return false;
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(d[i]) * (11 - i);
    }
    int r2 = (soma * 10) % 11;
    if (r2 == 10 || r2 == 11) r2 = 0;
    return r2 == int.parse(d[10]);
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    final digits =
        value.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited =
        digits.length > 11 ? digits.substring(0, 11) : digits;
    final buf = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 3 || i == 6) buf.write('.');
      if (i == 9) buf.write('-');
      buf.write(limited[i]);
    }
    final str = buf.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}
