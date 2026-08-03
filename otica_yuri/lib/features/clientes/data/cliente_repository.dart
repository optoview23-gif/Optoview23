import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cliente_model.dart';

class ClienteRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  ClienteRepository(this._db, this._storage);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('clientes');

  Stream<List<Cliente>> watchAll() => _col
      .orderBy('nome')
      .snapshots()
      .map((snap) => snap.docs.map(Cliente.fromFirestore).toList());

  Stream<Cliente?> watchById(String id) => _col.doc(id).snapshots().map(
      (doc) => doc.exists ? Cliente.fromFirestore(doc) : null);

  Future<String> criar(Map<String, dynamic> data) async {
    final ref = await _col
        .add({...data, 'criadoEm': FieldValue.serverTimestamp()});
    return ref.id;
  }

  Future<void> atualizar(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  Future<void> deletar(String id) => _col.doc(id).delete();

  Future<String> uploadFoto(String clienteId, File foto) async {
    final ref = _storage.ref('clientes/$clienteId/foto.jpg');
    await ref.putFile(foto, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}

final clienteRepositoryProvider = Provider<ClienteRepository>((ref) =>
    ClienteRepository(
        FirebaseFirestore.instance, FirebaseStorage.instance));

final clientesStreamProvider = StreamProvider<List<Cliente>>(
    (ref) => ref.watch(clienteRepositoryProvider).watchAll());

final clientePorIdProvider =
    StreamProvider.family<Cliente?, String>((ref, id) =>
        ref.watch(clienteRepositoryProvider).watchById(id));

final clienteSearchQueryProvider = StateProvider<String>((ref) => '');

final clientesFiltradosProvider =
    Provider<AsyncValue<List<Cliente>>>((ref) {
  final query =
      ref.watch(clienteSearchQueryProvider).toLowerCase().trim();
  final clientes = ref.watch(clientesStreamProvider);
  if (query.isEmpty) return clientes;
  final digits = query.replaceAll(RegExp(r'[^0-9]'), '');
  return clientes.whenData((list) => list
      .where((c) =>
          c.nome.toLowerCase().contains(query) ||
          (digits.isNotEmpty &&
              c.cpf
                  .replaceAll(RegExp(r'[^0-9]'), '')
                  .contains(digits)) ||
          (digits.isNotEmpty &&
              c.telefone
                  .replaceAll(RegExp(r'[^0-9]'), '')
                  .contains(digits)))
      .toList());
});
