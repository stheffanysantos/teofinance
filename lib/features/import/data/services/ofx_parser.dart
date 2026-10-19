import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/extrato_importado.dart';
import '../../domain/entities/transacao_importada.dart';

/// Lê extratos OFX de conta corrente e de cartão, nas duas variantes que os
/// bancos brasileiros usam: 1.x (SGML, tags sem fechamento) e 2.x (XML).
///
/// Tudo acontece no aparelho. Diferente do CSV, o OFX já diz o que cada campo
/// é, então não há mapeamento de colunas nem Perfil de Banco: qualquer dado
/// fora do esperado interrompe a leitura com um erro que aponta a transação
/// (nunca se pula ou se corrige um valor em silêncio).
class OfxParser {
  const OfxParser();

  /// Reconhece OFX pelo conteúdo (cabeçalho `OFXHEADER` ou a tag `<OFX>`),
  /// não pela extensão — bancos exportam OFX como `.ofx`, `.qfx` ou `.txt`.
  bool ehOfx(Uint8List bytes) {
    final inicio = latin1.decode(bytes.sublist(0, bytes.length < 4096 ? bytes.length : 4096)).toUpperCase();
    return inicio.contains('OFXHEADER') || inicio.contains('<OFX>') || inicio.contains('<?OFX');
  }

  ExtratoImportado parsear(Uint8List bytes) {
    final texto = _decodificar(bytes);

    final blocos = RegExp(
      r'<STMTTRN>([\s\S]*?)(?=</STMTTRN>|<STMTTRN>|</BANKTRANLIST>|</CCSTMTRS>|</STMTRS>|$)',
      caseSensitive: false,
    ).allMatches(texto).map((m) => m.group(1)!).toList();

    if (blocos.isEmpty) {
      throw const FormatException('Nenhuma transação encontrada no arquivo OFX.');
    }

    final transacoes = <TransacaoImportada>[];
    for (var i = 0; i < blocos.length; i++) {
      transacoes.add(_transacao(blocos[i], numero: i + 1));
    }

    return ExtratoImportado(transacoes: transacoes, instituicao: _campo(texto, 'ORG'));
  }

  TransacaoImportada _transacao(String bloco, {required int numero}) {
    final dataTexto = _campo(bloco, 'DTPOSTED');
    final valorTexto = _campo(bloco, 'TRNAMT');

    if (dataTexto == null) {
      throw FormatException('A transação $numero do OFX não tem data (DTPOSTED).');
    }
    if (valorTexto == null) {
      throw FormatException('A transação $numero do OFX não tem valor (TRNAMT).');
    }

    return TransacaoImportada(
      data: _data(dataTexto, numero: numero),
      descricao: _descricao(_campo(bloco, 'NAME'), _campo(bloco, 'MEMO')),
      valor: _valor(valorTexto, numero: numero),
    );
  }

  /// `AAAAMMDD` seguido, opcionalmente, de hora e fuso (`20261005120000[-3:BRT]`).
  /// Só o dia importa: o fuso não pode empurrar o lançamento para outra data.
  DateTime _data(String texto, {required int numero}) {
    final m = RegExp(r'^(\d{4})(\d{2})(\d{2})').firstMatch(texto);
    if (m == null) {
      throw FormatException('Data "$texto" inválida na transação $numero do OFX.');
    }
    final ano = int.parse(m.group(1)!);
    final mes = int.parse(m.group(2)!);
    final dia = int.parse(m.group(3)!);
    final data = DateTime(ano, mes, dia);
    // `DateTime` empurra datas impossíveis (31/02) para o mês seguinte em silêncio.
    if (data.year != ano || data.month != mes || data.day != dia) {
      throw FormatException('Data "$texto" não existe (transação $numero do OFX).');
    }
    return data;
  }

  /// OFX usa ponto decimal, mas alguns bancos brasileiros mandam vírgula.
  /// O último separador é o decimal; o outro, se houver, é de milhar.
  double _valor(String texto, {required int numero}) {
    var s = texto.replaceAll(RegExp(r'\s'), '');
    final ultimoPonto = s.lastIndexOf('.');
    final ultimaVirgula = s.lastIndexOf(',');

    if (ultimaVirgula > ultimoPonto) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else {
      s = s.replaceAll(',', '');
    }

    final valor = double.tryParse(s);
    if (valor == null || valor.isNaN || valor.isInfinite) {
      throw FormatException('Valor "$texto" inválido na transação $numero do OFX.');
    }
    return valor;
  }

  /// Bancos preenchem NAME, MEMO ou os dois. Une os dois quando diferem.
  String _descricao(String? nome, String? memo) {
    final n = nome?.trim() ?? '';
    final m = memo?.trim() ?? '';
    if (n.isEmpty && m.isEmpty) return 'Sem descrição';
    if (n.isEmpty) return m;
    if (m.isEmpty || m.toLowerCase() == n.toLowerCase()) return n;
    return '$n — $m';
  }

  /// Valor de `<TAG>valor` até a próxima tag ou quebra de linha — vale para o
  /// SGML (sem fechamento) e para o XML (`<TAG>valor</TAG>`).
  String? _campo(String texto, String tag) {
    final m = RegExp('<$tag>([^<\r\n]*)', caseSensitive: false).firstMatch(texto);
    final valor = m?.group(1)?.trim();
    if (valor == null || valor.isEmpty) return null;
    return _decodificarEntidades(valor);
  }

  String _decodificarEntidades(String s) {
    return s
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&');
  }

  /// UTF-8 quando o arquivo é válido nele; senão Latin-1/Windows-1252, que é o
  /// que os bancos brasileiros declaram (`CHARSET:1252`).
  String _decodificar(Uint8List bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes);
    }
  }
}
