import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/agendamento_model.dart';
import '../data/agendamento_repository.dart';
import '../../../core/constants/app_colors.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaAtual = ref.watch(agendaDiaProvider);

    return Scaffold(
      body: Column(
        children: [
          _CalendarioSemanal(diaAtual: diaAtual),
          const Divider(height: 1),
          Expanded(
            child: _AgendaDia(dia: diaAtual),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/agenda/novo', extra: diaAtual),
        icon: const Icon(Icons.add),
        label: const Text('Agendar'),
      ),
    );
  }
}

class _CalendarioSemanal extends ConsumerWidget {
  final DateTime diaAtual;
  const _CalendarioSemanal({required this.diaAtual});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoje = DateTime.now();
    final hojeNorm = DateTime(hoje.year, hoje.month, hoje.day);

    // Start of the week containing diaAtual (Monday)
    final inicioSemana = diaAtual
        .subtract(Duration(days: diaAtual.weekday - 1));

    final semanaAsync =
        ref.watch(agendamentosSemanaProvider(inicioSemana));

    final contsPorDia = <DateTime, int>{};
    semanaAsync.whenData((list) {
      for (final a in list) {
        final d =
            DateTime(a.inicio.year, a.inicio.month, a.inicio.day);
        contsPorDia[d] = (contsPorDia[d] ?? 0) + 1;
      }
    });

    return Container(
      color: AppColors.secondary,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      child: Column(
        children: [
          // Month + nav row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => ref
                    .read(agendaDiaProvider.notifier)
                    .state = diaAtual.subtract(const Duration(days: 7)),
              ),
              Text(
                DateFormat('MMMM yyyy', 'pt_BR').format(diaAtual),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon:
                    const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => ref
                    .read(agendaDiaProvider.notifier)
                    .state = diaAtual.add(const Duration(days: 7)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Day columns
          Row(
            children: List.generate(7, (i) {
              final dia = inicioSemana.add(Duration(days: i));
              final isHoje = dia == hojeNorm;
              final isSelecionado = dia == diaAtual;
              final count = contsPorDia[dia] ?? 0;
              return Expanded(
                child: GestureDetector(
                  onTap: () => ref
                      .read(agendaDiaProvider.notifier)
                      .state = dia,
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E', 'pt_BR')
                            .format(dia)
                            .toUpperCase()
                            .substring(0, 3),
                        style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: isHoje
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelecionado
                              ? Colors.white
                              : isHoje
                                  ? Colors.white.withAlpha(40)
                                  : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${dia.day}',
                          style: TextStyle(
                            color: isSelecionado
                                ? AppColors.secondary
                                : Colors.white,
                            fontWeight: isSelecionado || isHoje
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (count > 0)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelecionado
                                ? AppColors.secondary
                                : Colors.greenAccent,
                          ),
                        )
                      else
                        const SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AgendaDia extends ConsumerWidget {
  final DateTime dia;
  const _AgendaDia({required this.dia});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendamentosAsync = ref.watch(agendamentosDiaProvider(dia));
    final fmt = DateFormat('EEEE, d \'de\' MMMM', 'pt_BR');

    return agendamentosAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (lista) {
        if (lista.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  fmt.format(dia),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_available_outlined,
                          size: 56,
                          color: AppColors.textSecondary.withAlpha(128)),
                      const SizedBox(height: 12),
                      const Text('Nenhum agendamento',
                          style:
                              TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: lista.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  fmt.format(dia),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              );
            }
            return _AgendamentoCard(agendamento: lista[i - 1]);
          },
        );
      },
    );
  }
}

class _AgendamentoCard extends ConsumerWidget {
  final Agendamento agendamento;
  const _AgendamentoCard({required this.agendamento});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFmt = DateFormat('HH:mm');
    final color = _tipoColor(agendamento.tipo);
    final faded = agendamento.status.isFinalizado;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
            '/agenda/${agendamento.id}', extra: agendamento),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Time column
              SizedBox(
                width: 48,
                child: Column(
                  children: [
                    Text(
                      timeFmt.format(agendamento.inicio),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: faded
                              ? AppColors.textSecondary
                              : AppColors.textPrimary),
                    ),
                    Text(
                      timeFmt.format(agendamento.fim),
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                width: 3,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: faded ? color.withAlpha(80) : color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agendamento.clienteNome,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: faded
                              ? AppColors.textSecondary
                              : AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(agendamento.tipo.label,
                        style: TextStyle(
                            fontSize: 12, color: faded ? color.withAlpha(128) : color)),
                    if (agendamento.observacoes != null) ...[
                      const SizedBox(height: 2),
                      Text(agendamento.observacoes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              _StatusBadge(status: agendamento.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StatusAgendamento status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(status.label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
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
