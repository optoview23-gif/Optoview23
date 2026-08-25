import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/agendamento_model.dart';
import '../data/agendamento_repository.dart';
import '../../clientes/data/cliente_model.dart';
import '../../clientes/data/cliente_repository.dart';
import '../../../core/constants/app_colors.dart';

class AgendamentoFormScreen extends ConsumerStatefulWidget {
  final Agendamento? agendamento;
  final DateTime? dataInicial;

  const AgendamentoFormScreen({
    super.key,
    this.agendamento,
    this.dataInicial,
  });

  @override
  ConsumerState<AgendamentoFormScreen> createState() =>
      _AgendamentoFormScreenState();
}

class _AgendamentoFormScreenState
    extends ConsumerState<AgendamentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  String? _clienteId;
  String? _clienteNome;
  String? _clienteTelefone;

  late TipoAgendamento _tipo;
  late StatusAgendamento _status;
  late DateTime _data;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFim;

  final _obsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final a = widget.agendamento;
    if (a != null) {
      _clienteId = a.clienteId;
      _clienteNome = a.clienteNome;
      _clienteTelefone = a.clienteTelefone;
      _tipo = a.tipo;
      _status = a.status;
      _data =
          DateTime(a.inicio.year, a.inicio.month, a.inicio.day);
      _horaInicio = TimeOfDay.fromDateTime(a.inicio);
      _horaFim = TimeOfDay.fromDateTime(a.fim);
      _obsCtrl.text = a.observacoes ?? '';
    } else {
      final base = widget.dataInicial ?? DateTime.now();
      _tipo = TipoAgendamento.consulta;
      _status = StatusAgendamento.agendado;
      _data = DateTime(base.year, base.month, base.day);
      _horaInicio = const TimeOfDay(hour: 9, minute: 0);
      _horaFim = const TimeOfDay(hour: 9, minute: 30);
    }
  }

  @override
  void dispose() {
    _obsCtrl.dispose();
    super.dispose();
  }

  DateTime _toDateTime(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um cliente')));
      return;
    }

    final inicio = _toDateTime(_data, _horaInicio);
    final fim = _toDateTime(_data, _horaFim);
    if (!fim.isAfter(inicio)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Horário de fim deve ser após o início')));
      return;
    }

    setState(() => _saving = true);

    final data = <String, dynamic>{
      'clienteId': _clienteId,
      'clienteNome': _clienteNome,
      if (_clienteTelefone != null) 'clienteTelefone': _clienteTelefone,
      'tipo': _tipo.value,
      'status': _status.value,
      'inicio': inicio.millisecondsSinceEpoch,
      'fim': fim.millisecondsSinceEpoch,
      if (_obsCtrl.text.trim().isNotEmpty)
        'observacoes': _obsCtrl.text.trim(),
    };

    try {
      final repo = ref.read(agendamentoRepositoryProvider);
      if (widget.agendamento == null) {
        await repo.criar(data);
      } else {
        await repo.atualizar(widget.agendamento!.id, data);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.agendamento == null
            ? 'Novo Agendamento'
            : 'Editar Agendamento'),
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
            _buildTipoSection(),
            const SizedBox(height: 16),
            _buildDataHoraSection(context),
            const SizedBox(height: 16),
            _buildStatusSection(),
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
              GestureDetector(
                onTap: widget.agendamento != null ? null : _selecionarCliente,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                    color: widget.agendamento != null
                        ? Colors.grey.shade100
                        : null,
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
                      if (_clienteNome != null &&
                          widget.agendamento == null)
                        IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textSecondary),
                          onPressed: () => setState(() {
                            _clienteId = null;
                            _clienteNome = null;
                            _clienteTelefone = null;
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

  Widget _buildTipoSection() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tipo',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TipoAgendamento.values
                    .map((t) => ChoiceChip(
                          label: Text(t.label),
                          selected: _tipo == t,
                          onSelected: (_) => setState(() => _tipo = t),
                          selectedColor: _tipoColor(t),
                          labelStyle: TextStyle(
                              color: _tipo == t
                                  ? Colors.white
                                  : AppColors.textPrimary),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      );

  Widget _buildDataHoraSection(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Data e Horário',
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
                      labelText: 'Data',
                      prefixIcon:
                          Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: DateFormat('dd/MM/yyyy').format(_data),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickHora(isInicio: true),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Início',
                          prefixIcon:
                              Icon(Icons.access_time_outlined),
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(
                            text: _horaInicio.format(context)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickHora(isInicio: false),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Fim',
                          prefixIcon:
                              Icon(Icons.access_time_filled_outlined),
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(
                            text: _horaFim.format(context)),
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: StatusAgendamento.values
                    .map((s) => ChoiceChip(
                          label: Text(s.label),
                          selected: _status == s,
                          onSelected: (_) =>
                              setState(() => _status = s),
                          selectedColor: _statusColor(s),
                          labelStyle: TextStyle(
                              color: _status == s
                                  ? Colors.white
                                  : AppColors.textPrimary),
                        ))
                    .toList(),
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
        _clienteTelefone = cliente.telefone;
      });
    }
  }

  Future<void> _pickData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _data = picked);
  }

  Future<void> _pickHora({required bool isInicio}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isInicio ? _horaInicio : _horaFim,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx)
            .copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = picked;
          // Auto-advance end time by 30 min
          final totalMin =
              picked.hour * 60 + picked.minute + 30;
          _horaFim = TimeOfDay(
              hour: totalMin ~/ 60 % 24, minute: totalMin % 60);
        } else {
          _horaFim = picked;
        }
      });
    }
  }
}

Color _tipoColor(TipoAgendamento t) => switch (t) {
      TipoAgendamento.consulta => AppColors.primary,
      TipoAgendamento.entrega => Colors.blue,
      TipoAgendamento.ajuste => Colors.orange,
      TipoAgendamento.outro => Colors.purple,
    };

Color _statusColor(StatusAgendamento s) => switch (s) {
      StatusAgendamento.agendado => Colors.grey,
      StatusAgendamento.confirmado => AppColors.primary,
      StatusAgendamento.realizado => Colors.teal,
      StatusAgendamento.faltou => Colors.orange,
      StatusAgendamento.cancelado => AppColors.error,
    };

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
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                            c.telefone.contains(_query))
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
