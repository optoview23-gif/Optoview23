import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/receita_model.dart';
import '../data/receita_repository.dart';
import '../../../core/constants/app_colors.dart';

class ReceitaDetalheScreen extends ConsumerWidget {
  final String clienteId;
  final Receita receita;

  const ReceitaDetalheScreen(
      {super.key, required this.clienteId, required this.receita});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Receita — ${DateFormat('dd/MM/yyyy').format(receita.data)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => context.push(
              '/prontuario/$clienteId/${receita.id}/editar',
              extra: receita,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildGrauCard(),
            if (receita.observacoes != null &&
                receita.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildObservacoesCard(),
            ],
            if (receita.fotoUrl != null) ...[
              const SizedBox(height: 16),
              _buildFotoCard(),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow(Icons.calendar_today_outlined, 'Data',
                  DateFormat('dd/MM/yyyy').format(receita.data)),
              if (receita.optometrista.isNotEmpty)
                _infoRow(Icons.person_outline, 'Optometrista',
                    receita.optometrista),
            ],
          ),
        ),
      );

  Widget _infoRow(IconData icon, String label, String value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Text('$label: ',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14)),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _buildGrauCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Graus',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 16),
              Table(
                columnWidths: const {
                  0: FixedColumnWidth(48),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                  4: FlexColumnWidth(),
                  5: FlexColumnWidth(),
                },
                defaultVerticalAlignment:
                    TableCellVerticalAlignment.middle,
                children: [
                  _headerRow(),
                  _valueRow('OD', receita.od, isFirst: true),
                  _valueRow('OE', receita.oe, isFirst: false),
                ],
              ),
            ],
          ),
        ),
      );

  TableRow _headerRow() => TableRow(
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: AppColors.primary, width: 0.5))),
        children: [
          const SizedBox(height: 28),
          ...['ESF', 'CIL', 'EIXO', 'ADD', 'DNP'].map((h) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Center(
                  child: Text(h,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          fontSize: 13)),
                ),
              )),
        ],
      );

  TableRow _valueRow(String label, GrauOlho g,
      {required bool isFirst}) =>
      TableRow(
        decoration: isFirst
            ? null
            : const BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: Color(0xFFE0E0E0), width: 0.5))),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      fontSize: 14)),
            ),
          ),
          _valueCell(_fmtGrau(g.esf)),
          _valueCell(_fmtGrau(g.cil)),
          _valueCell(
              g.eixo != null ? '${g.eixo}°' : '—'),
          _valueCell(_fmtAdd(g.add)),
          _valueCell(
              g.dnp != null ? '${g.dnp!.toStringAsFixed(1)}mm' : '—'),
        ],
      );

  Widget _valueCell(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: text == '—'
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: text == '—'
                  ? FontWeight.normal
                  : FontWeight.w500,
            ),
          ),
        ),
      );

  String _fmtGrau(double? v) {
    if (v == null) return '—';
    if (v == 0) return '0,00';
    final s = v.toStringAsFixed(2).replaceAll('.', ',');
    return v > 0 ? '+$s' : s;
  }

  String _fmtAdd(double? v) {
    if (v == null) return '—';
    final s = v.toStringAsFixed(2).replaceAll('.', ',');
    return '+$s';
  }

  Widget _buildObservacoesCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Observações',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 8),
              Text(receita.observacoes!,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.5)),
            ],
          ),
        ),
      );

  Widget _buildFotoCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Receita Original (Scan)',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  receita.fotoUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) =>
                      progress == null
                          ? child
                          : const SizedBox(
                              height: 120,
                              child: Center(
                                  child:
                                      CircularProgressIndicator())),
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 80,
                    child: Center(
                        child: Icon(Icons.broken_image,
                            color: AppColors.textSecondary)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  void _confirmarExclusao(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir receita'),
        content: Text(
          'Excluir receita de ${DateFormat('dd/MM/yyyy').format(receita.data)}?\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(receitaRepositoryProvider)
                  .deletar(clienteId, receita.id);
              if (context.mounted) context.pop();
            },
            child: const Text('Excluir',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
