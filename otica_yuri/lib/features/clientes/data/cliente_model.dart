import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  final String id;
  final String nome;
  final String cpf;
  final String? rg;
  final String telefone;
  final String? whatsapp;
  final DateTime? dataNascimento;
  final String? endereco;
  final String? fotoUrl;
  final DateTime criadoEm;

  const Cliente({
    required this.id,
    required this.nome,
    required this.cpf,
    this.rg,
    required this.telefone,
    this.whatsapp,
    this.dataNascimento,
    this.endereco,
    this.fotoUrl,
    required this.criadoEm,
  });

  factory Cliente.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Cliente(
      id: doc.id,
      nome: data['nome'] as String,
      cpf: data['cpf'] as String,
      rg: data['rg'] as String?,
      telefone: data['telefone'] as String,
      whatsapp: data['whatsapp'] as String?,
      dataNascimento: (data['dataNascimento'] as Timestamp?)?.toDate(),
      endereco: data['endereco'] as String?,
      fotoUrl: data['fotoUrl'] as String?,
      criadoEm:
          (data['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'cpf': cpf,
        if (rg != null) 'rg': rg,
        'telefone': telefone,
        if (whatsapp != null) 'whatsapp': whatsapp,
        if (dataNascimento != null)
          'dataNascimento': Timestamp.fromDate(dataNascimento!),
        if (endereco != null) 'endereco': endereco,
        if (fotoUrl != null) 'fotoUrl': fotoUrl,
        'criadoEm': Timestamp.fromDate(criadoEm),
      };

  Cliente copyWith({
    String? nome,
    String? cpf,
    String? rg,
    String? telefone,
    String? whatsapp,
    DateTime? dataNascimento,
    String? endereco,
    String? fotoUrl,
  }) =>
      Cliente(
        id: id,
        nome: nome ?? this.nome,
        cpf: cpf ?? this.cpf,
        rg: rg ?? this.rg,
        telefone: telefone ?? this.telefone,
        whatsapp: whatsapp ?? this.whatsapp,
        dataNascimento: dataNascimento ?? this.dataNascimento,
        endereco: endereco ?? this.endereco,
        fotoUrl: fotoUrl ?? this.fotoUrl,
        criadoEm: criadoEm,
      );
}
