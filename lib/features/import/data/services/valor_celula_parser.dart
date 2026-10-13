/// Converte o texto bruto de uma célula para `DateTime`/`double`, conforme
/// as convenções do `PerfilBanco` (formato de data, separador decimal) —
/// cada banco usa uma convenção diferente, nunca assumida globalmente.
class ValorCelulaParser {
  DateTime parsearData(String texto, {required String formato}) {
    final partes = texto.trim().split(RegExp(r'[/-]'));
    if (partes.length != 3) {
      throw FormatException('Data "$texto" não corresponde ao formato $formato.');
    }
    final numeros = partes.map(int.parse).toList();

    switch (formato) {
      case 'dd/MM/yyyy':
        return DateTime(numeros[2], numeros[1], numeros[0]);
      case 'yyyy-MM-dd':
        return DateTime(numeros[0], numeros[1], numeros[2]);
      case 'MM/dd/yyyy':
        return DateTime(numeros[2], numeros[0], numeros[1]);
      default:
        throw FormatException('Formato de data não suportado: $formato.');
    }
  }

  double parsearValor(String texto, {required bool separadorDecimalVirgula}) {
    var normalizado = texto.trim().replaceAll(RegExp(r'[R$\s]'), '');
    if (separadorDecimalVirgula) {
      normalizado = normalizado.replaceAll('.', '').replaceAll(',', '.');
    } else {
      normalizado = normalizado.replaceAll(',', '');
    }
    return double.parse(normalizado);
  }
}
