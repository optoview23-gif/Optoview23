import 'package:cloud_firestore/cloud_firestore.dart';

class GrauOlho {
  final double? esf;
  final double? cil;
  final int? eixo;
  final double? add;
  final double? dnp;

  const GrauOlho({this.esf, this.cil, this.eixo, this.add, this.dnp});

  factory GrauOlho.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const GrauOlho();
    return GrauOlho(
      esf: (map['esf'] as num?)?.toDouble(),
      cil: (map['cil'] as num?)?.toDouble(),
      eixo: (map['eixo'] as num?)?.toInt(),
      add: (map['add'] as num?)?.toDouble(),
      dnp: (map['dnp'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{};
    if (esf != null) m['esf'] = esf;
    if (cil != null) m['cil'] = cil;
    if (eixo != null) m['eixo'] = eixo;
    if (add != null) m['add'] = add;
    if (dnp != null) m['dnp'] = dnp;
    return m;
  }

  bool get isEmpty =>
      esf == null && cil == null && eixo == null && add == null && dnp == null;

  String get resumo {
    if (isEmpty) return '—';
    final parts = <String>[];
    if (esf != null) parts.add(_fmtGrau(esf!));
    if (cil != null) parts.add(_fmtGrau(cil!));
    if (eixo != null) parts.add('$eixo°');
    return parts.join('/');
  }

  static String _fmtGrau(double v) {
    final s = v.toStringAsFixed(2);
    return v > 0 ? '+$s' : s;
  }
}

class Receita {
  final String id;
  final String clienteId;
  final DateTime data;
  final String optometrista;
  final GrauOlho od;
  final GrauOlho oe;
  final String? observacoes;
  final String? fotoUrl;
  final DateTime criadoEm;

  const Receita({
    required this.id,
    required this.clienteId,
    required this.data,
    required this.optometrista,
    required this.od,
    required this.oe,
    this.observacoes,
    this.fotoUrl,
    required this.criadoEm,
  });

  factory Receita.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc, String clienteId) {
    final d = doc.data()!;
    return Receita(
      id: doc.id,
      clienteId: clienteId,
      data: (d['data'] as Timestamp).toDate(),
      optometrista: d['optometrista'] as String? ?? '',
      od: GrauOlho.fromMap(d['od'] as Map<String, dynamic>?),
      oe: GrauOlho.fromMap(d['oe'] as Map<String, dynamic>?),
      observacoes: d['observacoes'] as String?,
      fotoUrl: d['fotoUrl'] as String?,
      criadoEm:
          (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'clienteId': clienteId,
        'data': Timestamp.fromDate(data),
        'optometrista': optometrista,
        'od': od.toMap(),
        'oe': oe.toMap(),
        if (observacoes != null) 'observacoes': observacoes,
        if (fotoUrl != null) 'fotoUrl': fotoUrl,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };
}
