import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/cliente_model.dart';
import '../data/cliente_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_avatar.dart';

class ClientesScreen extends ConsumerStatefulWidget {
  const ClientesScreen({super.key});

  @override
  ConsumerState<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends ConsumerState<ClientesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesFiltradosProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/clientes/novo'),
        icon: const Icon(Icons.person_add),
        label: const Text('Novo Cliente'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildList(clientes)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar por nome, CPF ou telefone...',
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

  Widget _buildList(AsyncValue<List<Cliente>> value) => value.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Erro ao carregar clientes: $e')),
        data: (clientes) {
          if (clientes.isEmpty) return _buildEmpty();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            itemCount: clientes.length,
            itemBuilder: (_, i) =>
                _ClienteCard(cliente: clientes[i]),
          );
        },
      );

  Widget _buildEmpty() {
    final query = ref.read(clienteSearchQueryProvider);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            query.isNotEmpty
                ? 'Nenhum resultado para "$query"'
                : 'Nenhum cliente cadastrado',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 16),
          ),
          if (query.isEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Toque em "Novo Cliente" para começar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final Cliente cliente;
  const _ClienteCard({required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: AppAvatar(
            fotoUrl: cliente.fotoUrl, nome: cliente.nome, radius: 28),
        title: Text(
          cliente.nome,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_maskCpf(cliente.cpf)}  •  ${cliente.telefone}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/clientes/${cliente.id}'),
      ),
    );
  }

  String _maskCpf(String cpf) {
    final d = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length != 11) return cpf;
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
  }
}
