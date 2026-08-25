import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/transacao_model.dart';
import '../data/transacao_repository.dart';
import '../../../core/constants/app_colors.dart';

class CaixaScreen extends ConsumerWidget {
  const CaixaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(caixaSummaryProvider);
    final filtradas = ref.watch(transacoesFiltradosProvider);
    final periodo = ref.watch(caixaPeriodoProvider);
    final tipoFilter = ref.watch(caixaTipoFilterProvider);

    return Scaffold(
      body: Column(
        children: [
          summary.when(
            loading: () => const _SummaryCardSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
            data: (s) => _SummaryCard(summary: s, periodo: periodo),
          ),
          _buildFilters(ref, periodo, tipoFilter),
          Expanded(
            child: filtradas.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (list) => list.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      itemCount: list.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (_, i) =>
                          _TransacaoTile(transacao: list[i]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/caixa/nova'),
        icon: const Icon(Icons.add),
        label: const Text('Nova Transação'),
      ),
    );
  }

  Widget _buildFilters(
      WidgetRef ref, PeriodoCaixa periodo, TipoTransacao? tipo) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _periodoChip(ref, PeriodoCaixa.hoje, 'Hoje', periodo),
                    const SizedBox(width: 6),
                    _periodoChip(
                        ref, PeriodoCaixa.semana, 'Semana', periodo),
                    const SizedBox(width: 6),
                    _periodoChip(ref, PeriodoCaixa.mes, 'Mês', periodo),
                    const SizedBox(width: 6),
                    _periodoChip(ref, PeriodoCaixa.todos, 'Tudo', periodo),
                    const SizedBox(width: 12),
                    _tipoChip(ref, null, 'Todos', tipo),
                    const SizedBox(width: 6),
                    _tipoChip(ref, TipoTransacao.receita, 'Receitas', tipo),
                    const SizedBox(width: 6),
                    _tipoChip(ref, TipoTransacao.despesa, 'Despesas', tipo),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _periodoChip(WidgetRef ref, PeriodoCaixa value, String label,
          PeriodoCaixa current) =>
      ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: current == value,
        onSelected: (_) =>
            ref.read(caixaPeriodoProvider.notifier).state = value,
        selectedColor: AppColors.secondary,
        labelStyle: TextStyle(
            color: current == value ? Colors.white : AppColors.textPrimary),
        visualDensity: VisualDensity.compact,
      );

  Widget _tipoChip(WidgetRef ref, TipoTransacao? value, String label,
          TipoTransacao? current) =>
      ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: current == value,
        onSelected: (_) =>
            ref.read(caixaTipoFilterProvider.notifier).state = value,
        selectedColor:
            value == TipoTransacao.despesa ? AppColors.error : AppColors.primary,
        labelStyle: TextStyle(
            color: current == value ? Colors.white : AppColors.textPrimary),
        visualDensity: VisualDensity.compact,
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 64,
                color: AppColors.textSecondary.withAlpha(128)),
            const SizedBox(height: 16),
            const Text('Nenhuma transação no período',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
}

class _SummaryCard extends StatelessWidget {
  final CaixaSummary summary;
  final PeriodoCaixa periodo;
  const _SummaryCard({required this.summary, required this.periodo});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final saldoPositivo = summary.saldo >= 0;

    return Container(
      color: AppColors.secondary,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _periodoLabel(),
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            fmt.format(summary.saldo),
            style: TextStyle(
              color: saldoPositivo ? Colors.white : Colors.red.shade300,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  label: 'Receitas',
                  value: fmt.format(summary.totalReceitas),
                  color: Colors.greenAccent.shade400,
                  icon: Icons.arrow_upward,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _miniStat(
                  label: 'Despesas',
                  value: fmt.format(summary.totalDespesas),
                  color: Colors.red.shade300,
                  icon: Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) =>
      Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      );

  String _periodoLabel() => switch (periodo) {
        PeriodoCaixa.hoje => 'Saldo de hoje',
        PeriodoCaixa.semana => 'Saldo dos últimos 7 dias',
        PeriodoCaixa.mes => 'Saldo do mês atual',
        PeriodoCaixa.todos => 'Saldo geral',
      };
}

class _SummaryCardSkeleton extends StatelessWidget {
  const _SummaryCardSkeleton();

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.secondary,
        height: 130,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
}

class _TransacaoTile extends ConsumerWidget {
  final Transacao transacao;
  const _TransacaoTile({required this.transacao});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isReceita = transacao.isReceita;
    final color = isReceita ? AppColors.primary : AppColors.error;

    return Dismissible(
      key: Key(transacao.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Excluir transação'),
          content: const Text('Deseja excluir esta transação?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
      onDismissed: (_) => ref
          .read(transacaoRepositoryProvider)
          .deletar(transacao.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(25),
          child: Icon(
            isReceita ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 20,
          ),
        ),
        title: Text(transacao.descricao,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          [
            if (transacao.categoria != null) transacao.categoria!,
            transacao.formaPagamento.label,
            DateFormat('dd/MM').format(transacao.data),
          ].join(' · '),
          style:
              const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Text(
          '${isReceita ? '+' : '-'} ${fmt.format(transacao.valor)}',
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
        onTap: () =>
            context.push('/caixa/${transacao.id}/editar', extra: transacao),
      ),
    );
  }
}
