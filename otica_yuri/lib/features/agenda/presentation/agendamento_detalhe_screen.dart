import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/agendamento_model.dart';
import '../data/agendamento_repository.dart';
import '../../../core/constants/app_colors.dart';

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

class AgendamentoDetalheScreen extends ConsumerWidget {
  final Agendamento agendamento;
  const AgendamentoDetalheScreen({super.key, required this.agendamento});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(agendamento.clienteNome,
            overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(
                '/agenda/${agendamento.id}/editar',
                extra: agendamento),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmarExclusao(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildInfo(),
            if (!agendamento.status.isFinalizado) ...[
              const SizedBox(height: 16),
              _buildAcoes(context, ref),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final dateFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    final timeFmt = DateFormat('HH:mm');
    return Container(
      color: _tipoColor(agendamento.tipo),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(agendamento.tipo.label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          Text(
            agendamento.clienteNome,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            dateFmt.format(agendamento.inicio),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            '${timeFmt.format(agendamento.inicio)} — ${timeFmt.format(agendamento.fim)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informações',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              _infoRow(Icons.circle_outlined, 'Status',
                  widget: _StatusBadge(status: agendamento.status)),
              if (agendamento.clienteTelefone != null)
                _infoRow(Icons.phone_outlined, 'Telefone',
                    value: agendamento.clienteTelefone!),
              _infoRow(Icons.timer_outlined, 'Duração',
                  value: _formatDuracao(agendamento.duracao)),
              if (agendamento.observacoes != null)
                _infoRow(Icons.notes_outlined, 'Observações',
                    value: agendamento.observacoes!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label,
      {String? value, Widget? widget}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Text('$label: ',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            if (value != null)
              Expanded(
                child: Text(value,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14)),
              )
            else if (widget != null)
              widget,
          ],
        ),
      );

  Widget _buildAcoes(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Atualizar Status',
                    style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: StatusAgendamento.values
                      .where((s) => s != agendamento.status)
                      .map((s) => OutlinedButton(
                            onPressed: () =>
                                _mudarStatus(context, ref, s),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _statusColor(s),
                              side: BorderSide(
                                  color: _statusColor(s).withAlpha(150)),
                            ),
                            child: Text(s.label),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _mudarStatus(
      BuildContext context, WidgetRef ref, StatusAgendamento s) async {
    try {
      await ref
          .read(agendamentoRepositoryProvider)
          .atualizarStatus(agendamento.id, s);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  void _confirmarExclusao(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir agendamento'),
        content: Text(
            'Excluir agendamento de ${agendamento.clienteNome}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(agendamentoRepositoryProvider)
                  .deletar(agendamento.id);
              if (context.mounted) context.go('/agenda');
            },
            child: const Text('Excluir',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  String _formatDuracao(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}h${m > 0 ? ' ${m}min' : ''}';
    return '${m}min';
  }
}

class _StatusBadge extends StatelessWidget {
  final StatusAgendamento status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(status.label,
          style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}
