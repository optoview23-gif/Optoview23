import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'receita_model.dart';

class ReceitaRepository {
  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  ReceitaRepository(this._db, this._storage);

  CollectionReference<Map<String, dynamic>> _col(String clienteId) =>
      _db
          .collection('clientes')
          .doc(clienteId)
          .collection('receitas');

  Stream<List<Receita>> watchByCliente(String clienteId) =>
      _col(clienteId)
          .orderBy('data', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => Receita.fromFirestore(doc, clienteId))
              .toList());

  Future<String> criar(String clienteId, Map<String, dynamic> data) async {
    final ref = await _col(clienteId)
        .add({...data, 'criadoEm': FieldValue.serverTimestamp()});
    return ref.id;
  }

  Future<void> atualizar(
          String clienteId, String id, Map<String, dynamic> data) =>
      _col(clienteId).doc(id).update(data);

  Future<void> deletar(String clienteId, String id) =>
      _col(clienteId).doc(id).delete();

  Future<String> uploadFoto(
      String clienteId, String receitaId, File foto) async {
    final ref =
        _storage.ref('receitas/$clienteId/$receitaId.jpg');
    await ref.putFile(foto, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}

final receitaRepositoryProvider = Provider<ReceitaRepository>((ref) =>
    ReceitaRepository(
        FirebaseFirestore.instance, FirebaseStorage.instance));

final receitasByClienteProvider =
    StreamProvider.family<List<Receita>, String>((ref, clienteId) =>
        ref.watch(receitaRepositoryProvider).watchByCliente(clienteId));
