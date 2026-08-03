import 'package:flutter_test/flutter_test.dart';
import 'package:otica_yuri/features/agenda/data/agendamento_model.dart';

void main() {
  group('TipoAgendamento', () {
    test('fromString returns correct enum value', () {
      expect(TipoAgendamento.fromString('consulta'), TipoAgendamento.consulta);
      expect(TipoAgendamento.fromString('entrega'), TipoAgendamento.entrega);
      expect(TipoAgendamento.fromString('ajuste'), TipoAgendamento.ajuste);
      expect(TipoAgendamento.fromString('outro'), TipoAgendamento.outro);
    });

    test('fromString falls back to consulta for unknown value', () {
      expect(TipoAgendamento.fromString('desconhecido'), TipoAgendamento.consulta);
      expect(TipoAgendamento.fromString(''), TipoAgendamento.consulta);
    });

    test('label is non-empty for all values', () {
      for (final t in TipoAgendamento.values) {
        expect(t.label, isNotEmpty);
      }
    });
  });

  group('StatusAgendamento', () {
    test('fromString returns correct enum value', () {
      expect(StatusAgendamento.fromString('agendado'), StatusAgendamento.agendado);
      expect(StatusAgendamento.fromString('confirmado'), StatusAgendamento.confirmado);
      expect(StatusAgendamento.fromString('realizado'), StatusAgendamento.realizado);
      expect(StatusAgendamento.fromString('faltou'), StatusAgendamento.faltou);
      expect(StatusAgendamento.fromString('cancelado'), StatusAgendamento.cancelado);
    });

    test('fromString falls back to agendado for unknown value', () {
      expect(StatusAgendamento.fromString('outro'), StatusAgendamento.agendado);
    });

    test('isFinalizado is true for terminal statuses', () {
      expect(StatusAgendamento.realizado.isFinalizado, isTrue);
      expect(StatusAgendamento.faltou.isFinalizado, isTrue);
      expect(StatusAgendamento.cancelado.isFinalizado, isTrue);
    });

    test('isFinalizado is false for non-terminal statuses', () {
      expect(StatusAgendamento.agendado.isFinalizado, isFalse);
      expect(StatusAgendamento.confirmado.isFinalizado, isFalse);
    });
  });

  group('Agendamento', () {
    final inicio = DateTime(2025, 6, 15, 9, 0);
    final fim = DateTime(2025, 6, 15, 9, 30);

    Agendamento makeAgendamento({
      String? observacoes,
      String? clienteTelefone,
      StatusAgendamento status = StatusAgendamento.agendado,
    }) =>
        Agendamento(
          id: 'ag1',
          clienteId: 'cli1',
          clienteNome: 'Ana Souza',
          clienteTelefone: clienteTelefone,
          tipo: TipoAgendamento.consulta,
          status: status,
          inicio: inicio,
          fim: fim,
          observacoes: observacoes,
          criadoEm: DateTime(2025, 6, 1),
        );

    test('duracao returns difference between fim and inicio', () {
      final a = makeAgendamento();
      expect(a.duracao, const Duration(minutes: 30));
    });

    test('duracao works for multi-hour appointments', () {
      final a = Agendamento(
        id: 'ag2',
        clienteId: 'cli1',
        clienteNome: 'Ana',
        tipo: TipoAgendamento.ajuste,
        status: StatusAgendamento.confirmado,
        inicio: DateTime(2025, 6, 15, 9, 0),
        fim: DateTime(2025, 6, 15, 11, 15),
        criadoEm: DateTime(2025, 6, 1),
      );
      expect(a.duracao, const Duration(hours: 2, minutes: 15));
    });

    test('toMap includes required fields', () {
      final a = makeAgendamento();
      final map = a.toMap();
      expect(map['clienteId'], 'cli1');
      expect(map['clienteNome'], 'Ana Souza');
      expect(map['tipo'], 'consulta');
      expect(map['status'], 'agendado');
      expect(map.containsKey('inicio'), isTrue);
      expect(map.containsKey('fim'), isTrue);
    });

    test('toMap omits null optional fields', () {
      final a = makeAgendamento();
      final map = a.toMap();
      expect(map.containsKey('clienteTelefone'), isFalse);
      expect(map.containsKey('observacoes'), isFalse);
      expect(map.containsKey('pedidoId'), isFalse);
    });

    test('toMap includes optional fields when present', () {
      final a = makeAgendamento(
          clienteTelefone: '11999990000', observacoes: 'Nota importante');
      final map = a.toMap();
      expect(map['clienteTelefone'], '11999990000');
      expect(map['observacoes'], 'Nota importante');
    });
  });
}
