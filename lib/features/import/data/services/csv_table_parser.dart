import 'package:csv/csv.dart';

/// Converte o conteúdo já decodificado (string) em linhas/colunas —
/// única classe que importa o pacote `csv` nesta feature.
class CsvTableParser {
  List<List<String>> parsear(String conteudo, {required String delimitador}) {
    final csv = Csv(fieldDelimiter: delimitador, autoDetect: false, dynamicTyping: false);
    final linhas = csv.decode(conteudo.replaceAll('\r\n', '\n'));
    return linhas.map((linha) => linha.map((celula) => celula.toString().trim()).toList()).toList();
  }
}
