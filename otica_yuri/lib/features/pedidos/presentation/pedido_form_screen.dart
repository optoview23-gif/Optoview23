import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/pedido_model.dart';
import '../data/pedido_repository.dart';
import '../../clientes/data/cliente_model.dart';
import '../../clientes/data/cliente_repository.dart';
import '../../prontuario/data/receita_model.dart';
import '../../prontuario/data/receita_repository.dart';
import '../../../core/constants/app_colors.dart';

class PedidoFormScreen extends ConsumerStatefulWidget {
  final Pedido? pedido;
  final String? clienteId;
  final String? clienteNome;

  const PedidoFormScreen({
    super.key,
    this.pedido,
    this.clienteId,
    this.clienteNome,
  });

  @override
  ConsumerState<PedidoFormScreen> createState() => _PedidoFormScreenState();
}

class _PedidoFormScreenState extends ConsumerState<PedidoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  String? _clienteId;
  String? _clienteNome;
  String? _receitaId;
  StatusPedido _status = StatusPedido.orcamento;

  final _armacaoCtrl = TextEditingController();
  final _lenteCtrl = TextEditingController();
  final _labCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _entradaCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  DateTime? _dataPrevista;

  final _priceFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: '');

  @override
  void initState() {
    super.initState();
    final p = widget.pedido;
    if (p != null) {
      _clienteId = p.clienteId;
      _clienteNome = p.clienteNome;
      _receitaId = p.receitaId;
      _status = p.status;
      _armacaoCtrl.text = p.armacaoDescricao ?? '';
      _lenteCtrl.text = p.lenteDescricao ?? '';
      _labCtrl.text = p.numeroPedidoLab ?? '';
      _totalCtrl.text = _priceFormat.format(p.valorTotal);
      _entradaCtrl.text =
          p.valorEntrada > 0 ? _priceFormat.format(p.valorEntrada) : '';
      _obsCtrl.text = p.observacoes ?? '';
      _dataPrevista = p.dataPrevista;
    } else {
      _clienteId = widget.clienteId;
      _clienteNome = widget.clienteNome;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _armacaoCtrl, _lenteCtrl, _labCtrl,
      _totalCtrl, _entradaCtrl, _obsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _parsePrice(String v) {
    final s = v.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(s) ?? 0.0;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um cliente')));
      return;
    }
    setState(() => _saving = true);

    final data = <String, dynamic>{
      'clienteId': _clienteId,
      'clienteNome': _clienteNome,
      if (_receitaId != null) 'receitaId': _receitaId,
      'status': _status.value,
      if (_armacaoCtrl.text.trim().isNotEmpty)
        'armacaoDescricao': _armacaoCtrl.text.trim(),
      if (_lenteCtrl.text.trim().isNotEmpty)
        'lenteDescricao': _lenteCtrl.text.trim(),
      if (_labCtrl.text.trim().isNotEmpty)
        'numeroPedidoLab': _labCtrl.text.trim(),
      'valorTotal': _parsePrice(_totalCtrl.text),
      'valorEntrada': _parsePrice(_entradaCtrl.text),
      if (_dataPrevista != null)
        'dataPrevista': _dataPrevista!.millisecondsSinceEpoch,
      if (_obsCtrl.text.trim().isNotEmpty) 'observacoes': _obsCtrl.text.trim(),
    };

    try {
      final repo = ref.read(pedidoRepositoryProvider);
      if (widget.pedido == null) {
        await repo.criar(data);
      } else {
        await repo.atualizar(widget.pedido!.id, data);
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
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.pedido == null ? 'Novo Pedido' : 'Editar Pedido'),
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
            _buildClienteSection(),
            const SizedBox(height: 16),
            if (_clienteId != null) ...[
              _buildReceitaSection(),
              const SizedBox(height: 16),
            ],
            _buildStatusSection(),
            const SizedBox(height: 16),
            _buildProdutosSection(),
            const SizedBox(height: 16),
            _buildFinanceiroSection(),
            const SizedBox(height: 16),
            _buildDatasSection(),
            const SizedBox(height: 16),
            _buildObsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cliente',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              if (_clienteId != null && widget.pedido != null)
                _infoChip(_clienteNome ?? '')
              else
                GestureDetector(
                  onTap: () => _selecionarCliente(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_search_outlined,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _clienteNome ?? 'Selecionar cliente...',
                            style: TextStyle(
                              color: _clienteNome != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (_clienteNome != null)
                          IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.textSecondary),
                            onPressed: () => setState(() {
                              _clienteId = null;
                              _clienteNome = null;
                              _receitaId = null;
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _buildReceitaSection() => Consumer(
        builder: (ctx, ref, _) {
          final receitasAsync =
              ref.watch(receitasByClienteProvider(_clienteId!));
          return receitasAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (receitas) {
              if (receitas.isEmpty) return const SizedBox.shrink();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Receita vinculada (opcional)',
                          style: TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String?>(
                        // ignore: deprecated_member_use
                        value: _receitaId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Receita',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Nenhuma'),
                          ),
                          ...receitas.map((r) => DropdownMenuItem<String?>(
                                value: r.id,
                                child: Text(_receitaLabel(r)),
                              )),
                        ],
                        onChanged: (v) =>
                            setState(() => _receitaId = v),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );

  Widget _buildStatusSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              DropdownButtonFormField<StatusPedido>(
                // ignore: deprecated_member_use
                value: _status,
                decoration: const InputDecoration(
                    border: OutlineInputBorder()),
                items: StatusPedido.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _status = v);
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildProdutosSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Produtos',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _armacaoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Armação',
                  prefixIcon: Icon(Icons.visibility_outlined),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lenteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lente',
                  prefixIcon: Icon(Icons.lens_outlined),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _labCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nº Pedido Laboratório',
                  prefixIcon: Icon(Icons.science_outlined),
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\w\-/]'))
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildFinanceiroSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Financeiro',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Valor Total (R\$)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))
                    ],
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Obrigatório' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _entradaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Entrada (R\$)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))
                    ],
                  ),
                ),
              ]),
            ],
          ),
        ),
      );

  Widget _buildDatasSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Datas',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _pickDataPrevista(),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Data de entrega prevista',
                      prefixIcon:
                          const Icon(Icons.calendar_today_outlined),
                      border: const OutlineInputBorder(),
                      suffixIcon: _dataPrevista != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => _dataPrevista = null),
                            )
                          : null,
                    ),
                    controller: TextEditingController(
                      text: _dataPrevista != null
                          ? DateFormat('dd/MM/yyyy').format(_dataPrevista!)
                          : '',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildObsSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Observações',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _obsCtrl,
                decoration: const InputDecoration(
                    border: OutlineInputBorder()),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
      );

  Widget _infoChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondary.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.secondary.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline,
                size: 16, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(text,
                style: const TextStyle(color: AppColors.secondary)),
          ],
        ),
      );

  Future<void> _selecionarCliente() async {
    final cliente = await showModalBottomSheet<Cliente>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ClienteSelectorSheet(),
    );
    if (cliente != null) {
      setState(() {
        _clienteId = cliente.id;
        _clienteNome = cliente.nome;
        _receitaId = null;
      });
    }
  }

  Future<void> _pickDataPrevista() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _dataPrevista ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dataPrevista = picked);
  }

  String _receitaLabel(Receita r) {
    final fmt = DateFormat('dd/MM/yyyy');
    return '${fmt.format(r.data)} — ${r.optometrista}';
  }
}

class _ClienteSelectorSheet extends ConsumerStatefulWidget {
  const _ClienteSelectorSheet();

  @override
  ConsumerState<_ClienteSelectorSheet> createState() =>
      _ClienteSelectorSheetState();
}

class _ClienteSelectorSheetState
    extends ConsumerState<_ClienteSelectorSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesAsync = ref.watch(clientesStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: clientesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (clientes) {
                final filtered = _query.isEmpty
                    ? clientes
                    : clientes
                        .where((c) =>
                            c.nome.toLowerCase().contains(_query) ||
                            c.cpf.contains(_query))
                        .toList();
                return ListView.builder(
                  controller: scrollCtrl,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    return ListTile(
                      leading: const CircleAvatar(
                          backgroundColor: AppColors.secondary,
                          child: Icon(Icons.person_outline,
                              color: Colors.white, size: 18)),
                      title: Text(c.nome),
                      subtitle: Text(c.telefone,
                          style: const TextStyle(fontSize: 12)),
                      onTap: () => Navigator.pop(context, c),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
