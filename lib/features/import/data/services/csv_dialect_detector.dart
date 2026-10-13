import 'dart:convert';
import 'dart:typed_data';

/// Detecta separador e encoding de um CSV sem pedir confirmação do usuário
/// a não ser que a confiança seja baixa (ver `.claude/docs/IMPORT_FLOW.md`).
///
/// Única classe da feature que decide "como decodificar os bytes brutos" —
/// nunca inline dentro do usecase ou do repository (ver
/// `.claude/rules/architecture.md`).
class CsvDialectDetector {
  static const _delimitadoresCandidatos = [',', ';', '\t', '|'];

  /// `true` = Latin-1/ISO-8859-1, `false` = UTF-8.
  bool detectarCodificacaoLatin1(Uint8List bytes) {
    try {
      utf8.decode(bytes, allowMalformed: false);
      return false;
    } on FormatException {
      return true;
    }
  }

  String decodificar(Uint8List bytes, {required bool latin1Encoding}) {
    return latin1Encoding ? latin1.decode(bytes) : utf8.decode(bytes, allowMalformed: true);
  }

  /// Conta ocorrências de cada delimitador candidato na primeira linha não
  /// vazia e escolhe o mais frequente — abordagem simples e robusta o
  /// bastante para os exports de extrato mais comuns.
  String detectarDelimitador(String conteudo) {
    final primeiraLinha = conteudo
        .split(RegExp(r'\r?\n'))
        .firstWhere((linha) => linha.trim().isNotEmpty, orElse: () => '');

    var melhor = ',';
    var melhorContagem = -1;
    for (final candidato in _delimitadoresCandidatos) {
      final contagem = candidato.allMatches(primeiraLinha).length;
      if (contagem > melhorContagem) {
        melhorContagem = contagem;
        melhor = candidato;
      }
    }
    return melhor;
  }

  /// Heurística simples: se a primeira linha não tiver nenhum dígito que
  /// pareça início de valor monetário/data, provavelmente é cabeçalho.
  bool detectarTemCabecalho(List<List<String>> linhas) {
    if (linhas.isEmpty) return false;
    final primeira = linhas.first;
    final pareceNumerica = primeira.any((celula) => RegExp(r'^-?\d').hasMatch(celula.trim()));
    return !pareceNumerica;
  }
}
