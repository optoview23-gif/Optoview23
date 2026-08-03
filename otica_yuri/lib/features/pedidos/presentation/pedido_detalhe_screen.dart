import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/pedido_model.dart';
import '../data/pedido_repository.dart';
import '../../../core/constants/app_colors.dart';

Color _statusColor(StatusPedido s) => switch (s) {
      StatusPedido.orcamento => Colors.grey,
      StatusPedido.confirmado => Colors.blue,
      StatusPedido.emLaboratorio => Colors.orange,
      StatusPedido.pronto => AppColors.primary,
      StatusPedido.entregue => Colors.teal,
      StatusPedido.cancelado => AppColors.error,
    };

class PedidoDetalheScreen extends ConsumerWidget {
  final Pedido pedido;
  const PedidoDetalheScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pedido.clienteNome, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () =>
                context.push('/pedidos/${pedido.id}/editar', extra: pedido),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Excluir',
            onPressed: () => _confirmarExclusao(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildProgressoStatus(),
            const SizedBox(height: 16),
            _buildDetalhesPedido(context),
            const SizedBox(height: 16),
            _buildFinanceiro(),
            const SizedBox(height: 16),
            _buildDatas(),
            if (!pedido.status.isFinalizado) ...[
              const SizedBox(height: 16),
              _buildAcoes(context, ref),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        color: AppColors.secondary,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(pedido.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pedido.status.label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              pedido.clienteNome,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                  .format(pedido.valorTotal),
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );

  Widget _buildProgressoStatus() {
    final statuses = StatusPedido.values
        .where((s) => s != StatusPedido.cancelado)
        .toList();
    final currentIndex = pedido.status == StatusPedido.cancelado
        ? -1
        : statuses.indexOf(pedido.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: pedido.status == StatusPedido.cancelado
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Pedido cancelado',
                        style: TextStyle(color: AppColors.error)),
                  ],
                )
              : Row(
                  children: List.generate(statuses.length * 2 - 1, (i) {
                    if (i.isOdd) {
                      return Expanded(
                        child: Container(
                          height: 2,
                          color: i ~/ 2 < currentIndex
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      );
                    }
                    final idx = i ~/ 2;
                    final reached = idx <= currentIndex;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: reached
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          child: Icon(Icons.check,
                              size: 14,
                              color: reached
                                  ? Colors.white
                                  : Colors.grey.shade400),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 48,
                          child: Text(
                            statuses[idx].label.split(' ').first,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 9,
                                color: reached
                                    ? AppColors.primary
                                    : Colors.grey),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
        ),
      ),
    );
  }

  Widget _buildDetalhesPedido(BuildContext context) {
    final rows = <Widget>[];

    if (pedido.armacaoDescricao != null) {
      rows.add(_infoRow(
          Icons.visibility_outlined, 'Armação', pedido.armacaoDescricao!));
    }
    if (pedido.lenteDescricao != null) {
      rows.add(_infoRow(
          Icons.lens_outlined, 'Lente', pedido.lenteDescricao!));
    }
    if (pedido.numeroPedidoLab != null) {
      rows.add(_infoRow(
          Icons.science_outlined, 'Nº Lab', pedido.numeroPedidoLab!));
    }
    if (pedido.receitaId != null) {
      rows.add(_infoRowWidget(
        Icons.receipt_long_outlined,
        'Receita',
        TextButton(
          onPressed: () =>
              context.push('/prontuario/${pedido.clienteId}'),
          child: const Text('Ver prontuário'),
        ),
      ));
    }
    if (pedido.observacoes != null) {
      rows.add(_infoRow(
          Icons.notes_outlined, 'Obs.', pedido.observacoes!));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detalhes do Pedido',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              ...rows,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceiro() {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Financeiro',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              _infoRow(Icons.attach_money,
                  'Total', fmt.format(pedido.valorTotal)),
              _infoRow(Icons.payments_outlined,
                  'Entrada', fmt.format(pedido.valorEntrada)),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Text('Restante: ',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                  Text(
                    fmt.format(pedido.valorRestante),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatas() {
    final fmt = DateFormat('dd/MM/yyyy');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Datas',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              _infoRow(Icons.calendar_today_outlined, 'Criado em',
                  fmt.format(pedido.criadoEm)),
              if (pedido.dataPrevista != null)
                _infoRow(Icons.schedule_outlined, 'Previsão de entrega',
                    fmt.format(pedido.dataPrevista!)),
              if (pedido.dataEntrega != null)
                _infoRow(Icons.check_circle_outline, 'Entregue em',
                    fmt.format(pedido.dataEntrega!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcoes(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Ações',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              if (pedido.status.proximo != null)
                FilledButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                      'Avançar para: ${pedido.status.proximo!.label}'),
                  onPressed: () =>
                      _avancarStatus(context, ref, pedido.status.proximo!),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.cancel_outlined,
                    color: AppColors.error),
                label: const Text('Cancelar pedido',
                    style: TextStyle(color: AppColors.error)),
                onPressed: () => _confirmarCancelamento(context, ref),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Text('$label: ',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14)),
            ),
          ],
        ),
      );

  Widget _infoRowWidget(IconData icon, String label, Widget widget) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Text('$label: ',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            widget,
          ],
        ),
      );

  Future<void> _avancarStatus(
      BuildContext context, WidgetRef ref, StatusPedido novo) async {
    DateTime? dataEntrega;
    if (novo == StatusPedido.entregue) {
      dataEntrega = DateTime.now();
    }
    try {
      await ref
          .read(pedidoRepositoryProvider)
          .atualizarStatus(pedido.id, novo, dataEntrega: dataEntrega);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  void _confirmarCancelamento(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text(
            'Deseja cancelar este pedido? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Voltar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(pedidoRepositoryProvider)
                  .atualizarStatus(pedido.id, StatusPedido.cancelado);
              if (context.mounted) context.pop();
            },
            child: const Text('Cancelar pedido',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir pedido'),
        content: const Text(
            'Deseja excluir este pedido? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(pedidoRepositoryProvider)
                  .deletar(pedido.id);
              if (context.mounted) context.go('/pedidos');
            },
            child: const Text('Excluir',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
