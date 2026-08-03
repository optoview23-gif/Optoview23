import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/cliente_model.dart';
import '../data/cliente_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_avatar.dart';

class ClientePerfilScreen extends ConsumerWidget {
  final String clienteId;
  const ClientePerfilScreen({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteAsync = ref.watch(clientePorIdProvider(clienteId));

    return clienteAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Cliente')),
        body: Center(child: Text('Erro: $e')),
      ),
      data: (cliente) {
        if (cliente == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cliente')),
            body: const Center(child: Text('Cliente não encontrado')),
          );
        }
        return _ClientePerfilView(cliente: cliente);
      },
    );
  }
}

class _ClientePerfilView extends ConsumerWidget {
  final Cliente cliente;
  const _ClientePerfilView({required this.cliente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cliente.nome, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => context.push(
              '/clientes/${cliente.id}/editar',
              extra: cliente,
            ),
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
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDados(),
            const SizedBox(height: 16),
            _buildHistorico(context),
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
        child: Row(
          children: [
            AppAvatar(
                fotoUrl: cliente.fotoUrl,
                nome: cliente.nome,
                radius: 48),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nome,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (cliente.dataNascimento != null)
                    Text(
                      _idade(cliente.dataNascimento!),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Cliente desde ${DateFormat('MM/yyyy').format(cliente.criadoEm)}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildDados() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dados',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
                const SizedBox(height: 12),
                _infoRow(
                    Icons.badge_outlined, 'CPF', _maskCpf(cliente.cpf)),
                if (cliente.rg != null)
                  _infoRow(
                      Icons.credit_card_outlined, 'RG', cliente.rg!),
                _infoRow(Icons.phone_outlined, 'Telefone',
                    cliente.telefone),
                if (cliente.whatsapp != null)
                  _infoRow(Icons.message_outlined, 'WhatsApp',
                      cliente.whatsapp!),
                if (cliente.dataNascimento != null)
                  _infoRow(
                    Icons.cake_outlined,
                    'Nascimento',
                    DateFormat('dd/MM/yyyy')
                        .format(cliente.dataNascimento!),
                  ),
                if (cliente.endereco != null)
                  _infoRow(Icons.location_on_outlined, 'Endereço',
                      cliente.endereco!),
              ],
            ),
          ),
        ),
      );

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

  Widget _buildHistorico(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico',
              style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            _historicoCard(
              icon: Icons.visibility_outlined,
              titulo: 'Prontuário Ótico',
              subtitulo: 'Receitas e histórico de consultas',
              onTap: () => context.push('/prontuario/${cliente.id}'),
            ),
            const SizedBox(height: 8),
            _historicoCard(
              icon: Icons.shopping_bag_outlined,
              titulo: 'Pedidos',
              subtitulo: 'Histórico de pedidos de óculos',
              onTap: () =>
                  context.push('/clientes/${cliente.id}/pedidos'),
            ),
          ],
        ),
      );

  Widget _historicoCard({
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) =>
      Card(
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: Text(titulo),
          subtitle: Text(subtitulo,
              style: const TextStyle(color: AppColors.textSecondary)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );

  String _maskCpf(String cpf) {
    final d = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length != 11) return cpf;
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
  }

  String _idade(DateTime nasc) {
    final hoje = DateTime.now();
    int idade = hoje.year - nasc.year;
    if (hoje.month < nasc.month ||
        (hoje.month == nasc.month && hoje.day < nasc.day)) {
      idade--;
    }
    return '$idade anos';
  }

  void _confirmarExclusao(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cliente'),
        content: Text(
          'Deseja excluir "${cliente.nome}"?\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(clienteRepositoryProvider)
                  .deletar(cliente.id);
              if (context.mounted) context.go('/clientes');
            },
            child: const Text('Excluir',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
