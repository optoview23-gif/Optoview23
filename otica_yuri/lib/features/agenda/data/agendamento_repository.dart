import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'agendamento_model.dart';

class AgendamentoRepository {
  final FirebaseFirestore _db;
  AgendamentoRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('agenda');

  Stream<List<Agendamento>> watchByDia(DateTime dia) {
    final inicio = DateTime(dia.year, dia.month, dia.day);
    final fim = inicio.add(const Duration(days: 1));
    return _col
        .where('inicio',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('inicio', isLessThan: Timestamp.fromDate(fim))
        .orderBy('inicio')
        .snapshots()
        .map((s) => s.docs.map(Agendamento.fromFirestore).toList());
  }

  Stream<List<Agendamento>> watchBySemana(DateTime semana) {
    final inicio = DateTime(semana.year, semana.month, semana.day)
        .subtract(Duration(days: semana.weekday - 1));
    final fim = inicio.add(const Duration(days: 7));
    return _col
        .where('inicio',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
        .where('inicio', isLessThan: Timestamp.fromDate(fim))
        .orderBy('inicio')
        .snapshots()
        .map((s) => s.docs.map(Agendamento.fromFirestore).toList());
  }

  Future<void> criar(Map<String, dynamic> data) =>
      _col.add({...data, 'criadoEm': FieldValue.serverTimestamp()});

  Future<void> atualizar(String id, Map<String, dynamic> data) =>
      _col.doc(id).update(data);

  Future<void> deletar(String id) => _col.doc(id).delete();

  Future<void> atualizarStatus(String id, StatusAgendamento status) =>
      _col.doc(id).update({'status': status.value});
}

final agendamentoRepositoryProvider = Provider<AgendamentoRepository>(
    (ref) => AgendamentoRepository(FirebaseFirestore.instance));

final agendaDiaProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final agendamentosDiaProvider =
    StreamProvider.family<List<Agendamento>, DateTime>((ref, dia) =>
        ref.watch(agendamentoRepositoryProvider).watchByDia(dia));

final agendamentosSemanaProvider =
    StreamProvider.family<List<Agendamento>, DateTime>((ref, semana) =>
        ref.watch(agendamentoRepositoryProvider).watchBySemana(semana));
