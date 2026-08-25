import 'package:flutter_test/flutter_test.dart';
import 'package:otica_yuri/features/estoque/data/item_estoque_model.dart';

void main() {
  group('CategoriaEstoque', () {
    test('fromString retorna categoria correta', () {
      expect(CategoriaEstoque.fromString('armacao'), CategoriaEstoque.armacao);
      expect(CategoriaEstoque.fromString('lente'), CategoriaEstoque.lente);
      expect(CategoriaEstoque.fromString('acessorio'),
          CategoriaEstoque.acessorio);
    });

    test('fromString com valor desconhecido retorna acessorio', () {
      expect(CategoriaEstoque.fromString('desconhecido'),
          CategoriaEstoque.acessorio);
    });

    test('label e value estão corretos', () {
      expect(CategoriaEstoque.armacao.label, 'Armação');
      expect(CategoriaEstoque.armacao.value, 'armacao');
      expect(CategoriaEstoque.lente.label, 'Lente');
      expect(CategoriaEstoque.acessorio.label, 'Acessório');
    });
  });

  group('ItemEstoque.nomeExibicao', () {
    test('armação exibe marca e modelo', () {
      final item = _makeItem(
          categoria: CategoriaEstoque.armacao,
          marca: 'Oakley',
          modelo: 'X100');
      expect(item.nomeExibicao, 'Oakley X100');
    });

    test('armação sem campos exibe fallback', () {
      final item =
          _makeItem(categoria: CategoriaEstoque.armacao);
      expect(item.nomeExibicao, '(sem identificação)');
    });

    test('lente exibe tipo e tratamento com separador', () {
      final item = _makeItem(
          categoria: CategoriaEstoque.lente,
          tipo: 'Monofocal',
          tratamento: 'Antirreflexo');
      expect(item.nomeExibicao, 'Monofocal + Antirreflexo');
    });

    test('lente só com tipo', () {
      final item = _makeItem(
          categoria: CategoriaEstoque.lente, tipo: 'Bifocal');
      expect(item.nomeExibicao, 'Bifocal');
    });

    test('acessório exibe nome', () {
      final item = _makeItem(
          categoria: CategoriaEstoque.acessorio, nome: 'Estojo');
      expect(item.nomeExibicao, 'Estojo');
    });

    test('acessório sem nome exibe fallback', () {
      final item =
          _makeItem(categoria: CategoriaEstoque.acessorio);
      expect(item.nomeExibicao, '(sem nome)');
    });
  });

  group('ItemEstoque.estoque', () {
    test('semEstoque é true quando quantidade é 0', () {
      final item = _makeItem(quantidade: 0);
      expect(item.semEstoque, isTrue);
      expect(item.estoqueBaixo, isFalse);
    });

    test('estoqueBaixo é true quando quantidade <= quantidadeMinima e > 0',
        () {
      final item = _makeItem(quantidade: 3, quantidadeMinima: 5);
      expect(item.estoqueBaixo, isTrue);
      expect(item.semEstoque, isFalse);
    });

    test('estoque normal quando quantidade > quantidadeMinima', () {
      final item = _makeItem(quantidade: 10, quantidadeMinima: 5);
      expect(item.estoqueBaixo, isFalse);
      expect(item.semEstoque, isFalse);
    });

    test('estoqueBaixo é false quando quantidade == 0', () {
      final item = _makeItem(quantidade: 0, quantidadeMinima: 5);
      expect(item.estoqueBaixo, isFalse);
    });
  });

  group('ItemEstoque.toMap', () {
    test('toMap inclui apenas campos não nulos', () {
      final item = _makeItem(
        categoria: CategoriaEstoque.armacao,
        marca: 'Ray-Ban',
        modelo: 'Aviator',
      );
      final m = item.toMap();
      expect(m['categoria'], 'armacao');
      expect(m['marca'], 'Ray-Ban');
      expect(m['modelo'], 'Aviator');
      expect(m.containsKey('cor'), isFalse);
      expect(m.containsKey('codigo'), isFalse);
      expect(m.containsKey('tipo'), isFalse);
      expect(m.containsKey('precoCusto'), isFalse);
    });
  });
}

ItemEstoque _makeItem({
  CategoriaEstoque categoria = CategoriaEstoque.acessorio,
  String? marca,
  String? modelo,
  String? cor,
  String? codigo,
  String? tipo,
  String? tratamento,
  String? nome,
  int quantidade = 10,
  int quantidadeMinima = 5,
  double? precoCusto,
  double precoVenda = 99.90,
}) =>
    ItemEstoque(
      id: 'test-id',
      categoria: categoria,
      marca: marca,
      modelo: modelo,
      cor: cor,
      codigo: codigo,
      tipo: tipo,
      tratamento: tratamento,
      nome: nome,
      quantidade: quantidade,
      quantidadeMinima: quantidadeMinima,
      precoCusto: precoCusto,
      precoVenda: precoVenda,
      ativo: true,
      criadoEm: DateTime(2024, 1, 1),
    );
