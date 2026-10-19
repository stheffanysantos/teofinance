import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/import/domain/entities/transacao_importada.dart';
import 'package:teofinance/features/import/domain/services/marcar_duplicatas.dart';

TransacaoImportada _t(String descricao, double valor, {DateTime? data}) =>
    TransacaoImportada(data: data ?? DateTime(2026, 10, 5), descricao: descricao, valor: valor);

String _chave(TransacaoImportada t) => chaveLancamento(t.data, t.valor, t.descricao);

void main() {
  group('chaveLancamento', () {
    test('ignora caixa, espaços nas pontas e espaços repetidos', () {
      expect(
        chaveLancamento(DateTime(2026, 10, 5), -52.3, '  Supermercado   CENTRAL '),
        chaveLancamento(DateTime(2026, 10, 5), -52.3, 'supermercado central'),
      );
    });

    test('ignora a hora do dia', () {
      expect(
        chaveLancamento(DateTime(2026, 10, 5, 23, 59), -10, 'x'),
        chaveLancamento(DateTime(2026, 10, 5), -10, 'x'),
      );
    });

    test('ruído de ponto flutuante não muda os centavos', () {
      expect(chaveLancamento(DateTime(2026, 10, 5), 0.1 + 0.2, 'x'), chaveLancamento(DateTime(2026, 10, 5), 0.3, 'x'));
    });

    test('sinal, dia, valor e descrição diferentes geram chaves diferentes', () {
      final base = chaveLancamento(DateTime(2026, 10, 5), -52.30, 'mercado');

      expect(chaveLancamento(DateTime(2026, 10, 5), 52.30, 'mercado'), isNot(base));
      expect(chaveLancamento(DateTime(2026, 10, 6), -52.30, 'mercado'), isNot(base));
      expect(chaveLancamento(DateTime(2026, 10, 5), -52.31, 'mercado'), isNot(base));
      expect(chaveLancamento(DateTime(2026, 10, 5), -52.30, 'padaria'), isNot(base));
    });
  });

  group('indicesDuplicados', () {
    test('sem nada existente, nenhuma linha é duplicata', () {
      expect(indicesDuplicados(importadas: [_t('a', -1), _t('b', -2)], chavesExistentes: const []), isEmpty);
    });

    test('marca só as linhas que já existem', () {
      final importadas = [_t('a', -1), _t('b', -2), _t('c', -3)];

      final dups = indicesDuplicados(importadas: importadas, chavesExistentes: [_chave(importadas[1])]);

      expect(dups, {1});
    });

    test('importar o mesmo arquivo de novo marca tudo', () {
      final importadas = [_t('a', -1), _t('b', -2)];

      final dups = indicesDuplicados(importadas: importadas, chavesExistentes: importadas.map(_chave));

      expect(dups, {0, 1});
    });

    test('compras repetidas legítimas: 1 existente e 2 no arquivo, só uma é duplicata', () {
      final importadas = [_t('Café', -8), _t('Café', -8)];

      final dups = indicesDuplicados(importadas: importadas, chavesExistentes: [_chave(importadas.first)]);

      expect(dups, hasLength(1));
    });

    test('2 existentes e 2 no arquivo: ambas são duplicatas', () {
      final importadas = [_t('Café', -8), _t('Café', -8)];

      final dups = indicesDuplicados(
        importadas: importadas,
        chavesExistentes: [_chave(importadas.first), _chave(importadas.first)],
      );

      expect(dups, {0, 1});
    });

    test('mesmo valor e data com descrição diferente não é duplicata', () {
      final dups = indicesDuplicados(
        importadas: [_t('Padaria', -8)],
        chavesExistentes: [_chave(_t('Mercado', -8))],
      );

      expect(dups, isEmpty);
    });

    test('mesma descrição e valor em outro dia não é duplicata', () {
      final dups = indicesDuplicados(
        importadas: [_t('Aluguel', -1500, data: DateTime(2026, 11, 5))],
        chavesExistentes: [_chave(_t('Aluguel', -1500))],
      );

      expect(dups, isEmpty);
    });
  });
}
