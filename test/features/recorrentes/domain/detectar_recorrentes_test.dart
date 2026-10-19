import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/recorrentes/domain/entities/gasto_recorrente.dart';
import 'package:teofinance/features/recorrentes/domain/services/detectar_recorrentes.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

int _seq = 0;

Transacao _t(
  String descricao,
  double valor,
  DateTime data, {
  bool parcela = false,
  double? minhaParte,
}) =>
    Transacao(
      id: 't${_seq++}',
      descricao: descricao,
      categoria: 'x',
      valor: valor,
      data: data,
      ehParcela: parcela,
      valorParcela: parcela ? valor : null,
      minhaParte: minhaParte,
    );

/// Uma cobrança por mês, no mesmo dia, terminando em [fim].
List<Transacao> _mensais(String descricao, List<double> valores, {DateTime? fim, int dia = 5}) {
  final ultimo = fim ?? DateTime(2026, 10, dia);
  return [
    for (var i = 0; i < valores.length; i++)
      _t(descricao, -valores[valores.length - 1 - i], DateTime(ultimo.year, ultimo.month - i, dia)),
  ];
}

final _hoje = DateTime(2026, 10, 19);

List<GastoRecorrente> _detectar(List<Transacao> ts) => detectarRecorrentes(ts, agora: _hoje);

void main() {
  group('normalizarDescricao', () {
    test('variações do mesmo comércio viram a mesma chave', () {
      final chaves = {
        normalizarDescricao('NETFLIX.COM 12/10'),
        normalizarDescricao('Netflix 4521'),
        normalizarDescricao('COMPRA NO DEBITO NETFLIX'),
        normalizarDescricao('  netflix  '),
      };

      expect(chaves, {'netflix'});
    });

    test('ignora acentos, números, pontuação e palavras de ruído', () {
      expect(normalizarDescricao('Pagamento Pix - Padaria São João 123'), 'padaria sao joao');
    });

    test('mantém só as três primeiras palavras', () {
      expect(normalizarDescricao('Clube do Livro Premium Anual'), 'clube livro premium');
    });

    test('só ruído ou números não tem identidade', () {
      expect(normalizarDescricao('PIX 12345'), '');
      expect(normalizarDescricao(''), '');
    });
  });

  group('assinatura mensal fixa', () {
    test('detecta, com cadência, valor, última e próxima data', () {
      final r = _detectar(_mensais('NETFLIX.COM', [39.9, 39.9, 39.9, 39.9]));

      expect(r, hasLength(1));
      final g = r.single;
      expect(g.cadencia, CadenciaGasto.mensal);
      expect(g.regularidade, RegularidadeGasto.fixo);
      expect(g.valorTipico, 39.9);
      expect(g.ocorrencias, 4);
      expect(g.ultimaData, DateTime(2026, 10, 5));
      expect(g.proximaData, DateTime(2026, 11, 5));
      expect(g.ativa, isTrue);
      expect(g.houveReajuste, isFalse);
    });

    test('descrições ligeiramente diferentes a cada mês continuam no mesmo grupo', () {
      final ts = [
        _t('NETFLIX.COM 12/07', -39.9, DateTime(2026, 8, 5)),
        _t('Netflix 4521', -39.9, DateTime(2026, 9, 5)),
        _t('COMPRA NO DEBITO NETFLIX', -39.9, DateTime(2026, 10, 5)),
      ];

      expect(_detectar(ts), hasLength(1));
    });

    test('três cobranças bastam; duas não', () {
      expect(_detectar(_mensais('Spotify', [21.9, 21.9, 21.9])), hasLength(1));
      expect(_detectar(_mensais('Spotify', [21.9, 21.9])), isEmpty);
    });

    test('o dia varia um pouco (fim de semana) e ainda é mensal', () {
      final ts = [
        _t('Academia', -99, DateTime(2026, 7, 3)),
        _t('Academia', -99, DateTime(2026, 8, 5)),
        _t('Academia', -99, DateTime(2026, 9, 2)),
        _t('Academia', -99, DateTime(2026, 10, 5)),
      ];

      expect(_detectar(ts).single.cadencia, CadenciaGasto.mensal);
    });

    test('próxima data respeita mês curto: 31/jan vira 28/fev', () {
      final ts = [
        _t('Seguro', -80, DateTime(2026, 11, 30)),
        _t('Seguro', -80, DateTime(2026, 12, 31)),
        _t('Seguro', -80, DateTime(2027, 1, 31)),
      ];

      final g = detectarRecorrentes(ts, agora: DateTime(2027, 2, 10)).single;

      expect(g.proximaData, DateTime(2027, 2, 28));
    });
  });

  group('reajuste', () {
    test('aponta quando o último valor subiu', () {
      final g = _detectar(_mensais('NETFLIX', [39.9, 39.9, 39.9, 44.9])).single;

      expect(g.regularidade, RegularidadeGasto.fixo);
      expect(g.valorTipico, 39.9);
      expect(g.ultimoValor, 44.9);
      expect(g.houveReajuste, isTrue);
      expect(g.variacaoDoUltimo, closeTo(0.1253, 0.001));
    });

    test('aponta quando o valor caiu, com sinal negativo', () {
      final g = _detectar(_mensais('Plano', [100, 100, 100, 80])).single;

      expect(g.variacaoDoUltimo, closeTo(-0.2, 1e-9));
    });

    test('variação dentro de 2% não é reajuste', () {
      final g = _detectar(_mensais('Plano', [100, 100, 100, 101])).single;

      expect(g.houveReajuste, isFalse);
    });
  });

  group('conta de valor variável', () {
    test('luz que oscila vira recorrente variável com a mediana', () {
      final g = _detectar(_mensais('ENERGIA ELETRICA', [180, 210, 150, 240, 190])).single;

      expect(g.regularidade, RegularidadeGasto.variavel);
      expect(g.valorTipico, 190);
      expect(g.houveReajuste, isFalse);
    });

    test('valores dispersos demais (mais de 3x) não são uma conta recorrente', () {
      expect(_detectar(_mensais('Compra grande', [50, 400, 80, 30])), isEmpty);
    });
  });

  group('outras cadências', () {
    test('semanal', () {
      final ts = [
        for (var i = 0; i < 6; i++) _t('Feira livre', -45, DateTime(2026, 9, 7).add(Duration(days: 7 * i))),
      ];

      final g = _detectar(ts).single;

      expect(g.cadencia, CadenciaGasto.semanal);
      expect(g.valorMensalEstimado, closeTo(45 * 52 / 12, 1e-9));
    });

    test('anual com duas cobranças de valor igual', () {
      final ts = [
        _t('Seguro auto', -2400, DateTime(2025, 11, 20)),
        _t('Seguro auto', -2400, DateTime(2026, 11, 20)),
      ];

      final g = detectarRecorrentes(ts, agora: DateTime(2026, 12, 1)).single;

      expect(g.cadencia, CadenciaGasto.anual);
      expect(g.valorMensalEstimado, 200);
      expect(g.proximaData, DateTime(2027, 11, 20));
    });

    test('anual com valores diferentes não conta', () {
      final ts = [
        _t('Viagem', -2400, DateTime(2025, 11, 20)),
        _t('Viagem', -3100, DateTime(2026, 11, 20)),
      ];

      expect(detectarRecorrentes(ts, agora: DateTime(2026, 12, 1)), isEmpty);
    });

    test('mensal vale em valor mensal estimado', () {
      expect(_detectar(_mensais('Netflix', [40, 40, 40])).single.valorMensalEstimado, 40);
    });
  });

  group('o que fica de fora', () {
    test('receitas não são gastos recorrentes', () {
      final ts = [
        for (var i = 0; i < 4; i++) _t('SALARIO', 5000, DateTime(2026, 7 + i, 5)),
      ];

      expect(_detectar(ts), isEmpty);
    });

    test('parcelas de parcelamento não entram', () {
      final ts = [
        for (var i = 0; i < 4; i++) _t('Notebook (${i + 1}/4)', -250, DateTime(2026, 7 + i, 10), parcela: true),
      ];

      expect(_detectar(ts), isEmpty);
    });

    test('compras de supermercado em intervalos irregulares não viram recorrentes', () {
      final ts = [
        _t('SUPERMERCADO CENTRAL', -230, DateTime(2026, 9, 1)),
        _t('SUPERMERCADO CENTRAL', -88, DateTime(2026, 9, 4)),
        _t('SUPERMERCADO CENTRAL', -310, DateTime(2026, 9, 13)),
        _t('SUPERMERCADO CENTRAL', -140, DateTime(2026, 9, 22)),
        _t('SUPERMERCADO CENTRAL', -95, DateTime(2026, 10, 2)),
      ];

      expect(_detectar(ts), isEmpty);
    });

    test('valor sempre igual mas em intervalos irregulares não é recorrente: só o ritmo decide', () {
      final ts = [
        _t('PEDAGIO', -20, DateTime(2026, 9, 1)),
        _t('PEDAGIO', -20, DateTime(2026, 9, 4)),
        _t('PEDAGIO', -20, DateTime(2026, 9, 13)),
        _t('PEDAGIO', -20, DateTime(2026, 10, 2)),
        _t('PEDAGIO', -20, DateTime(2026, 10, 9)),
      ];

      expect(_detectar(ts), isEmpty);
    });

    test('intervalo de 24 dias fica fora do ritmo mensal e de 25 já entra', () {
      List<Transacao> serie(int dias) => [
            _t('CLUBE', -50, DateTime(2026, 6, 1)),
            _t('CLUBE', -50, DateTime(2026, 6, 1).add(Duration(days: dias))),
            _t('CLUBE', -50, DateTime(2026, 6, 1).add(Duration(days: dias * 2))),
          ];

      expect(detectarRecorrentes(serie(24), agora: DateTime(2026, 8, 5)), isEmpty);
      expect(detectarRecorrentes(serie(25), agora: DateTime(2026, 8, 5)), hasLength(1));
    });

    test('intervalo de 36 dias ainda é mensal e de 37 não', () {
      List<Transacao> serie(int dias) => [
            _t('CLUBE', -50, DateTime(2026, 1, 1)),
            _t('CLUBE', -50, DateTime(2026, 1, 1).add(Duration(days: dias))),
            _t('CLUBE', -50, DateTime(2026, 1, 1).add(Duration(days: dias * 2))),
          ];

      expect(detectarRecorrentes(serie(36), agora: DateTime(2026, 4, 1)), hasLength(1));
      expect(detectarRecorrentes(serie(37), agora: DateTime(2026, 4, 1)), isEmpty);
    });

    test('descrição só com ruído é ignorada', () {
      expect(_detectar(_mensais('PIX 1234', [50, 50, 50, 50])), isEmpty);
    });

    test('lista vazia', () {
      expect(_detectar(const []), isEmpty);
    });
  });

  group('compras repetidas no mesmo dia', () {
    test('duas cobranças no mesmo dia somam uma só e não quebram o intervalo', () {
      final ts = [
        _t('Clube', -30, DateTime(2026, 8, 5)),
        _t('Clube', -30, DateTime(2026, 9, 5)),
        _t('Clube', -20, DateTime(2026, 10, 5)),
        _t('Clube', -10, DateTime(2026, 10, 5)),
      ];

      final g = _detectar(ts).single;

      expect(g.ocorrencias, 3);
      expect(g.ultimoValor, 30);
    });
  });

  group('gasto dividido', () {
    test('usa a parte do usuário no valor', () {
      final ts = [
        _t('Assinatura da casa', -100, DateTime(2026, 8, 5), minhaParte: 25),
        _t('Assinatura da casa', -100, DateTime(2026, 9, 5), minhaParte: 25),
        _t('Assinatura da casa', -100, DateTime(2026, 10, 5), minhaParte: 25),
      ];

      expect(_detectar(ts).single.valorTipico, 25);
    });
  });

  group('ativa ou provavelmente cancelada', () {
    test('cobrança recente está ativa', () {
      expect(_detectar(_mensais('Netflix', [40, 40, 40])).single.ativa, isTrue);
    });

    test('sem cobrança há mais de um período e meio fica inativa', () {
      final g = _detectar(_mensais('Netflix', [40, 40, 40], fim: DateTime(2026, 7, 5))).single;

      expect(g.ativa, isFalse);
    });

    test('exatamente no limite de 45 dias ainda está ativa; um dia a mais não', () {
      final base = _mensais('Netflix', [40, 40, 40], fim: DateTime(2026, 9, 1), dia: 1);

      expect(detectarRecorrentes(base, agora: DateTime(2026, 10, 16)).single.ativa, isTrue);
      expect(detectarRecorrentes(base, agora: DateTime(2026, 10, 17)).single.ativa, isFalse);
    });
  });

  group('ordem', () {
    test('ativas antes das inativas, e maior peso mensal primeiro', () {
      final ts = [
        ..._mensais('Academia', [100, 100, 100]),
        ..._mensais('Netflix', [40, 40, 40]),
        ..._mensais('Revista antiga', [200, 200, 200], fim: DateTime(2026, 6, 5)),
      ];

      final r = _detectar(ts);

      expect(r.map((g) => g.chave), ['academia', 'netflix', 'revista antiga']);
      expect(r.map((g) => g.ativa), [true, true, false]);
    });
  });
}
