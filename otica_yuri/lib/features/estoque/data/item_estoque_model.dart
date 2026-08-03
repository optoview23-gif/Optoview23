import 'package:cloud_firestore/cloud_firestore.dart';

enum CategoriaEstoque {
  armacao('Armação', 'armacao'),
  lente('Lente', 'lente'),
  acessorio('Acessório', 'acessorio');

  final String label;
  final String value;
  const CategoriaEstoque(this.label, this.value);

  static CategoriaEstoque fromString(String v) =>
      CategoriaEstoque.values.firstWhere(
          (e) => e.value == v,
          orElse: () => CategoriaEstoque.acessorio);
}

class ItemEstoque {
  final String id;
  final CategoriaEstoque categoria;
  // Armação
  final String? marca;
  final String? modelo;
  final String? cor;
  final String? codigo;
  // Lente
  final String? tipo;
  final String? tratamento;
  // Acessório / genérico
  final String? nome;
  // Comum
  final int quantidade;
  final int quantidadeMinima;
  final double? precoCusto;
  final double precoVenda;
  final bool ativo;
  final DateTime criadoEm;

  const ItemEstoque({
    required this.id,
    required this.categoria,
    this.marca,
    this.modelo,
    this.cor,
    this.codigo,
    this.tipo,
    this.tratamento,
    this.nome,
    required this.quantidade,
    required this.quantidadeMinima,
    this.precoCusto,
    required this.precoVenda,
    required this.ativo,
    required this.criadoEm,
  });

  String get nomeExibicao {
    switch (categoria) {
      case CategoriaEstoque.armacao:
        final parts = [marca, modelo]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList();
        return parts.isEmpty ? '(sem identificação)' : parts.join(' ');
      case CategoriaEstoque.lente:
        final parts = [tipo, tratamento]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList();
        return parts.isEmpty ? '(sem identificação)' : parts.join(' + ');
      case CategoriaEstoque.acessorio:
        return (nome?.isNotEmpty == true) ? nome! : '(sem nome)';
    }
  }

  bool get estoqueBaixo =>
      quantidade > 0 && quantidade <= quantidadeMinima;
  bool get semEstoque => quantidade == 0;

  factory ItemEstoque.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ItemEstoque(
      id: doc.id,
      categoria: CategoriaEstoque.fromString(
          d['categoria'] as String? ?? 'acessorio'),
      marca: d['marca'] as String?,
      modelo: d['modelo'] as String?,
      cor: d['cor'] as String?,
      codigo: d['codigo'] as String?,
      tipo: d['tipo'] as String?,
      tratamento: d['tratamento'] as String?,
      nome: d['nome'] as String?,
      quantidade: (d['quantidade'] as num?)?.toInt() ?? 0,
      quantidadeMinima:
          (d['quantidadeMinima'] as num?)?.toInt() ?? 0,
      precoCusto: (d['precoCusto'] as num?)?.toDouble(),
      precoVenda: (d['precoVenda'] as num?)?.toDouble() ?? 0.0,
      ativo: d['ativo'] as bool? ?? true,
      criadoEm:
          (d['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'categoria': categoria.value,
        if (marca != null) 'marca': marca,
        if (modelo != null) 'modelo': modelo,
        if (cor != null) 'cor': cor,
        if (codigo != null) 'codigo': codigo,
        if (tipo != null) 'tipo': tipo,
        if (tratamento != null) 'tratamento': tratamento,
        if (nome != null) 'nome': nome,
        'quantidade': quantidade,
        'quantidadeMinima': quantidadeMinima,
        if (precoCusto != null) 'precoCusto': precoCusto,
        'precoVenda': precoVenda,
        'ativo': ativo,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };
}
