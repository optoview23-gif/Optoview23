import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../agenda/data/agendamento_model.dart';
import '../../agenda/data/agendamento_repository.dart';
import '../../estoque/data/item_estoque_repository.dart';
import '../../pedidos/data/pedido_model.dart';
import '../data/dashboard_providers.dart';
import '../../../core/constants/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoje = DateTime.now();
    final hojeNorm = DateTime(hoje.year, hoje.month, hoje.day);
    final agendamentosAsync = ref.watch(agendamentosDiaProvider(hojeNorm));
    final pedidosPendentesAsync = ref.watch(pedidosPendentesProvider);
    final alertasAsync = ref.watch(estoqueAlertasProvider);
    final caixaMesAsync = ref.watch(caixaMesSummaryProvider);

    final saudacao = _saudacao(hoje.hour);
    final dateFmt = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    final moneyFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(saudacao, dateFmt.format(hoje)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(
                  context,
                  agendamentosAsync: agendamentosAsync,
                  pedidosPendentesAsync: pedidosPendentesAsync,
                  alertasAsync: alertasAsync,
                  caixaMesAsync: caixaMesAsync,
                  moneyFmt: moneyFmt,
                ),
                const SizedBox(height: 24),
                _buildAgendamentosSection(context, agendamentosAsync),
                const SizedBox(height: 24),
                _buildPedidosSection(context, pedidosPendentesAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String saudacao, String data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(saudacao,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Ótica Yuri',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: Colors.white60, size: 14),
              const SizedBox(width: 6),
              Text(data,
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required AsyncValue<List<Agendamento>> agendamentosAsync,
    required AsyncValue<List<Pedido>> pedidosPendentesAsync,
    required AsyncValue<dynamic> alertasAsync,
    required AsyncValue<dynamic> caixaMesAsync,
    required NumberFormat moneyFmt,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          icon: Icons.calendar_month_outlined,
          color: AppColors.primary,
          label: 'Agendamentos hoje',
          value: agendamentosAsync.when(
            data: (l) => '${l.length}',
            loading: () => '…',
            error: (_, __) => '–',
          ),
          onTap: () => context.go('/agenda'),
        ),
        _StatCard(
          icon: Icons.shopping_bag_outlined,
          color: Colors.blue,
          label: 'Pedidos pendentes',
          value: pedidosPendentesAsync.when(
            data: (l) => '${l.length}',
            loading: () => '…',
            error: (_, __) => '–',
          ),
          onTap: () => context.go('/pedidos'),
        ),
        _StatCard(
          icon: Icons.inventory_2_outlined,
          color: Colors.orange,
          label: 'Alertas estoque',
          value: alertasAsync.when(
            data: (l) => '${(l as List).length}',
            loading: () => '…',
            error: (_, __) => '–',
          ),
          onTap: () => context.go('/estoque'),
        ),
        _StatCard(
          icon: Icons.account_balance_wallet_outlined,
          color: Colors.teal,
          label: 'Saldo do mês',
          value: caixaMesAsync.when(
            data: (s) => moneyFmt.format(s.saldo),
            loading: () => '…',
            error: (_, __) => '–',
          ),
          onTap: () => context.go('/caixa'),
        ),
      ],
    );
  }

  Widget _buildAgendamentosSection(
      BuildContext context, AsyncValue<List<Agendamento>> async) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Agendamentos de hoje',
          onVerTodos: () => context.go('/agenda'),
        ),
        const SizedBox(height: 8),
        async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erro: $e',
              style: const TextStyle(color: AppColors.error)),
          data: (lista) {
            if (lista.isEmpty) {
              return const _EmptyCard(
                icon: Icons.event_available_outlined,
                message: 'Nenhum agendamento para hoje',
              );
            }
            final exibir = lista.take(5).toList();
            return Column(
              children: exibir
                  .map((a) => _AgendamentoTile(agendamento: a))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPedidosSection(
      BuildContext context, AsyncValue<List<Pedido>> async) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Pedidos pendentes',
          onVerTodos: () => context.go('/pedidos'),
        ),
        const SizedBox(height: 8),
        async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erro: $e',
              style: const TextStyle(color: AppColors.error)),
          data: (lista) {
            if (lista.isEmpty) {
              return const _EmptyCard(
                icon: Icons.check_circle_outline,
                message: 'Nenhum pedido pendente',
              );
            }
            final exibir = lista.take(5).toList();
            return Column(
              children:
                  exibir.map((p) => _PedidoTile(pedido: p)).toList(),
            );
          },
        ),
      ],
    );
  }

  String _saudacao(int hora) {
    if (hora < 12) return 'Bom dia 👋';
    if (hora < 18) return 'Boa tarde 👋';
    return 'Boa noite 👋';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onVerTodos;

  const _SectionHeader({required this.title, required this.onVerTodos});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary)),
        TextButton(
          onPressed: onVerTodos,
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0)),
          child: const Text('Ver todos',
              style: TextStyle(fontSize: 12, color: AppColors.primary)),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            children: [
              Icon(icon,
                  size: 36,
                  color: AppColors.textSecondary.withAlpha(100)),
              const SizedBox(height: 8),
              Text(message,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgendamentoTile extends StatelessWidget {
  final Agendamento agendamento;
  const _AgendamentoTile({required this.agendamento});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final color = _tipoColor(agendamento.tipo);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 44,
              child: Text(
                timeFmt.format(agendamento.inicio),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(agendamento.clienteNome,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                          fontSize: 13)),
                  Text(agendamento.tipo.label,
                      style: TextStyle(
                          fontSize: 11, color: color)),
                ],
              ),
            ),
            _StatusDot(status: agendamento.status),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final StatusAgendamento status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      StatusAgendamento.agendado => Colors.grey,
      StatusAgendamento.confirmado => AppColors.primary,
      StatusAgendamento.realizado => Colors.teal,
      StatusAgendamento.faltou => Colors.orange,
      StatusAgendamento.cancelado => AppColors.error,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _PedidoTile extends StatelessWidget {
  final Pedido pedido;
  const _PedidoTile({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final moneyFmt =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final color = _pedidoStatusColor(pedido.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(_pedidoStatusIcon(pedido.status), color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pedido.clienteNome,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: AppColors.textPrimary)),
                  Text(pedido.status.label,
                      style: TextStyle(fontSize: 11, color: color)),
                ],
              ),
            ),
            Text(
              moneyFmt.format(pedido.valorTotal),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

Color _tipoColor(TipoAgendamento t) => switch (t) {
      TipoAgendamento.consulta => AppColors.primary,
      TipoAgendamento.entrega => Colors.blue,
      TipoAgendamento.ajuste => Colors.orange,
      TipoAgendamento.outro => Colors.purple,
    };

Color _pedidoStatusColor(StatusPedido s) => switch (s) {
      StatusPedido.orcamento => Colors.grey,
      StatusPedido.confirmado => AppColors.primary,
      StatusPedido.emLaboratorio => Colors.blue,
      StatusPedido.pronto => Colors.teal,
      StatusPedido.entregue => Colors.green.shade700,
      StatusPedido.cancelado => AppColors.error,
    };

IconData _pedidoStatusIcon(StatusPedido s) => switch (s) {
      StatusPedido.orcamento => Icons.description_outlined,
      StatusPedido.confirmado => Icons.thumb_up_outlined,
      StatusPedido.emLaboratorio => Icons.science_outlined,
      StatusPedido.pronto => Icons.check_circle_outline,
      StatusPedido.entregue => Icons.done_all,
      StatusPedido.cancelado => Icons.cancel_outlined,
    };
