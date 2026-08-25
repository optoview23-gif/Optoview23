import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../data/receita_model.dart';
import '../data/receita_repository.dart';
import '../../../core/constants/app_colors.dart';

class ReceitaFormScreen extends ConsumerStatefulWidget {
  final String clienteId;
  final Receita? receita;

  const ReceitaFormScreen(
      {super.key, required this.clienteId, this.receita});

  @override
  ConsumerState<ReceitaFormScreen> createState() =>
      _ReceitaFormScreenState();
}

class _ReceitaFormScreenState
    extends ConsumerState<ReceitaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _optometristaCtrl;
  late final TextEditingController _dataCtrl;
  late final TextEditingController _observacoesCtrl;

  // OD
  late final TextEditingController _odEsfCtrl;
  late final TextEditingController _odCilCtrl;
  late final TextEditingController _odEixoCtrl;
  late final TextEditingController _odAddCtrl;
  late final TextEditingController _odDnpCtrl;

  // OE
  late final TextEditingController _oeEsfCtrl;
  late final TextEditingController _oeCilCtrl;
  late final TextEditingController _oeEixoCtrl;
  late final TextEditingController _oeAddCtrl;
  late final TextEditingController _oeDnpCtrl;

  DateTime _data = DateTime.now();
  File? _fotoFile;
  bool _loading = false;
  String? _errorMessage;

  bool get _isEditing => widget.receita != null;

  @override
  void initState() {
    super.initState();
    final r = widget.receita;
    _data = r?.data ?? DateTime.now();
    _optometristaCtrl =
        TextEditingController(text: r?.optometrista ?? '');
    _dataCtrl = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(_data));
    _observacoesCtrl =
        TextEditingController(text: r?.observacoes ?? '');

    _odEsfCtrl =
        TextEditingController(text: _fmtInit(r?.od.esf));
    _odCilCtrl =
        TextEditingController(text: _fmtInit(r?.od.cil));
    _odEixoCtrl = TextEditingController(
        text: r?.od.eixo?.toString() ?? '');
    _odAddCtrl =
        TextEditingController(text: _fmtInit(r?.od.add));
    _odDnpCtrl =
        TextEditingController(text: _fmtInit(r?.od.dnp));

    _oeEsfCtrl =
        TextEditingController(text: _fmtInit(r?.oe.esf));
    _oeCilCtrl =
        TextEditingController(text: _fmtInit(r?.oe.cil));
    _oeEixoCtrl = TextEditingController(
        text: r?.oe.eixo?.toString() ?? '');
    _oeAddCtrl =
        TextEditingController(text: _fmtInit(r?.oe.add));
    _oeDnpCtrl =
        TextEditingController(text: _fmtInit(r?.oe.dnp));
  }

  String _fmtInit(double? v) {
    if (v == null) return '';
    return v.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _optometristaCtrl.dispose();
    _dataCtrl.dispose();
    _observacoesCtrl.dispose();
    _odEsfCtrl.dispose();
    _odCilCtrl.dispose();
    _odEixoCtrl.dispose();
    _odAddCtrl.dispose();
    _odDnpCtrl.dispose();
    _oeEsfCtrl.dispose();
    _oeCilCtrl.dispose();
    _oeEixoCtrl.dispose();
    _oeAddCtrl.dispose();
    _oeDnpCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _data = picked;
        _dataCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickFoto(ImageSource source) async {
    Navigator.pop(context);
    final picked = await ImagePicker()
        .pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() => _fotoFile = File(picked.path));
    }
  }

  GrauOlho _buildGrau(
    TextEditingController esf,
    TextEditingController cil,
    TextEditingController eixo,
    TextEditingController add,
    TextEditingController dnp,
  ) =>
      GrauOlho(
        esf: double.tryParse(esf.text.trim()),
        cil: double.tryParse(cil.text.trim()),
        eixo: int.tryParse(eixo.text.trim()),
        add: double.tryParse(add.text.trim()),
        dnp: double.tryParse(dnp.text.trim()),
      );

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(receitaRepositoryProvider);
      final od = _buildGrau(
          _odEsfCtrl, _odCilCtrl, _odEixoCtrl, _odAddCtrl, _odDnpCtrl);
      final oe = _buildGrau(
          _oeEsfCtrl, _oeCilCtrl, _oeEixoCtrl, _oeAddCtrl, _oeDnpCtrl);

      final data = <String, dynamic>{
        'data': _data,
        'optometrista': _optometristaCtrl.text.trim(),
        'od': od.toMap(),
        'oe': oe.toMap(),
        if (_observacoesCtrl.text.trim().isNotEmpty)
          'observacoes': _observacoesCtrl.text.trim(),
      };

      if (_isEditing) {
        if (_fotoFile != null) {
          final url = await repo.uploadFoto(
              widget.clienteId, widget.receita!.id, _fotoFile!);
          data['fotoUrl'] = url;
        }
        await repo.atualizar(widget.clienteId, widget.receita!.id, data);
      } else {
        final newId = await repo.criar(widget.clienteId, data);
        if (_fotoFile != null) {
          final url = await repo.uploadFoto(
              widget.clienteId, newId, _fotoFile!);
          await repo.atualizar(
              widget.clienteId, newId, {'fotoUrl': url});
        }
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erro ao salvar: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_isEditing ? 'Editar Receita' : 'Nova Receita'),
        actions: [
          if (!_loading)
            TextButton(
              onPressed: _salvar,
              child: const Text('SALVAR',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Text(_errorMessage!,
                          style: const TextStyle(
                              color: AppColors.error)),
                      const SizedBox(height: 12),
                    ],
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildGrauCard(),
                    const SizedBox(height: 16),
                    _buildObservacoesCard(),
                    const SizedBox(height: 16),
                    _buildFotoCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Consulta',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickData,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Data da consulta *',
                      prefixIcon:
                          Icon(Icons.calendar_today_outlined),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Informe a data'
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _optometristaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Optometrista *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Informe o nome do optometrista'
                        : null,
              ),
            ],
          ),
        ),
      );

  Widget _buildGrauCard() {
    const headers = ['ESF', 'CIL', 'EIXO', 'ADD', 'DNP'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Graus (Refração)',
                style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: 4),
            const Text(
              'ESF/CIL: use sinal (ex: -1.50, +2.25). EIXO: 1–180.',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(48),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
                5: FlexColumnWidth(),
              },
              defaultVerticalAlignment:
                  TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: AppColors.primary,
                              width: 0.5))),
                  children: [
                    const SizedBox(height: 28),
                    ...headers.map((h) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: 6),
                          child: Center(
                            child: Text(h,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                    fontSize: 13)),
                          ),
                        )),
                  ],
                ),
                _grauTableRow(
                  'OD',
                  [
                    _odEsfCtrl,
                    _odCilCtrl,
                    _odEixoCtrl,
                    _odAddCtrl,
                    _odDnpCtrl
                  ],
                  isOD: true,
                ),
                _grauTableRow(
                  'OE',
                  [
                    _oeEsfCtrl,
                    _oeCilCtrl,
                    _oeEixoCtrl,
                    _oeAddCtrl,
                    _oeDnpCtrl
                  ],
                  isOD: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _grauTableRow(String label,
      List<TextEditingController> ctrls,
      {required bool isOD}) {
    return TableRow(
      decoration: isOD
          ? null
          : const BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Color(0xFFE0E0E0), width: 0.5))),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    fontSize: 14)),
          ),
        ),
        ...ctrls.asMap().entries.map((entry) {
          final isEixo = entry.key == 2;
          return Padding(
            padding: const EdgeInsets.all(3),
            child: TextFormField(
              controller: entry.value,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(
                  signed: !isEixo, decimal: !isEixo),
              inputFormatters: [
                if (isEixo)
                  FilteringTextInputFormatter.digitsOnly
                else
                  _SignedDecimalFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: '—',
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 4, vertical: 10),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildObservacoesCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Observações',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacoesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Anotações clínicas, recomendações, próximo retorno...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 64),
                    child: Icon(Icons.notes_outlined),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildFotoCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Scan da Receita (opcional)',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 12),
              if (_fotoFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_fotoFile!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover),
                )
              else if (widget.receita?.fotoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(widget.receita!.fotoUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _showFotoOptions,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(_fotoFile != null ||
                        widget.receita?.fotoUrl != null
                    ? 'Alterar foto'
                    : 'Adicionar foto'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary),
              ),
            ],
          ),
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
}

class _SignedDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    final text = value.text;
    if (text.isEmpty) return value;
    // Allow: optional leading +/-, digits, optional single dot/comma
    final regex = RegExp(r'^[+-]?(\d*[.,]?\d*)$');
    if (regex.hasMatch(text)) {
      return value.copyWith(
          text: text.replaceAll(',', '.'));
    }
    return old;
  }
}
