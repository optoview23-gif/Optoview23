import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/item_estoque_model.dart';
import '../data/item_estoque_repository.dart';
import '../../../core/constants/app_colors.dart';

class EstoqueScreen extends ConsumerStatefulWidget {
  const EstoqueScreen({super.key});

  @override
  ConsumerState<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends ConsumerState<EstoqueScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtrado = ref.watch(estoqueFiltradoProvider);
    final alertas = ref.watch(estoqueAlertasProvider);
    final categoriaAtual = ref.watch(estoqueCategoriaProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(categoriaAtual),
          alertas.whenData((list) => list.isNotEmpty
              ? _buildAlertBanner(list.length)
              : const SizedBox.shrink()).value ??
              const SizedBox.shrink(),
          Expanded(
            child: filtrado.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (items) => items.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      itemCount: items.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (_, i) =>
                          _ItemEstoqueCard(item: items[i]),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/estoque/novo'),
        icon: const Icon(Icons.add),
        label: const Text('Novo Item'),
      ),
    );
  }

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Buscar por nome ou código...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      ref
                          .read(estoqueSearchQueryProvider.notifier)
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
              ref.read(estoqueSearchQueryProvider.notifier).state = v,
        ),
      );

  Widget _buildCategoryChips(CategoriaEstoque? current) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            _chip(null, 'Todos', current),
            const SizedBox(width: 8),
            ...CategoriaEstoque.values
                .map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _chip(c, c.label, current),
                    )),
          ],
        ),
      );

  Widget _chip(
          CategoriaEstoque? value, String label, CategoriaEstoque? current) =>
      ChoiceChip(
        label: Text(label),
        selected: current == value,
        onSelected: (_) =>
            ref.read(estoqueCategoriaProvider.notifier).state = value,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: current == value ? Colors.white : AppColors.textPrimary,
        ),
      );

  Widget _buildAlertBanner(int count) => Container(
        color: Colors.orange.shade100,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$count ${count == 1 ? 'item com' : 'itens com'} estoque baixo ou zerado',
                style: const TextStyle(
                    fontSize: 13, color: Colors.deepOrange),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(estoqueCategoriaProvider.notifier).state = null;
                ref.read(estoqueSearchQueryProvider.notifier).state = '';
                _searchCtrl.clear();
              },
              child: const Text('Ver todos'),
            ),
          ],
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.textSecondary.withAlpha(128)),
            const SizedBox(height: 16),
            const Text('Nenhum item encontrado',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
}

class _ItemEstoqueCard extends ConsumerWidget {
  final ItemEstoque item;
  const _ItemEstoqueCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildLeading(),
        title: Text(item.nomeExibicao,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: _buildSubtitle(),
        trailing: _buildQuantidade(),
        onTap: () => context.push('/estoque/${item.id}', extra: item),
      ),
    );
  }

  Widget _buildLeading() {
    final icon = switch (item.categoria) {
      CategoriaEstoque.armacao => Icons.visibility_outlined,
      CategoriaEstoque.lente => Icons.lens_outlined,
      CategoriaEstoque.acessorio => Icons.category_outlined,
    };
    return CircleAvatar(
      backgroundColor: AppColors.secondary.withAlpha(30),
      child: Icon(icon, color: AppColors.secondary, size: 20),
    );
  }

  Widget _buildSubtitle() {
    final parts = <String>[item.categoria.label];
    if (item.cor != null) parts.add(item.cor!);
    if (item.codigo != null) parts.add('Cód: ${item.codigo}');
    return Text(parts.join(' · '),
        style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 12));
  }

  Widget _buildQuantidade() {
    Color color;
    if (item.semEstoque) {
      color = AppColors.error;
    } else if (item.estoqueBaixo) {
      color = Colors.orange;
    } else {
      color = AppColors.primary;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${item.quantidade}',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const Text('un',
            style:
                TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
