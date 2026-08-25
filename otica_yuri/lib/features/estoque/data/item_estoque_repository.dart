import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'item_estoque_model.dart';

class ItemEstoqueRepository {
  final FirebaseFirestore _db;
  ItemEstoqueRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('estoque');

  Stream<List<ItemEstoque>> watchAll() => _col
      .orderBy('criadoEm', descending: true)
      .snapshots()
      .map((s) => s.docs.map(ItemEstoque.fromFirestore).toList());

  Future<void> criar(Map<String, dynamic> data) =>
      _col.add({...data, 'criadoEm': FieldValue.serverTimestamp()});

  Future<void> atualizar(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  Future<void> deletar(String id) => _col.doc(id).delete();

  Future<void> ajustarQuantidade(String id, int delta) =>
      _col.doc(id).update({'quantidade': FieldValue.increment(delta)});
}

final itemEstoqueRepositoryProvider = Provider<ItemEstoqueRepository>(
    (ref) => ItemEstoqueRepository(FirebaseFirestore.instance));

final estoqueStreamProvider = StreamProvider<List<ItemEstoque>>(
    (ref) => ref.watch(itemEstoqueRepositoryProvider).watchAll());

final estoqueCategoriaProvider =
    StateProvider<CategoriaEstoque?>((ref) => null);

final estoqueSearchQueryProvider = StateProvider<String>((ref) => '');

final estoqueFiltradoProvider =
    Provider<AsyncValue<List<ItemEstoque>>>((ref) {
  final all = ref.watch(estoqueStreamProvider);
  final categoria = ref.watch(estoqueCategoriaProvider);
  final query = ref.watch(estoqueSearchQueryProvider).trim().toLowerCase();

  return all.whenData((items) {
    var list = items;
    if (categoria != null) {
      list = list.where((i) => i.categoria == categoria).toList();
    }
    if (query.isNotEmpty) {
      list = list
          .where((i) =>
              i.nomeExibicao.toLowerCase().contains(query) ||
              (i.codigo?.toLowerCase().contains(query) ?? false))
          .toList();
    }
    return list;
  });
});

final estoqueAlertasProvider = Provider<AsyncValue<List<ItemEstoque>>>((ref) {
  return ref.watch(estoqueStreamProvider).whenData(
      (items) => items.where((i) => i.estoqueBaixo || i.semEstoque).toList());
});
