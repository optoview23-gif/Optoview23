import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'transacao_model.dart';

enum PeriodoCaixa { hoje, semana, mes, todos }

class TransacaoRepository {
  final FirebaseFirestore _db;
  TransacaoRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('caixa');

  Stream<List<Transacao>> watchAll() => _col
      .orderBy('data', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Transacao.fromFirestore).toList());

  Future<void> criar(Map<String, dynamic> data) =>
      _col.add({...data, 'criadoEm': FieldValue.serverTimestamp()});

  Future<void> atualizar(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  Future<void> deletar(String id) => _col.doc(id).delete();
}

final transacaoRepositoryProvider = Provider<TransacaoRepository>(
    (ref) => TransacaoRepository(FirebaseFirestore.instance));

final transacoesStreamProvider = StreamProvider<List<Transacao>>(
    (ref) => ref.watch(transacaoRepositoryProvider).watchAll());

final caixaPeriodoProvider =
    StateProvider<PeriodoCaixa>((ref) => PeriodoCaixa.mes);

final caixaTipoFilterProvider =
    StateProvider<TipoTransacao?>((ref) => null);

final transacoesFiltradosProvider =
    Provider<AsyncValue<List<Transacao>>>((ref) {
  final all = ref.watch(transacoesStreamProvider);
  final periodo = ref.watch(caixaPeriodoProvider);
  final tipo = ref.watch(caixaTipoFilterProvider);

  return all.whenData((list) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    DateTime? desde;
    switch (periodo) {
      case PeriodoCaixa.hoje:
        desde = hoje;
        break;
      case PeriodoCaixa.semana:
        desde = hoje.subtract(const Duration(days: 7));
        break;
      case PeriodoCaixa.mes:
        desde = DateTime(agora.year, agora.month, 1);
        break;
      case PeriodoCaixa.todos:
        desde = null;
        break;
    }

    var filtered = list;
    if (desde != null) {
      filtered = filtered
          .where((t) =>
              t.data.isAfter(desde!.subtract(const Duration(seconds: 1))))
          .toList();
    }
    if (tipo != null) {
      filtered = filtered.where((t) => t.tipo == tipo).toList();
    }
    return filtered;
  });
});

final caixaSummaryProvider =
    Provider<AsyncValue<CaixaSummary>>((ref) {
  return ref.watch(transacoesFiltradosProvider).whenData(
      (list) => CaixaSummary.fromList(list));
});
