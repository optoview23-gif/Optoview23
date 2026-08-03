import 'package:flutter_test/flutter_test.dart';
import 'package:otica_yuri/features/prontuario/data/receita_model.dart';

void main() {
  group('GrauOlho', () {
    test('isEmpty é true quando todos campos são nulos', () {
      const g = GrauOlho();
      expect(g.isEmpty, isTrue);
    });

    test('isEmpty é false quando pelo menos um campo tem valor', () {
      const g = GrauOlho(esf: -1.50);
      expect(g.isEmpty, isFalse);
    });

    test('toMap não inclui campos nulos', () {
      const g = GrauOlho(esf: -1.50, cil: -0.50, eixo: 90);
      final m = g.toMap();
      expect(m['esf'], -1.50);
      expect(m['cil'], -0.50);
      expect(m['eixo'], 90);
      expect(m.containsKey('add'), isFalse);
      expect(m.containsKey('dnp'), isFalse);
    });

    test('fromMap converte corretamente', () {
      final m = {'esf': -2.25, 'cil': -0.75, 'eixo': 45};
      final g = GrauOlho.fromMap(m);
      expect(g.esf, -2.25);
      expect(g.cil, -0.75);
      expect(g.eixo, 45);
      expect(g.add, isNull);
    });

    test('fromMap com null retorna GrauOlho vazio', () {
      final g = GrauOlho.fromMap(null);
      expect(g.isEmpty, isTrue);
    });

    test('resumo formata corretamente', () {
      const g = GrauOlho(esf: -1.50, cil: -0.50, eixo: 90);
      expect(g.resumo, '-1.50/-0.50/90°');
    });

    test('resumo retorna — quando vazio', () {
      const g = GrauOlho();
      expect(g.resumo, '—');
    });
  });

  group('Receita', () {
    test('toMap inclui clienteId e dados obrigatórios', () {
      final r = Receita(
        id: 'r1',
        clienteId: 'c1',
        data: DateTime(2024, 6, 15),
        optometrista: 'Dr. Paulo',
        od: const GrauOlho(esf: -1.50),
        oe: const GrauOlho(esf: -1.75),
        criadoEm: DateTime(2024, 6, 15),
      );
      final m = r.toMap();
      expect(m['clienteId'], 'c1');
      expect(m['optometrista'], 'Dr. Paulo');
      expect(m.containsKey('observacoes'), isFalse);
    });
  });
}
