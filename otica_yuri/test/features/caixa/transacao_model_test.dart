import 'package:flutter_test/flutter_test.dart';
import 'package:otica_yuri/features/caixa/data/transacao_model.dart';

void main() {
  group('TipoTransacao', () {
    test('fromString retorna tipo correto', () {
      expect(TipoTransacao.fromString('receita'), TipoTransacao.receita);
      expect(TipoTransacao.fromString('despesa'), TipoTransacao.despesa);
    });

    test('fromString com valor desconhecido retorna receita', () {
      expect(TipoTransacao.fromString('xxx'), TipoTransacao.receita);
    });
  });

  group('FormaPagamento', () {
    test('fromString retorna forma correta', () {
      expect(FormaPagamento.fromString('pix'), FormaPagamento.pix);
      expect(FormaPagamento.fromString('cartao_credito'),
          FormaPagamento.cartaoCredito);
      expect(FormaPagamento.fromString('cartao_debito'),
          FormaPagamento.cartaoDebito);
    });

    test('fromString com valor desconhecido retorna dinheiro', () {
      expect(FormaPagamento.fromString('xyz'), FormaPagamento.dinheiro);
    });
  });

  group('Transacao', () {
    test('isReceita é true para tipo receita', () {
      final t = _makeTransacao(tipo: TipoTransacao.receita);
      expect(t.isReceita, isTrue);
    });

    test('isReceita é false para tipo despesa', () {
      final t = _makeTransacao(tipo: TipoTransacao.despesa);
      expect(t.isReceita, isFalse);
    });

    test('toMap inclui campos obrigatórios', () {
      final t = _makeTransacao();
      final m = t.toMap();
      expect(m['tipo'], 'receita');
      expect(m['valor'], 150.0);
      expect(m['descricao'], 'Venda óculos');
      expect(m['formaPagamento'], 'pix');
    });

    test('toMap não inclui campos nulos', () {
      final t = _makeTransacao();
      final m = t.toMap();
      expect(m.containsKey('categoria'), isFalse);
      expect(m.containsKey('pedidoId'), isFalse);
      expect(m.containsKey('clienteNome'), isFalse);
      expect(m.containsKey('observacoes'), isFalse);
    });

    test('toMap inclui campos opcionais quando presentes', () {
      final t = _makeTransacao(
          categoria: 'Venda de óculos', obs: 'Pago na hora');
      final m = t.toMap();
      expect(m['categoria'], 'Venda de óculos');
      expect(m['observacoes'], 'Pago na hora');
    });
  });

  group('CaixaSummary', () {
    test('saldo é receitas menos despesas', () {
      const summary = CaixaSummary(totalReceitas: 1000, totalDespesas: 350);
      expect(summary.saldo, closeTo(650, 0.001));
    });

    test('saldo negativo quando despesas > receitas', () {
      const summary = CaixaSummary(totalReceitas: 200, totalDespesas: 500);
      expect(summary.saldo, closeTo(-300, 0.001));
    });

    test('fromList calcula totais corretamente', () {
      final list = [
        _makeTransacao(tipo: TipoTransacao.receita, valor: 500),
        _makeTransacao(tipo: TipoTransacao.receita, valor: 300),
        _makeTransacao(tipo: TipoTransacao.despesa, valor: 200),
      ];
      final s = CaixaSummary.fromList(list);
      expect(s.totalReceitas, closeTo(800, 0.001));
      expect(s.totalDespesas, closeTo(200, 0.001));
      expect(s.saldo, closeTo(600, 0.001));
    });

    test('fromList com lista vazia retorna zeros', () {
      final s = CaixaSummary.fromList([]);
      expect(s.totalReceitas, 0);
      expect(s.totalDespesas, 0);
      expect(s.saldo, 0);
    });
  });
}

Transacao _makeTransacao({
  TipoTransacao tipo = TipoTransacao.receita,
  double valor = 150.0,
  String? categoria,
  String? obs,
}) =>
    Transacao(
      id: 't1',
      tipo: tipo,
      valor: valor,
      descricao: 'Venda óculos',
      formaPagamento: FormaPagamento.pix,
      categoria: categoria,
      observacoes: obs,
      data: DateTime(2024, 6, 1),
      criadoEm: DateTime(2024, 6, 1),
    );
