import 'package:cloud_firestore/cloud_firestore.dart';

enum StatusPedido {
  orcamento('Orçamento', 'orcamento'),
  confirmado('Confirmado', 'confirmado'),
  emLaboratorio('Em Laboratório', 'em_laboratorio'),
  pronto('Pronto para retirada', 'pronto'),
  entregue('Entregue', 'entregue'),
  cancelado('Cancelado', 'cancelado');

  final String label, value;
  const StatusPedido(this.label, this.value);

  static StatusPedido fromString(String v) => StatusPedido.values.firstWhere(
      (e) => e.value == v,
      orElse: () => StatusPedido.orcamento);

  bool get isFinalizado =>
      this == StatusPedido.entregue || this == StatusPedido.cancelado;

  StatusPedido? get proximo => switch (this) {
        StatusPedido.orcamento => StatusPedido.confirmado,
        StatusPedido.confirmado => StatusPedido.emLaboratorio,
        StatusPedido.emLaboratorio => StatusPedido.pronto,
        StatusPedido.pronto => StatusPedido.entregue,
        StatusPedido.entregue => null,
        StatusPedido.cancelado => null,
      };
}

class Pedido {
  final String id;
  final String clienteId;
  final String clienteNome;
  final String? receitaId;
  final StatusPedido status;
  final String? armacaoDescricao;
  final String? lenteDescricao;
  final String? numeroPedidoLab;
  final double valorTotal;
  final double valorEntrada;
  final DateTime? dataPrevista;
  final DateTime? dataEntrega;
  final String? observacoes;
  final DateTime criadoEm;

  const Pedido({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    this.receitaId,
    required this.status,
    this.armacaoDescricao,
    this.lenteDescricao,
    this.numeroPedidoLab,
    required this.valorTotal,
    this.valorEntrada = 0.0,
    this.dataPrevista,
    this.dataEntrega,
    this.observacoes,
    required this.criadoEm,
  });

  double get valorRestante => valorTotal - valorEntrada;

  factory Pedido.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Pedido(
      id: doc.id,
      clienteId: d['clienteId'] as String? ?? '',
      clienteNome: d['clienteNome'] as String? ?? '',
      receitaId: d['receitaId'] as String?,
      status: StatusPedido.fromString(d['status'] as String? ?? 'orcamento'),
      armacaoDescricao: d['armacaoDescricao'] as String?,
      lenteDescricao: d['lenteDescricao'] as String?,
      numeroPedidoLab: d['numeroPedidoLab'] as String?,
      valorTotal: (d['valorTotal'] as num?)?.toDouble() ?? 0.0,
      valorEntrada: (d['valorEntrada'] as num?)?.toDouble() ?? 0.0,
      dataPrevista: (d['dataPrevista'] as Timestamp?)?.toDate(),
      dataEntrega: (d['dataEntrega'] as Timestamp?)?.toDate(),
      observacoes: d['observacoes'] as String?,
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'clienteId': clienteId,
        'clienteNome': clienteNome,
        if (receitaId != null) 'receitaId': receitaId,
        'status': status.value,
        if (armacaoDescricao != null) 'armacaoDescricao': armacaoDescricao,
        if (lenteDescricao != null) 'lenteDescricao': lenteDescricao,
        if (numeroPedidoLab != null) 'numeroPedidoLab': numeroPedidoLab,
        'valorTotal': valorTotal,
        'valorEntrada': valorEntrada,
        if (dataPrevista != null)
          'dataPrevista': Timestamp.fromDate(dataPrevista!),
        if (dataEntrega != null)
          'dataEntrega': Timestamp.fromDate(dataEntrega!),
        if (observacoes != null) 'observacoes': observacoes,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };
}
