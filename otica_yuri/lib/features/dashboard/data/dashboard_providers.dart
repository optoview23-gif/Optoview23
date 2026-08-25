import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pedidos/data/pedido_model.dart';
import '../../pedidos/data/pedido_repository.dart';
import '../../caixa/data/transacao_model.dart';
import '../../caixa/data/transacao_repository.dart';

final pedidosPendentesProvider =
    Provider<AsyncValue<List<Pedido>>>((ref) {
  return ref.watch(pedidosStreamProvider).whenData(
      (list) => list.where((p) => !p.status.isFinalizado).toList());
});

final caixaMesSummaryProvider =
    Provider<AsyncValue<CaixaSummary>>((ref) {
  return ref.watch(transacoesStreamProvider).whenData((list) {
    final now = DateTime.now();
    final filtered = list
        .where((t) => t.data.year == now.year && t.data.month == now.month)
        .toList();
    return CaixaSummary.fromList(filtered);
  });
});
