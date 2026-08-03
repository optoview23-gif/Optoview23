import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pedido_model.dart';

class PedidoRepository {
  final FirebaseFirestore _db;
  PedidoRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('pedidos');

  Stream<List<Pedido>> watchAll() => _col
      .orderBy('criadoEm', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Pedido.fromFirestore).toList());

  Stream<List<Pedido>> watchByCliente(String clienteId) => _col
      .where('clienteId', isEqualTo: clienteId)
      .orderBy('criadoEm', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Pedido.fromFirestore).toList());

  Future<void> criar(Map<String, dynamic> data) =>
      _col.add({...data, 'criadoEm': FieldValue.serverTimestamp()});

  Future<void> atualizar(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  Future<void> deletar(String id) => _col.doc(id).delete();

  Future<void> atualizarStatus(String id, StatusPedido status,
      {DateTime? dataEntrega}) async {
    final update = <String, dynamic>{'status': status.value};
    if (dataEntrega != null) {
      update['dataEntrega'] = Timestamp.fromDate(dataEntrega);
    }
    await _col.doc(id).update(update);
  }
}

final pedidoRepositoryProvider = Provider<PedidoRepository>(
    (ref) => PedidoRepository(FirebaseFirestore.instance));

final pedidosStreamProvider = StreamProvider<List<Pedido>>(
    (ref) => ref.watch(pedidoRepositoryProvider).watchAll());

final pedidosByClienteProvider =
    StreamProvider.family<List<Pedido>, String>((ref, clienteId) =>
        ref.watch(pedidoRepositoryProvider).watchByCliente(clienteId));

final pedidoStatusFilterProvider =
    StateProvider<StatusPedido?>((ref) => null);

final pedidoSearchQueryProvider = StateProvider<String>((ref) => '');

final pedidosFiltradosProvider =
    Provider<AsyncValue<List<Pedido>>>((ref) {
  final all = ref.watch(pedidosStreamProvider);
  final status = ref.watch(pedidoStatusFilterProvider);
  final query = ref.watch(pedidoSearchQueryProvider).trim().toLowerCase();

  return all.whenData((pedidos) {
    var list = pedidos;
    if (status != null) {
      list = list.where((p) => p.status == status).toList();
    }
    if (query.isNotEmpty) {
      list = list
          .where((p) => p.clienteNome.toLowerCase().contains(query))
          .toList();
    }
    return list;
  });
});
