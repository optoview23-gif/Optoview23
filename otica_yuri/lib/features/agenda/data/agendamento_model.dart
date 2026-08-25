import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoAgendamento {
  consulta('Consulta', 'consulta'),
  entrega('Retirada de pedido', 'entrega'),
  ajuste('Ajuste / Reparo', 'ajuste'),
  outro('Outro', 'outro');

  final String label, value;
  const TipoAgendamento(this.label, this.value);

  static TipoAgendamento fromString(String v) =>
      TipoAgendamento.values.firstWhere((e) => e.value == v,
          orElse: () => TipoAgendamento.consulta);
}

enum StatusAgendamento {
  agendado('Agendado', 'agendado'),
  confirmado('Confirmado', 'confirmado'),
  realizado('Realizado', 'realizado'),
  faltou('Faltou', 'faltou'),
  cancelado('Cancelado', 'cancelado');

  final String label, value;
  const StatusAgendamento(this.label, this.value);

  static StatusAgendamento fromString(String v) =>
      StatusAgendamento.values.firstWhere((e) => e.value == v,
          orElse: () => StatusAgendamento.agendado);

  bool get isFinalizado =>
      this == StatusAgendamento.realizado ||
      this == StatusAgendamento.faltou ||
      this == StatusAgendamento.cancelado;
}

class Agendamento {
  final String id;
  final String clienteId;
  final String clienteNome;
  final String? clienteTelefone;
  final TipoAgendamento tipo;
  final StatusAgendamento status;
  final DateTime inicio;
  final DateTime fim;
  final String? pedidoId;
  final String? observacoes;
  final DateTime criadoEm;

  const Agendamento({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    this.clienteTelefone,
    required this.tipo,
    required this.status,
    required this.inicio,
    required this.fim,
    this.pedidoId,
    this.observacoes,
    required this.criadoEm,
  });

  Duration get duracao => fim.difference(inicio);

  factory Agendamento.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Agendamento(
      id: doc.id,
      clienteId: d['clienteId'] as String? ?? '',
      clienteNome: d['clienteNome'] as String? ?? '',
      clienteTelefone: d['clienteTelefone'] as String?,
      tipo: TipoAgendamento.fromString(d['tipo'] as String? ?? 'consulta'),
      status: StatusAgendamento.fromString(
          d['status'] as String? ?? 'agendado'),
      inicio: (d['inicio'] as Timestamp).toDate(),
      fim: (d['fim'] as Timestamp).toDate(),
      pedidoId: d['pedidoId'] as String?,
      observacoes: d['observacoes'] as String?,
      criadoEm:
          (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'clienteId': clienteId,
        'clienteNome': clienteNome,
        if (clienteTelefone != null) 'clienteTelefone': clienteTelefone,
        'tipo': tipo.value,
        'status': status.value,
        'inicio': Timestamp.fromDate(inicio),
        'fim': Timestamp.fromDate(fim),
        if (pedidoId != null) 'pedidoId': pedidoId,
        if (observacoes != null) 'observacoes': observacoes,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };
}
