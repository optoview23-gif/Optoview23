import 'package:flutter_test/flutter_test.dart';
import 'package:otica_yuri/features/pedidos/data/pedido_model.dart';

void main() {
  group('StatusPedido', () {
    test('fromString retorna status correto', () {
      expect(StatusPedido.fromString('orcamento'), StatusPedido.orcamento);
      expect(StatusPedido.fromString('confirmado'), StatusPedido.confirmado);
      expect(StatusPedido.fromString('em_laboratorio'),
          StatusPedido.emLaboratorio);
      expect(StatusPedido.fromString('pronto'), StatusPedido.pronto);
      expect(StatusPedido.fromString('entregue'), StatusPedido.entregue);
      expect(StatusPedido.fromString('cancelado'), StatusPedido.cancelado);
    });

    test('fromString com valor desconhecido retorna orcamento', () {
      expect(StatusPedido.fromString('xxx'), StatusPedido.orcamento);
    });

    test('isFinalizado é true para entregue e cancelado', () {
      expect(StatusPedido.entregue.isFinalizado, isTrue);
      expect(StatusPedido.cancelado.isFinalizado, isTrue);
      expect(StatusPedido.orcamento.isFinalizado, isFalse);
      expect(StatusPedido.confirmado.isFinalizado, isFalse);
    });

    test('proximo segue fluxo correto', () {
      expect(StatusPedido.orcamento.proximo, StatusPedido.confirmado);
      expect(StatusPedido.confirmado.proximo, StatusPedido.emLaboratorio);
      expect(StatusPedido.emLaboratorio.proximo, StatusPedido.pronto);
      expect(StatusPedido.pronto.proximo, StatusPedido.entregue);
      expect(StatusPedido.entregue.proximo, isNull);
      expect(StatusPedido.cancelado.proximo, isNull);
    });
  });

  group('Pedido', () {
    test('valorRestante é calculado corretamente', () {
      final p = _makePedido(valorTotal: 500.0, valorEntrada: 200.0);
      expect(p.valorRestante, closeTo(300.0, 0.001));
    });

    test('valorRestante com entrada zero', () {
      final p = _makePedido(valorTotal: 350.0, valorEntrada: 0.0);
      expect(p.valorRestante, closeTo(350.0, 0.001));
    });

    test('toMap inclui campos obrigatórios', () {
      final p = _makePedido();
      final m = p.toMap();
      expect(m['clienteId'], 'c1');
      expect(m['clienteNome'], 'João Silva');
      expect(m['status'], 'orcamento');
      expect(m['valorTotal'], 500.0);
      expect(m['valorEntrada'], 0.0);
    });

    test('toMap não inclui campos nulos', () {
      final p = _makePedido();
      final m = p.toMap();
      expect(m.containsKey('receitaId'), isFalse);
      expect(m.containsKey('armacaoDescricao'), isFalse);
      expect(m.containsKey('lenteDescricao'), isFalse);
      expect(m.containsKey('observacoes'), isFalse);
      expect(m.containsKey('dataPrevista'), isFalse);
    });

    test('toMap inclui campos opcionais quando presentes', () {
      final p = _makePedido(
        armacao: 'Ray-Ban Aviator',
        lente: 'Transitions',
        obs: 'Urgente',
      );
      final m = p.toMap();
      expect(m['armacaoDescricao'], 'Ray-Ban Aviator');
      expect(m['lenteDescricao'], 'Transitions');
      expect(m['observacoes'], 'Urgente');
    });
  });
}

Pedido _makePedido({
  StatusPedido status = StatusPedido.orcamento,
  double valorTotal = 500.0,
  double valorEntrada = 0.0,
  String? armacao,
  String? lente,
  String? obs,
}) =>
    Pedido(
      id: 'p1',
      clienteId: 'c1',
      clienteNome: 'João Silva',
      status: status,
      valorTotal: valorTotal,
      valorEntrada: valorEntrada,
      armacaoDescricao: armacao,
      lenteDescricao: lente,
      observacoes: obs,
      criadoEm: DateTime(2024, 6, 1),
    );
