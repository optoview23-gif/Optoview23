import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/item_estoque_model.dart';
import '../data/item_estoque_repository.dart';
import '../../../core/constants/app_colors.dart';

class ItemEstoqueDetalheScreen extends ConsumerWidget {
  final ItemEstoque item;
  const ItemEstoqueDetalheScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.nomeExibicao, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () =>
                context.push('/estoque/${item.id}/editar', extra: item),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildEstoqueCard(context, ref),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    Color statusColor;
    String statusLabel;
    if (item.semEstoque) {
      statusColor = AppColors.error;
      statusLabel = 'Sem estoque';
    } else if (item.estoqueBaixo) {
      statusColor = Colors.orange;
      statusLabel = 'Estoque baixo';
    } else {
      statusColor = AppColors.primary;
      statusLabel = 'Em estoque';
    }

    return Container(
      color: AppColors.secondary,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item.categoria.label,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(200),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item.nomeExibicao,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${item.quantidade}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Text('unidades',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final priceFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final rows = <Widget>[];

    switch (item.categoria) {
      case CategoriaEstoque.armacao:
        if (item.marca != null) {
          rows.add(_infoRow(Icons.business_outlined, 'Marca', item.marca!));
        }
        if (item.modelo != null) {
          rows.add(_infoRow(Icons.tag_outlined, 'Modelo', item.modelo!));
        }
        if (item.cor != null) {
          rows.add(_infoRow(Icons.palette_outlined, 'Cor', item.cor!));
        }
        break;
      case CategoriaEstoque.lente:
        if (item.tipo != null) {
          rows.add(_infoRow(Icons.lens_outlined, 'Tipo', item.tipo!));
        }
        if (item.tratamento != null) {
          rows.add(_infoRow(
              Icons.auto_fix_high_outlined, 'Tratamento', item.tratamento!));
        }
        break;
      case CategoriaEstoque.acessorio:
        break;
    }

    if (item.codigo != null) {
      rows.add(_infoRow(Icons.qr_code_outlined, 'Código', item.codigo!));
    }

    rows.add(_infoRow(
      Icons.attach_money,
      'Preço de Venda',
      priceFormat.format(item.precoVenda),
    ));
    if (item.precoCusto != null) {
      rows.add(_infoRow(
        Icons.money_off_outlined,
        'Preço de Custo',
        priceFormat.format(item.precoCusto),
      ));
    }
    rows.add(_infoRow(
      Icons.calendar_today_outlined,
      'Cadastrado em',
      DateFormat('dd/MM/yyyy').format(item.criadoEm),
    ));

    if (rows.isEmpty) return const SizedBox.shrink();

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
              ...rows,
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

  Widget _buildEstoqueCard(BuildContext context, WidgetRef ref) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajuste de Estoque',
                    style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  'Mínimo configurado: ${item.quantidadeMinima} unidades',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _adjustButton(
                      context, ref,
                      icon: Icons.remove,
                      delta: -1,
                      enabled: item.quantidade > 0,
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '${item.quantidade}',
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 24),
                    _adjustButton(
                      context, ref,
                      icon: Icons.add,
                      delta: 1,
                      enabled: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('Entrada em lote'),
                      onPressed: () =>
                          _ajustarLote(context, ref, isEntrada: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Saída em lote'),
                      onPressed: () =>
                          _ajustarLote(context, ref, isEntrada: false),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      );

  Widget _adjustButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required int delta,
    required bool enabled,
  }) =>
      FilledButton(
        onPressed: enabled
            ? () => _ajustar(context, ref, delta)
            : null,
        style: FilledButton.styleFrom(
          backgroundColor: delta > 0 ? AppColors.primary : AppColors.error,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16),
        ),
        child: Icon(icon, color: Colors.white),
      );

  Future<void> _ajustar(
      BuildContext context, WidgetRef ref, int delta) async {
    try {
      await ref
          .read(itemEstoqueRepositoryProvider)
          .ajustarQuantidade(item.id, delta);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  Future<void> _ajustarLote(
      BuildContext context, WidgetRef ref, {required bool isEntrada}) async {
    final ctrl = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEntrada ? 'Entrada de estoque' : 'Saída de estoque'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: 'Quantidade', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (result != null && context.mounted) {
      await _ajustar(context, ref, isEntrada ? result : -result);
    }
  }

  void _confirmarExclusao(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text(
            'Deseja excluir "${item.nomeExibicao}"?\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(itemEstoqueRepositoryProvider)
                  .deletar(item.id);
              if (context.mounted) context.go('/estoque');
            },
            child: const Text('Excluir',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
