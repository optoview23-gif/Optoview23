import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../clientes/data/cliente_repository.dart';
import '../data/receita_model.dart';
import '../data/receita_repository.dart';
import '../../../core/constants/app_colors.dart';

class ReceitasClienteScreen extends ConsumerWidget {
  final String clienteId;
  const ReceitasClienteScreen({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clienteAsync = ref.watch(clientePorIdProvider(clienteId));
    final receitasAsync = ref.watch(receitasByClienteProvider(clienteId));
    final nomeCliente =
        clienteAsync.valueOrNull?.nome ?? 'Prontuário';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Prontuário',
                style: TextStyle(
                    fontSize: 12, color: Colors.white70)),
            Text(nomeCliente,
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/prontuario/$clienteId/nova'),
        icon: const Icon(Icons.add),
        label: const Text('Nova Receita'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: receitasAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text('Erro ao carregar receitas: $e')),
        data: (receitas) => receitas.isEmpty
            ? _buildEmpty(context)
            : ListView.builder(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: receitas.length,
                itemBuilder: (_, i) => _ReceitaCard(
                  receita: receitas[i],
                  onTap: () => context.push(
                      '/prontuario/$clienteId/${receitas[i].id}',
                      extra: receitas[i]),
                ),
              ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_outlined,
                size: 72,
                color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('Nenhuma receita cadastrada',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Toque em "Nova Receita" para adicionar',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
}

class _ReceitaCard extends StatelessWidget {
  final Receita receita;
  final VoidCallback onTap;
  const _ReceitaCard({required this.receita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd/MM/yyyy').format(receita.data),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  if (receita.optometrista.isNotEmpty)
                    Text(
                      receita.optometrista,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 10),
              _grauRow('OD', receita.od),
              const SizedBox(height: 4),
              _grauRow('OE', receita.oe),
            ],
          ),
        ),
      ),
    );
  }

  Widget _grauRow(String label, GrauOlho grau) => Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  fontSize: 13),
            ),
          ),
          Text(
            grau.resumo,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 13),
          ),
        ],
      );
}
