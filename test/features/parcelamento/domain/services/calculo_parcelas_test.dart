import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/parcelamento/domain/services/calculo_parcelas.dart';

void main() {
  group('dataDaParcela', () {
    test('primeira parcela é a própria data', () {
      expect(dataDaParcela(DateTime(2026, 10, 15), 0), DateTime(2026, 10, 15));
    });

    test('mantém o mesmo dia nos meses seguintes', () {
      expect(dataDaParcela(DateTime(2026, 10, 15), 1), DateTime(2026, 11, 15));
      expect(dataDaParcela(DateTime(2026, 10, 15), 2), DateTime(2026, 12, 15));
    });

    test('vira o ano', () {
      expect(dataDaParcela(DateTime(2026, 11, 5), 2), DateTime(2027, 1, 5));
      expect(dataDaParcela(DateTime(2026, 11, 5), 14), DateTime(2028, 1, 5));
    });

    test('dia 31 cai no último dia de meses mais curtos e volta a 31 depois', () {
      final primeira = DateTime(2026, 1, 31);
      expect(dataDaParcela(primeira, 1), DateTime(2026, 2, 28));
      expect(dataDaParcela(primeira, 2), DateTime(2026, 3, 31));
      expect(dataDaParcela(primeira, 3), DateTime(2026, 4, 30));
    });

    test('fevereiro de ano bissexto tem 29 dias', () {
      expect(dataDaParcela(DateTime(2028, 1, 30), 1), DateTime(2028, 2, 29));
    });

    test('preserva a hora da primeira parcela', () {
      expect(
        dataDaParcela(DateTime(2026, 10, 15, 14, 30), 1),
        DateTime(2026, 11, 15, 14, 30),
      );
    });
  });

  group('valoresDasParcelas', () {
    test('divisão exata repete o mesmo valor', () {
      expect(valoresDasParcelas(300, 3), [100, 100, 100]);
    });

    test('resto em centavos vai para a última parcela', () {
      expect(valoresDasParcelas(100, 3), [33.33, 33.33, 33.34]);
    });

    test('mantém o sinal negativo das despesas', () {
      expect(valoresDasParcelas(-100, 3), [-33.33, -33.33, -33.34]);
    });

    test('a soma é sempre exatamente o total, em qualquer número de parcelas', () {
      for (final total in [99.99, 1234.56, 0.1, 3000.0, 1.0]) {
        for (var n = 2; n <= 12; n++) {
          final soma = valoresDasParcelas(total, n).fold<double>(0, (a, v) => a + v);
          expect((soma * 100).round(), (total * 100).round(), reason: '$total em ${n}x');
        }
      }
    });
  });
}
