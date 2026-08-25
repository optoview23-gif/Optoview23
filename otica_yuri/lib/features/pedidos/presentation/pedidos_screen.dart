import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/pedido_model.dart';
import '../data/pedido_repository.dart';
import '../../../core/constants/app_colors.dart';

class PedidosScreen extends ConsumerStatefulWidget {
  const PedidosScreen({super.key});

  @override
  ConsumerState<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends ConsumerState<PedidosScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtrado = ref.watch(pedidosFiltradosProvider);
    final statusAtual = ref.watch(pedidoStatusFilterProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatusChips(statusAtual),
          Expanded(
            child: filtrado.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (pedidos) => pedidos.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      itemCount: pedidos.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (_, i) =>
                          _PedidoCard(pedido: pedidos[i]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/pedidos/novo'),
        icon: const Icon(Icons.add),
        label: const Text('Novo Pedido'),
      ),
    );
  }

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Buscar por cliente...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      ref
                          .read(pedidoSearchQueryProvider.notifier)
                          .state = '';
                    },
                  )
                : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
          onChanged: (v) =>
              ref.read(pedidoSearchQueryProvider.notifier).state = v,
        ),
      );

  Widget _buildStatusChips(StatusPedido? current) =>
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            _chip(null, 'Todos', current),
            const SizedBox(width: 8),
            ...StatusPedido.values.map(
              (s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _chip(s, s.label, current),
              ),
            ),
          ],
        ),
      );

  Widget _chip(StatusPedido? value, String label, StatusPedido? current) =>
      ChoiceChip(
        label: Text(label),
        selected: current == value,
        onSelected: (_) =>
            ref.read(pedidoStatusFilterProvider.notifier).state = value,
        selectedColor: value == null ? AppColors.primary : _statusColor(value),
        labelStyle: TextStyle(
          color: current == value ? Colors.white : AppColors.textPrimary,
          fontSize: 13,
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.textSecondary.withAlpha(128)),
            const SizedBox(height: 16),
            const Text('Nenhum pedido encontrado',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
}

Color _statusColor(StatusPedido s) => switch (s) {
      StatusPedido.orcamento => Colors.grey,
      StatusPedido.confirmado => Colors.blue,
      StatusPedido.emLaboratorio => Colors.orange,
      StatusPedido.pronto => AppColors.primary,
      StatusPedido.entregue => Colors.teal,
      StatusPedido.cancelado => AppColors.error,
    };

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  const _PedidoCard({required this.pedido});

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
        title: Text(pedido.clienteNome,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            _StatusChip(status: pedido.status),
            if (pedido.dataPrevista != null) ...[
              const SizedBox(height: 2),
              Text(
                'Previsão: ${DateFormat('dd/MM/yyyy').format(pedido.dataPrevista!)}',
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
