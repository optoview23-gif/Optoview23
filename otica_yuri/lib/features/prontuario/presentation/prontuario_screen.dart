import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../clientes/data/cliente_model.dart';
import '../../clientes/data/cliente_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_avatar.dart';

class ProntuarioScreen extends ConsumerStatefulWidget {
  const ProntuarioScreen({super.key});

  @override
  ConsumerState<ProntuarioScreen> createState() =>
      _ProntuarioScreenState();
}

class _ProntuarioScreenState extends ConsumerState<ProntuarioScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesFiltradosProvider);
    final query = ref.watch(clienteSearchQueryProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody(clientes, query)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar cliente por nome, CPF ou telefone...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref
                          .read(clienteSearchQueryProvider.notifier)
                          .state = '';
                    },
                  )
                : null,
          ),
          onChanged: (v) =>
              ref.read(clienteSearchQueryProvider.notifier).state = v,
        ),
      );

  Widget _buildBody(
      AsyncValue<List<Cliente>> clientes, String query) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_outlined,
                size: 72,
                color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text(
              'Busque um cliente para ver o prontuário',
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return clientes.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (list) => list.isEmpty
          ? Center(
              child: Text(
                'Nenhum cliente encontrado para "$query"',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: list.length,
              itemBuilder: (_, i) => _ClienteItem(cliente: list[i]),
            ),
    );
  }
}

class _ClienteItem extends StatelessWidget {
  final Cliente cliente;
  const _ClienteItem({required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: AppAvatar(
            fotoUrl: cliente.fotoUrl,
            nome: cliente.nome,
            radius: 24),
        title: Text(cliente.nome,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          cliente.telefone,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            context.push('/prontuario/${cliente.id}'),
      ),
    );
  }
}
