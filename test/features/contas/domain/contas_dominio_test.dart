import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/services/proxima_ocorrencia.dart';
import 'package:teofinance/features/contas/domain/services/resumo_contas.dart';
import 'package:teofinance/features/contas/domain/services/validar_conta.dart';

ContaAPagar _conta(
  DateTime vencimento, {
  double valor = 100,
  bool paga = false,
  int diasAntes = 1,
  RecorrenciaConta recorrencia = RecorrenciaConta.nenhuma,
  int? diaBase,
}) =>
    ContaAPagar(
      id: '${vencimento.toIso8601String()}$valor$paga',
      descricao: 'x',
      valor: valor,
      vencimento: vencimento,
      diaBase: diaBase ?? vencimento.day,
      paga: paga,
      diasAntesLembrete: diasAntes,
      recorrencia: recorrencia,
    );

final _hoje = DateTime(2026, 10, 19, 15, 30);

void main() {
  group('statusEm', () {
    test('paga vence qualquer outro estado', () {
      expect(_conta(DateTime(2026, 1, 1), paga: true).statusEm(_hoje), StatusConta.paga);
    });

    test('vencimento anterior a hoje está atrasado', () {
      expect(_conta(DateTime(2026, 10, 18)).statusEm(_hoje), StatusConta.atrasada);
    });

    test('vencimento hoje, em qualquer hora, vence hoje', () {
      expect(_conta(DateTime(2026, 10, 19)).statusEm(_hoje), StatusConta.venceHoje);
      expect(_conta(DateTime(2026, 10, 19, 23, 59)).statusEm(DateTime(2026, 10, 19, 0, 1)), StatusConta.venceHoje);
    });

    test('vencimento futuro está a vencer', () {
      expect(_conta(DateTime(2026, 10, 20)).statusEm(_hoje), StatusConta.aVencer);
    });
  });

  group('diasParaVencer e lembrete', () {
    test('conta os dias de calendário, negativos quando atrasada', () {
      expect(_conta(DateTime(2026, 10, 22)).diasParaVencer(_hoje), 3);
      expect(_conta(DateTime(2026, 10, 19)).diasParaVencer(_hoje), 0);
      expect(_conta(DateTime(2026, 10, 17)).diasParaVencer(_hoje), -2);
    });

    test('o dia do lembrete é o vencimento menos os dias de antecedência', () {
      expect(_conta(DateTime(2026, 11, 10), diasAntes: 2).diaDoLembrete, DateTime(2026, 11, 8));
      expect(_conta(DateTime(2026, 11, 10), diasAntes: 0).diaDoLembrete, DateTime(2026, 11, 10));
    });

    test('o lembrete atravessa a virada de mês', () {
      expect(_conta(DateTime(2026, 11, 1), diasAntes: 3).diaDoLembrete, DateTime(2026, 10, 29));
    });
  });

  group('reagendada e copyWith', () {
    test('reagendar muda o vencimento e o dia-base juntos', () {
      final r = _conta(DateTime(2026, 2, 28), diaBase: 31).reagendada(DateTime(2026, 3, 15, 10));

      expect(r.vencimento, DateTime(2026, 3, 15));
      expect(r.diaBase, 15);
    });

    test('editar descrição ou valor preserva o dia-base', () {
      final r = _conta(DateTime(2026, 2, 28), diaBase: 31).copyWith(descricao: 'Novo', valor: 9);

      expect(r.diaBase, 31);
      expect(r.vencimento, DateTime(2026, 2, 28));
    });
  });

  group('proximoVencimento', () {
    DateTime? proximo(DateTime v, int dia, RecorrenciaConta r) =>
        proximoVencimento(vencimento: v, diaBase: dia, recorrencia: r);

    test('conta que não se repete não tem próxima', () {
      expect(proximo(DateTime(2026, 10, 10), 10, RecorrenciaConta.nenhuma), isNull);
    });

    test('mensal vai para o mesmo dia do mês seguinte', () {
      expect(proximo(DateTime(2026, 10, 10), 10, RecorrenciaConta.mensal), DateTime(2026, 11, 10));
    });

    test('mensal atravessa a virada de ano', () {
      expect(proximo(DateTime(2026, 12, 5), 5, RecorrenciaConta.mensal), DateTime(2027, 1, 5));
    });

    test('dia 31 em mês curto cai no último dia e volta ao 31 depois', () {
      final fev = proximo(DateTime(2026, 1, 31), 31, RecorrenciaConta.mensal);
      expect(fev, DateTime(2026, 2, 28));

      final mar = proximo(fev!, 31, RecorrenciaConta.mensal);
      expect(mar, DateTime(2026, 3, 31));
    });

    test('dia 30 também respeita fevereiro e ano bissexto', () {
      expect(proximo(DateTime(2028, 1, 30), 30, RecorrenciaConta.mensal), DateTime(2028, 2, 29));
      expect(proximo(DateTime(2026, 1, 30), 30, RecorrenciaConta.mensal), DateTime(2026, 2, 28));
    });

    test('dia-base maior que o mês do vencimento atual não vira o mês seguinte em silêncio', () {
      // Vencimento 28/fev de uma conta do dia 31: a próxima é 31/mar, não 3/mar nem 6/abr.
      expect(proximo(DateTime(2026, 2, 28), 31, RecorrenciaConta.mensal), DateTime(2026, 3, 31));
    });

    test('anual vai para o mesmo dia do ano seguinte, e 29/fev vira 28/fev', () {
      expect(proximo(DateTime(2026, 11, 20), 20, RecorrenciaConta.anual), DateTime(2027, 11, 20));
      expect(proximo(DateTime(2028, 2, 29), 29, RecorrenciaConta.anual), DateTime(2029, 2, 28));
    });

    test('uma série mensal do dia 31 durante um ano mantém o dia-base', () {
      var venc = DateTime(2026, 1, 31);
      final dias = <int>[];
      for (var i = 0; i < 12; i++) {
        venc = proximo(venc, 31, RecorrenciaConta.mensal)!;
        dias.add(venc.day);
      }

      expect(dias, [28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31]);
    });
  });

  group('resumirContas', () {
    test('sem contas, tudo zerado e nada urgente', () {
      final r = resumirContas(const [], hoje: _hoje);

      expect(r.atrasadas, 0);
      expect(r.temAlgoUrgente, isFalse);
    });

    test('separa atrasadas, a vencer em 7 dias e as do mês', () {
      final r = resumirContas([
        _conta(DateTime(2026, 10, 5), valor: 100), // atrasada, no mês
        _conta(DateTime(2026, 10, 19), valor: 50), // hoje
        _conta(DateTime(2026, 10, 26), valor: 70), // exatamente em 7 dias
        _conta(DateTime(2026, 10, 27), valor: 999), // 8 dias: fora da janela
        _conta(DateTime(2026, 10, 30), valor: 20), // no mês, fora da janela
      ], hoje: _hoje);

      expect(r.atrasadas, 1);
      expect(r.valorAtrasadas, 100);
      expect(r.aVencerEm7Dias, 2);
      expect(r.valorAVencerEm7Dias, 120);
      expect(r.pendentesNoMes, 5);
      expect(r.valorPendenteNoMes, 100 + 50 + 70 + 999 + 20);
      expect(r.temAlgoUrgente, isTrue);
    });

    test('contas pagas não entram em nenhuma soma', () {
      final r = resumirContas([_conta(DateTime(2026, 10, 5), paga: true), _conta(DateTime(2026, 10, 20), paga: true)], hoje: _hoje);

      expect(r.atrasadas, 0);
      expect(r.aVencerEm7Dias, 0);
      expect(r.pendentesNoMes, 0);
    });

    test('conta de outro mês não conta como pendente do mês', () {
      final r = resumirContas([_conta(DateTime(2026, 11, 3), valor: 80)], hoje: _hoje);

      expect(r.pendentesNoMes, 0);
      expect(r.aVencerEm7Dias, 0);
    });

    test('só atrasada já é urgente', () {
      expect(resumirContas([_conta(DateTime(2026, 9, 1))], hoje: _hoje).temAlgoUrgente, isTrue);
    });
  });

  group('validarConta', () {
    Failure? validar({String descricao = 'Aluguel', double valor = 100, int dias = 1}) =>
        validarConta(descricao: descricao, valor: valor, diasAntesLembrete: dias);

    test('dados válidos passam', () {
      expect(validar(), isNull);
      expect(validar(dias: 0), isNull);
      expect(validar(dias: kMaxDiasAntesLembrete), isNull);
    });

    test('nome vazio ou só espaços falha', () {
      expect(validar(descricao: ''), isA<ValidationFailure>());
      expect(validar(descricao: '   '), isA<ValidationFailure>());
    });

    test('valor zero, negativo, NaN ou infinito falha', () {
      expect(validar(valor: 0), isA<ValidationFailure>());
      expect(validar(valor: -5), isA<ValidationFailure>());
      expect(validar(valor: double.nan), isA<ValidationFailure>());
      expect(validar(valor: double.infinity), isA<ValidationFailure>());
    });

    test('antecedência fora de 0 a 30 dias falha', () {
      expect(validar(dias: -1), isA<ValidationFailure>());
      expect(validar(dias: kMaxDiasAntesLembrete + 1), isA<ValidationFailure>());
    });
  });
}
