import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/transacao_model.dart';
import '../data/transacao_repository.dart';
import '../../../core/constants/app_colors.dart';

class TransacaoFormScreen extends ConsumerStatefulWidget {
  final Transacao? transacao;
  const TransacaoFormScreen({super.key, this.transacao});

  @override
  ConsumerState<TransacaoFormScreen> createState() =>
      _TransacaoFormScreenState();
}

class _TransacaoFormScreenState
    extends ConsumerState<TransacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late TipoTransacao _tipo;
  late FormaPagamento _formaPagamento;
  late DateTime _data;

  final _valorCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  final _priceFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: '');

  @override
  void initState() {
    super.initState();
    final t = widget.transacao;
    if (t != null) {
      _tipo = t.tipo;
      _formaPagamento = t.formaPagamento;
      _data = t.data;
      _valorCtrl.text = _priceFormat.format(t.valor);
      _descricaoCtrl.text = t.descricao;
      _categoriaCtrl.text = t.categoria ?? '';
      _obsCtrl.text = t.observacoes ?? '';
    } else {
      _tipo = TipoTransacao.receita;
      _formaPagamento = FormaPagamento.dinheiro;
      _data = DateTime.now();
    }
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    _descricaoCtrl.dispose();
    _categoriaCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  double _parsePrice(String v) {
    final s = v.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(s) ?? 0.0;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = <String, dynamic>{
      'tipo': _tipo.value,
      'valor': _parsePrice(_valorCtrl.text),
      'descricao': _descricaoCtrl.text.trim(),
      'formaPagamento': _formaPagamento.value,
      if (_categoriaCtrl.text.trim().isNotEmpty)
        'categoria': _categoriaCtrl.text.trim(),
      'data': _data.millisecondsSinceEpoch,
      if (_obsCtrl.text.trim().isNotEmpty)
        'observacoes': _obsCtrl.text.trim(),
    };

    try {
      final repo = ref.read(transacaoRepositoryProvider);
      if (widget.transacao == null) {
        await repo.criar(data);
      } else {
        await repo.atualizar(widget.transacao!.id, data);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transacao != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Transação' : 'Nova Transação'),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _salvar,
              child: const Text('SALVAR',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTipoSelector(),
            const SizedBox(height: 16),
            _buildValorSection(),
            const SizedBox(height: 16),
            _buildDetalhesSection(),
            const SizedBox(height: 16),
            _buildPagamentoSection(),
            const SizedBox(height: 16),
            _buildDataSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoSelector() => Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: TipoTransacao.values.map((t) {
              final selected = _tipo == t;
              final color = t == TipoTransacao.receita
                  ? AppColors.primary
                  : AppColors.error;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _tipo = t;
                    _categoriaCtrl.clear();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color:
                          selected ? color : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          t == TipoTransacao.receita
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: selected ? Colors.white : color,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t.label,
                          style: TextStyle(
                            color: selected ? Colors.white : color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );

  Widget _buildValorSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextFormField(
            controller: _valorCtrl,
            decoration: InputDecoration(
              labelText: 'Valor (R\$)',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(
                _tipo == TipoTransacao.receita
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: _tipo == TipoTransacao.receita
                    ? AppColors.primary
                    : AppColors.error,
              ),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))
            ],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Obrigatório' : null,
            autofocus: widget.transacao == null,
          ),
        ),
      );

  Widget _buildDetalhesSection() {
    final categorias = _tipo == TipoTransacao.receita
        ? categoriasReceita
        : categoriasDespesa;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detalhes',
                style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descricaoCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 12),
            Autocomplete<String>(
              initialValue:
                  TextEditingValue(text: _categoriaCtrl.text),
              optionsBuilder: (value) => value.text.isEmpty
                  ? categorias
                  : categorias.where((c) => c
                      .toLowerCase()
                      .contains(value.text.toLowerCase())),
              onSelected: (v) => _categoriaCtrl.text = v,
              fieldViewBuilder:
                  (ctx, ctrl, focusNode, onSubmit) => TextFormField(
                controller: ctrl,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Categoria (opcional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => _categoriaCtrl.text = v,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _obsCtrl,
              decoration: const InputDecoration(
                labelText: 'Observações (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagamentoSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Forma de Pagamento',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FormaPagamento.values
                    .map((f) => ChoiceChip(
                          label: Text(f.label),
                          selected: _formaPagamento == f,
                          onSelected: (_) =>
                              setState(() => _formaPagamento = f),
                          selectedColor: AppColors.secondary,
                          labelStyle: TextStyle(
                            color: _formaPagamento == f
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      );

  Widget _buildDataSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Data',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickData,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: DateFormat('dd/MM/yyyy').format(_data),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> _pickData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _data = picked);
  }
}
