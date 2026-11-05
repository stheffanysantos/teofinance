import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/transactions/presentation/providers/transactions_view_providers.dart';

void main() {
  test('busca ignora maiúsculas e acentos e olha descrição e categoria', () {
    expect(correspondeABusca('cafe', 'Café da manhã', 'Alimentação'), isTrue);
    expect(correspondeABusca('ALIMENTACAO', 'Padaria', 'Alimentação'), isTrue);
    expect(correspondeABusca('uber', 'Mercado', 'Mercado'), isFalse);
    expect(correspondeABusca('  ', 'qualquer', ''), isTrue);
  });
}
