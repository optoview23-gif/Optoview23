import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoTransacao {
  receita('Receita', 'receita'),
  despesa('Despesa', 'despesa');

  final String label, value;
  const TipoTransacao(this.label, this.value);

  static TipoTransacao fromString(String v) =>
      TipoTransacao.values.firstWhere((e) => e.value == v,
          orElse: () => TipoTransacao.receita);
}

enum FormaPagamento {
  dinheiro('Dinheiro', 'dinheiro'),
  pix('PIX', 'pix'),
  cartaoDebito('Cartão Débito', 'cartao_debito'),
  cartaoCredito('Cartão Crédito', 'cartao_credito'),
  transferencia('Transferência', 'transferencia'),
  cheque('Cheque', 'cheque');

  final String label, value;
  const FormaPagamento(this.label, this.value);

  static FormaPagamento fromString(String v) =>
      FormaPagamento.values.firstWhere((e) => e.value == v,
          orElse: () => FormaPagamento.dinheiro);
}

const List<String> categoriasReceita = [
  'Venda de óculos',
  'Entrada de pedido',
  'Saldo restante',
  'Ajuste / reparo',
  'Consulta',
  'Outros',
];

const List<String> categoriasDespesa = [
  'Laboratório',
  'Fornecedor / armações',
  'Aluguel',
  'Salário',
  'Material de escritório',
  'Impostos',
  'Energia / água / internet',
  'Outros',
];

class Transacao {
  final String id;
  final TipoTransacao tipo;
  final double valor;
  final String descricao;
  final FormaPagamento formaPagamento;
  final String? categoria;
  final String? pedidoId;
  final String? clienteNome;
  final DateTime data;
  final DateTime criadoEm;
  final String? observacoes;

  const Transacao({
    required this.id,
    required this.tipo,
    required this.valor,
    required this.descricao,
    required this.formaPagamento,
    this.categoria,
    this.pedidoId,
    this.clienteNome,
    required this.data,
    required this.criadoEm,
    this.observacoes,
  });

  bool get isReceita => tipo == TipoTransacao.receita;

  factory Transacao.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Transacao(
      id: doc.id,
      tipo: TipoTransacao.fromString(d['tipo'] as String? ?? 'receita'),
      valor: (d['valor'] as num?)?.toDouble() ?? 0.0,
      descricao: d['descricao'] as String? ?? '',
      formaPagamento: FormaPagamento.fromString(
          d['formaPagamento'] as String? ?? 'dinheiro'),
      categoria: d['categoria'] as String?,
      pedidoId: d['pedidoId'] as String?,
      clienteNome: d['clienteNome'] as String?,
      data: (d['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
      criadoEm:
          (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      observacoes: d['observacoes'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'tipo': tipo.value,
        'valor': valor,
        'descricao': descricao,
        'formaPagamento': formaPagamento.value,
        if (categoria != null) 'categoria': categoria,
        if (pedidoId != null) 'pedidoId': pedidoId,
        if (clienteNome != null) 'clienteNome': clienteNome,
        'data': Timestamp.fromDate(data),
        'criadoEm': Timestamp.fromDate(criadoEm),
        if (observacoes != null) 'observacoes': observacoes,
      };
}

class CaixaSummary {
  final double totalReceitas;
  final double totalDespesas;

  const CaixaSummary(
      {required this.totalReceitas, required this.totalDespesas});

  double get saldo => totalReceitas - totalDespesas;

  factory CaixaSummary.fromList(List<Transacao> list) {
    double receitas = 0, despesas = 0;
    for (final t in list) {
      if (t.isReceita) {
        receitas += t.valor;
      } else {
        despesas += t.valor;
      }
    }
    return CaixaSummary(totalReceitas: receitas, totalDespesas: despesas);
  }
}
