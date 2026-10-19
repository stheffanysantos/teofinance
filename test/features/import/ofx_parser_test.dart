import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/import/data/services/ofx_parser.dart';

const _parser = OfxParser();

Uint8List _utf8(String s) => Uint8List.fromList(utf8.encode(s));
Uint8List _latin1(String s) => Uint8List.fromList(latin1.encode(s));

/// OFX 1.x (SGML): cabeçalho de texto, tags sem fechamento — formato mais comum
/// nos bancos brasileiros.
const _sgml = '''OFXHEADER:100
DATA:OFXSGML
VERSION:102
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:NONE

<OFX>
<SIGNONMSGSRSV1><SONRS><STATUS><CODE>0<SEVERITY>INFO</STATUS>
<DTSERVER>20261019120000[-3:BRT]<LANGUAGE>POR
<FI><ORG>Banco Exemplo<FID>123</FI></SONRS></SIGNONMSGSRSV1>
<BANKMSGSRSV1><STMTTRNRS><TRNUID>1<STATUS><CODE>0<SEVERITY>INFO</STATUS>
<STMTRS><CURDEF>BRL
<BANKACCTFROM><BANKID>001<ACCTID>12345-6<ACCTTYPE>CHECKING</BANKACCTFROM>
<BANKTRANLIST><DTSTART>20261001<DTEND>20261031
<STMTTRN>
<TRNTYPE>DEBIT
<DTPOSTED>20261005120000[-3:BRT]
<TRNAMT>-52.30
<FITID>2026100501
<MEMO>SUPERMERCADO CENTRAL
</STMTTRN>
<STMTTRN>
<TRNTYPE>CREDIT
<DTPOSTED>20261010
<TRNAMT>3500.00
<FITID>2026101001
<NAME>SALARIO
<MEMO>PAGAMENTO EMPRESA
</STMTTRN>
</BANKTRANLIST>
<LEDGERBAL><BALAMT>1000.00<DTASOF>20261031</LEDGERBAL>
</STMTRS></STMTTRNRS></BANKMSGSRSV1>
</OFX>
''';

/// OFX 2.x (XML): todas as tags fechadas.
const _xml = '''<?xml version="1.0" encoding="UTF-8"?>
<?OFX OFXHEADER="200" VERSION="211" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?>
<OFX>
  <SIGNONMSGSRSV1><SONRS><FI><ORG>Banco XML</ORG></FI></SONRS></SIGNONMSGSRSV1>
  <CREDITCARDMSGSRSV1><CCSTMTTRNRS><CCSTMTRS>
    <BANKTRANLIST>
      <STMTTRN>
        <TRNTYPE>DEBIT</TRNTYPE>
        <DTPOSTED>20261012000000</DTPOSTED>
        <TRNAMT>-199.90</TRNAMT>
        <FITID>a1</FITID>
        <NAME>LOJA &amp; CIA</NAME>
        <MEMO>LOJA &amp; CIA</MEMO>
      </STMTTRN>
    </BANKTRANLIST>
  </CCSTMTRS></CCSTMTTRNRS></CREDITCARDMSGSRSV1>
</OFX>
''';

String _transacao({String? data = '20261005', String? valor = '-10.00', String? memo = 'X'}) {
  return '<STMTTRN><TRNTYPE>DEBIT'
      '${data == null ? '' : '<DTPOSTED>$data'}'
      '${valor == null ? '' : '<TRNAMT>$valor'}'
      '${memo == null ? '' : '<MEMO>$memo'}</STMTTRN>';
}

Uint8List _arquivo(List<String> transacoes) =>
    _utf8('OFXHEADER:100\n<OFX><BANKTRANLIST>${transacoes.join('\n')}</BANKTRANLIST></OFX>');

void main() {
  group('detecção', () {
    test('reconhece OFX 1.x, OFX 2.x e o cabeçalho, mesmo com outra extensão', () {
      expect(_parser.ehOfx(_utf8(_sgml)), isTrue);
      expect(_parser.ehOfx(_utf8(_xml)), isTrue);
      expect(_parser.ehOfx(_utf8('<ofx><stmttrn></stmttrn></ofx>')), isTrue);
    });

    test('CSV não é confundido com OFX', () {
      expect(_parser.ehOfx(_utf8('Data;Descricao;Valor\n05/10/2026;Mercado;-52,30\n')), isFalse);
    });

    test('arquivo vazio não é OFX', () {
      expect(_parser.ehOfx(Uint8List(0)), isFalse);
    });
  });

  group('OFX 1.x (SGML)', () {
    final extrato = _parser.parsear(_utf8(_sgml));

    test('lê as duas transações com data, valor e sinal', () {
      expect(extrato.transacoes, hasLength(2));
      expect(extrato.transacoes[0].data, DateTime(2026, 10, 5));
      expect(extrato.transacoes[0].valor, -52.30);
      expect(extrato.transacoes[1].data, DateTime(2026, 10, 10));
      expect(extrato.transacoes[1].valor, 3500);
    });

    test('o fuso na data não desloca o dia', () {
      expect(extrato.transacoes[0].data, DateTime(2026, 10, 5));
    });

    test('descrição: só MEMO usa o MEMO; NAME e MEMO diferentes são unidos', () {
      expect(extrato.transacoes[0].descricao, 'SUPERMERCADO CENTRAL');
      expect(extrato.transacoes[1].descricao, 'SALARIO — PAGAMENTO EMPRESA');
    });

    test('informa a instituição e deixa a categoria para o usuário', () {
      expect(extrato.instituicao, 'Banco Exemplo');
      expect(extrato.transacoes.every((t) => t.precisaCategoria), isTrue);
    });
  });

  group('OFX 2.x (XML) de cartão', () {
    test('lê transação de cartão e decodifica entidades XML', () {
      final extrato = _parser.parsear(_utf8(_xml));

      expect(extrato.transacoes, hasLength(1));
      expect(extrato.transacoes.single.valor, -199.90);
      expect(extrato.transacoes.single.descricao, 'LOJA & CIA'); // NAME == MEMO não repete
      expect(extrato.instituicao, 'Banco XML');
    });
  });

  group('codificação e quebras de linha', () {
    test('Latin-1 (CHARSET:1252) preserva os acentos', () {
      final bytes = _latin1('OFXHEADER:100\nCHARSET:1252\n<OFX>${_transacao(memo: 'PADARIA SÃO JOÃO - AÇAÍ')}</OFX>');

      expect(_parser.parsear(bytes).transacoes.single.descricao, 'PADARIA SÃO JOÃO - AÇAÍ');
    });

    test('UTF-8 preserva os acentos', () {
      final bytes = _utf8('OFXHEADER:100\n<OFX>${_transacao(memo: 'FEIJÃO')}</OFX>');

      expect(_parser.parsear(bytes).transacoes.single.descricao, 'FEIJÃO');
    });

    test('quebras CRLF não entram nos valores', () {
      final bytes = _utf8(_sgml.replaceAll('\n', '\r\n'));

      final extrato = _parser.parsear(bytes);

      expect(extrato.transacoes[0].descricao, 'SUPERMERCADO CENTRAL');
      expect(extrato.transacoes[0].valor, -52.30);
    });
  });

  group('valores', () {
    double valor(String texto) => _parser.parsear(_arquivo([_transacao(valor: texto)])).transacoes.single.valor;

    test('ponto decimal, vírgula decimal e milhar nos dois estilos', () {
      expect(valor('-1234.56'), -1234.56);
      expect(valor('-1234,56'), -1234.56);
      expect(valor('-1.234,56'), -1234.56);
      expect(valor('-1,234.56'), -1234.56);
      expect(valor('+25.5'), 25.5);
      expect(valor('0.00'), 0);
    });

    test('valor que não é número interrompe com o número da transação', () {
      expect(
        () => _parser.parsear(_arquivo([_transacao(), _transacao(valor: 'abc')])),
        throwsA(isA<FormatException>().having((e) => e.message, 'mensagem', allOf(contains('transação 2'), contains('abc')))),
      );
    });
  });

  group('datas', () {
    test('data impossível (31/02) falha em vez de virar março em silêncio', () {
      expect(
        () => _parser.parsear(_arquivo([_transacao(data: '20260231')])),
        throwsA(isA<FormatException>().having((e) => e.message, 'mensagem', contains('não existe'))),
      );
    });

    test('mês 13 e texto solto falham', () {
      expect(() => _parser.parsear(_arquivo([_transacao(data: '20261305')])), throwsFormatException);
      expect(() => _parser.parsear(_arquivo([_transacao(data: 'ontem')])), throwsFormatException);
    });

    test('29/02 em ano bissexto é válido', () {
      final data = _parser.parsear(_arquivo([_transacao(data: '20280229')])).transacoes.single.data;

      expect(data, DateTime(2028, 2, 29));
    });
  });

  group('arquivo inválido', () {
    test('sem nenhuma transação', () {
      expect(
        () => _parser.parsear(_utf8('OFXHEADER:100\n<OFX><BANKTRANLIST></BANKTRANLIST></OFX>')),
        throwsA(isA<FormatException>().having((e) => e.message, 'mensagem', contains('Nenhuma transação'))),
      );
    });

    test('transação sem data ou sem valor aponta qual é', () {
      expect(
        () => _parser.parsear(_arquivo([_transacao(data: null)])),
        throwsA(isA<FormatException>().having((e) => e.message, 'mensagem', contains('DTPOSTED'))),
      );
      expect(
        () => _parser.parsear(_arquivo([_transacao(), _transacao(valor: null)])),
        throwsA(isA<FormatException>().having((e) => e.message, 'mensagem', allOf(contains('transação 2'), contains('TRNAMT')))),
      );
    });

    test('uma transação ruim impede a importação inteira (nada parcial)', () {
      expect(
        () => _parser.parsear(_arquivo([_transacao(), _transacao(), _transacao(valor: 'x')])),
        throwsFormatException,
      );
    });

    test('sem descrição vira "Sem descrição"', () {
      final t = _parser.parsear(_arquivo([_transacao(memo: null)])).transacoes.single;

      expect(t.descricao, 'Sem descrição');
    });
  });

  test('lê um extrato grande sem perder transações', () {
    final bytes = _arquivo([for (var i = 0; i < 2000; i++) _transacao(valor: '-${i + 1}.00')]);

    final extrato = _parser.parsear(bytes);

    expect(extrato.transacoes, hasLength(2000));
    expect(extrato.transacoes.last.valor, -2000);
  });
}
