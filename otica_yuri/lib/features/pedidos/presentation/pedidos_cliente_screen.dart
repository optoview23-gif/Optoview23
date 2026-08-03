import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/pedido_model.dart';
import '../data/pedido_repository.dart';
import '../../clientes/data/cliente_repository.dart';
import '../../../core/constants/app_colors.dart';

Color _statusColor(StatusPedido s) => switch (s) {
      StatusPedido.orcamento => Colors.grey,
      StatusPedido.confirmado => Colors.blue,
      StatusPedido.emLaboratorio => Colors.orange,
      StatusPedido.pronto => AppColors.primary,
      StatusPedido.entregue => Colors.teal,
      StatusPedido.cancelado => AppColors.error,
    };

class PedidosClienteScreen extends ConsumerWidget {
  final String clienteId;
  const PedidosClienteScreen({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteAsync = ref.watch(clientePorIdProvider(clienteId));
    final pedidosAsync = ref.watch(pedidosByClienteProvider(clienteId));

    final clienteNome =
        clienteAsync.value?.nome ?? 'Pedidos';

    return Scaffold(
      appBar: AppBar(title: Text(clienteNome)),
      body: pedidosAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (pedidos) => pedidos.isEmpty
            ? _buildEmpty(context, clienteNome)
            : ListView.builder(
                itemCount: pedidos.length,
                padding: const EdgeInsets.only(bottom: 80),
                itemBuilder: (_, i) =>
                    _PedidoClienteCard(pedido: pedidos[i]),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/pedidos/novo',
          extra: <String, String?>{
            'clienteId': clienteId,
            'clienteNome': clienteNome,
          },
        ),
        icon: const Icon(Icons.add),
        label: const Text('Novo Pedido'),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String clienteNome) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.textSecondary.withAlpha(128)),
            const SizedBox(height: 16),
            const Text('Nenhum pedido registrado',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push(
                '/pedidos/novo',
                extra: <String, String?>{
                  'clienteId': clienteId,
                  'clienteNome': clienteNome,
                },
              ),
              icon: const Icon(Icons.add),
              label: const Text('Criar primeiro pedido'),
            ),
          ],
        ),
      );
}

class _PedidoClienteCard extends StatelessWidget {
  final Pedido pedido;
  const _PedidoClienteCard({required this.pedido});

  @override
  Widget build(BuildContext context) {
    final priceFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(pedido.status).withAlpha(30),
          child: Icon(_statusIcon(pedido.status),
              color: _statusColor(pedido.status), size: 20),
        ),
        title: Text(
          _descricaoPedido(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            _StatusChip(status: pedido.status),
            if (pedido.dataPrevista != null) ...[
              const SizedBox(height: 2),
              Text(
                'Prev.: ${DateFormat('dd/MM/yyyy').format(pedido.dataPrevista!)}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
        trailing: Text(
          priceFormat.format(pedido.valorTotal),
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        isThreeLine: pedido.dataPrevista != null,
        onTap: () =>
            context.push('/pedidos/${pedido.id}', extra: pedido),
      ),
    );
  }

  String _descricaoPedido() {
    final parts = <String>[];
    if (pedido.armacaoDescricao != null) {
      parts.add(pedido.armacaoDescricao!);
    }
    if (pedido.lenteDescricao != null) parts.add(pedido.lenteDescricao!);
    if (parts.isEmpty) {
      return DateFormat('dd/MM/yyyy').format(pedido.criadoEm);
    }
    return parts.join(' + ');
  }
}

class _StatusChip extends StatelessWidget {
  final StatusPedido status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: _statusColor(status).withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _statusColor(status).withAlpha(100), width: 1),
        ),
        child: Text(
          status.label,
          style: TextStyle(
              fontSize: 11,
              color: _statusColor(status),
              fontWeight: FontWeight.w600),
        ),
      );
}

IconData _statusIcon(StatusPedido s) => switch (s) {
      StatusPedido.orcamento => Icons.pending_outlined,
      StatusPedido.confirmado => Icons.check_circle_outline,
      StatusPedido.emLaboratorio => Icons.science_outlined,
      StatusPedido.pronto => Icons.done_all,
      StatusPedido.entregue => Icons.shopping_bag_outlined,
      StatusPedido.cancelado => Icons.cancel_outlined,
    };
