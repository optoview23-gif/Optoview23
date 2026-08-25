import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/item_estoque_model.dart';
import '../data/item_estoque_repository.dart';
import '../../../core/constants/app_colors.dart';

class ItemEstoqueFormScreen extends ConsumerStatefulWidget {
  final ItemEstoque? item;
  const ItemEstoqueFormScreen({super.key, this.item});

  @override
  ConsumerState<ItemEstoqueFormScreen> createState() =>
      _ItemEstoqueFormScreenState();
}

class _ItemEstoqueFormScreenState
    extends ConsumerState<ItemEstoqueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late CategoriaEstoque _categoria;

  // Armação
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _corCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();

  // Lente
  final _tipoCtrl = TextEditingController();
  final _tratamentoCtrl = TextEditingController();

  // Acessório
  final _nomeCtrl = TextEditingController();

  // Comum
  final _quantidadeCtrl = TextEditingController();
  final _quantidadeMinimaCtrl = TextEditingController();
  final _precoCustoCtrl = TextEditingController();
  final _precoVendaCtrl = TextEditingController();
  bool _ativo = true;

  final _priceFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item != null) {
      _categoria = item.categoria;
      _marcaCtrl.text = item.marca ?? '';
      _modeloCtrl.text = item.modelo ?? '';
      _corCtrl.text = item.cor ?? '';
      _codigoCtrl.text = item.codigo ?? '';
      _tipoCtrl.text = item.tipo ?? '';
      _tratamentoCtrl.text = item.tratamento ?? '';
      _nomeCtrl.text = item.nome ?? '';
      _quantidadeCtrl.text = '${item.quantidade}';
      _quantidadeMinimaCtrl.text = '${item.quantidadeMinima}';
      _precoCustoCtrl.text =
          item.precoCusto != null ? _priceFormatter.format(item.precoCusto) : '';
      _precoVendaCtrl.text = _priceFormatter.format(item.precoVenda);
      _ativo = item.ativo;
    } else {
      _categoria = CategoriaEstoque.armacao;
      _quantidadeCtrl.text = '0';
      _quantidadeMinimaCtrl.text = '5';
    }
  }

  @override
  void dispose() {
    for (final c in [
      _marcaCtrl, _modeloCtrl, _corCtrl, _codigoCtrl,
      _tipoCtrl, _tratamentoCtrl, _nomeCtrl,
      _quantidadeCtrl, _quantidadeMinimaCtrl,
      _precoCustoCtrl, _precoVendaCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parsePrice(String v) {
    final s = v.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(s);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = <String, dynamic>{
      'categoria': _categoria.value,
      'quantidade': int.tryParse(_quantidadeCtrl.text.trim()) ?? 0,
      'quantidadeMinima':
          int.tryParse(_quantidadeMinimaCtrl.text.trim()) ?? 0,
      'precoVenda': _parsePrice(_precoVendaCtrl.text.trim()) ?? 0.0,
      'ativo': _ativo,
    };

    final precoCusto = _parsePrice(_precoCustoCtrl.text.trim());
    if (precoCusto != null) { data['precoCusto'] = precoCusto; }

    switch (_categoria) {
      case CategoriaEstoque.armacao:
        if (_marcaCtrl.text.trim().isNotEmpty) {
          data['marca'] = _marcaCtrl.text.trim();
        }
        if (_modeloCtrl.text.trim().isNotEmpty) {
          data['modelo'] = _modeloCtrl.text.trim();
        }
        if (_corCtrl.text.trim().isNotEmpty) {
          data['cor'] = _corCtrl.text.trim();
        }
        if (_codigoCtrl.text.trim().isNotEmpty) {
          data['codigo'] = _codigoCtrl.text.trim();
        }
        break;
      case CategoriaEstoque.lente:
        if (_tipoCtrl.text.trim().isNotEmpty) {
          data['tipo'] = _tipoCtrl.text.trim();
        }
        if (_tratamentoCtrl.text.trim().isNotEmpty) {
          data['tratamento'] = _tratamentoCtrl.text.trim();
        }
        if (_codigoCtrl.text.trim().isNotEmpty) {
          data['codigo'] = _codigoCtrl.text.trim();
        }
        break;
      case CategoriaEstoque.acessorio:
        if (_nomeCtrl.text.trim().isNotEmpty) {
          data['nome'] = _nomeCtrl.text.trim();
        }
        if (_codigoCtrl.text.trim().isNotEmpty) {
          data['codigo'] = _codigoCtrl.text.trim();
        }
        break;
    }

    try {
      final repo = ref.read(itemEstoqueRepositoryProvider);
      if (widget.item == null) {
        await repo.criar(data);
      } else {
        await repo.atualizar(widget.item!.id, data);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.item != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Item' : 'Novo Item'),
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
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildCategoryFields(),
            const SizedBox(height: 16),
            _buildComumFields(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Categoria',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              ...CategoriaEstoque.values.map(
                (c) => RadioListTile<CategoriaEstoque>(
                  value: c,
                  // ignore: deprecated_member_use
                  groupValue: _categoria,
                  title: Text(c.label),
                  dense: true,
                  // ignore: deprecated_member_use
                  onChanged: widget.item != null
                      ? null
                      : (v) => setState(() => _categoria = v!),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildCategoryFields() {
    final fields = switch (_categoria) {
      CategoriaEstoque.armacao => _armacaoFields(),
      CategoriaEstoque.lente => _lenteFields(),
      CategoriaEstoque.acessorio => _acessorioFields(),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dados da ${_categoria.label}',
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            const SizedBox(height: 12),
            ...fields,
          ],
        ),
      ),
    );
  }

  List<Widget> _armacaoFields() => [
        _field(_marcaCtrl, 'Marca'),
        const SizedBox(height: 12),
        _field(_modeloCtrl, 'Modelo'),
        const SizedBox(height: 12),
        _field(_corCtrl, 'Cor'),
        const SizedBox(height: 12),
        _field(_codigoCtrl, 'Código / Referência'),
      ];

  List<Widget> _lenteFields() => [
        _field(_tipoCtrl, 'Tipo (ex: Monofocal, Bifocal)'),
        const SizedBox(height: 12),
        _field(_tratamentoCtrl, 'Tratamento (ex: Antirreflexo, UV)'),
        const SizedBox(height: 12),
        _field(_codigoCtrl, 'Código / Referência'),
      ];

  List<Widget> _acessorioFields() => [
        _field(_nomeCtrl, 'Nome', required: true),
        const SizedBox(height: 12),
        _field(_codigoCtrl, 'Código / Referência'),
      ];

  Widget _buildComumFields() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estoque & Preços',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantidadeCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _quantidadeMinimaCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Qtd. Mínima',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _precoCustoCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Preço de Custo (R\$)',
                        border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d,.]'))
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _precoVendaCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Preço de Venda (R\$)',
                        border: OutlineInputBorder()),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d,.]'))
                    ],
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _ativo,
                onChanged: (v) => setState(() => _ativo = v),
                title: const Text('Item ativo'),
                subtitle: const Text('Desmarque para ocultar sem excluir'),
                // ignore: deprecated_member_use
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      );

  Widget _field(TextEditingController ctrl, String label,
          {bool required = false}) =>
      TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator:
            required ? (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null : null,
        textCapitalization: TextCapitalization.words,
      );
}
