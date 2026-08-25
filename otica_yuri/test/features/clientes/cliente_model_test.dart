import 'package:flutter_test/flutter_test.dart';
import 'package:otica_yuri/features/clientes/data/cliente_model.dart';

void main() {
  final base = Cliente(
    id: '1',
    nome: 'Maria Silva',
    cpf: '12345678901',
    telefone: '11999999999',
    criadoEm: DateTime(2024, 1, 1),
  );

  test('copyWith preserva campos não alterados', () {
    final atualizado = base.copyWith(nome: 'Maria Santos');
    expect(atualizado.nome, 'Maria Santos');
    expect(atualizado.cpf, '12345678901');
    expect(atualizado.id, '1');
    expect(atualizado.telefone, '11999999999');
  });

  test('copyWith pode atualizar múltiplos campos', () {
    final atualizado = base.copyWith(
      cpf: '98765432100',
      telefone: '11888888888',
      rg: '12.345.678-9',
    );
    expect(atualizado.cpf, '98765432100');
    expect(atualizado.telefone, '11888888888');
    expect(atualizado.rg, '12.345.678-9');
    expect(atualizado.nome, 'Maria Silva');
  });

  test('toMap não inclui campos opcionais nulos', () {
    final map = base.toMap();
    expect(map.containsKey('rg'), isFalse);
    expect(map.containsKey('whatsapp'), isFalse);
    expect(map.containsKey('fotoUrl'), isFalse);
    expect(map['nome'], 'Maria Silva');
    expect(map['cpf'], '12345678901');
  });

  test('toMap inclui campos opcionais quando preenchidos', () {
    final c = base.copyWith(rg: '1234567', whatsapp: '11999999999');
    final map = c.toMap();
    expect(map['rg'], '1234567');
    expect(map['whatsapp'], '11999999999');
  });

  test('criadoEm é preservado pelo copyWith', () {
    final atualizado = base.copyWith(nome: 'Outro Nome');
    expect(atualizado.criadoEm, base.criadoEm);
  });
}
