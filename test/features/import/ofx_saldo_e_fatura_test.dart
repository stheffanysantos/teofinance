import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/import/data/services/ofx_parser.dart';
import 'package:teofinance/features/import/domain/services/pagamento_fatura.dart';

Uint8List _b(String s) => Uint8List.fromList(utf8.encode(s));

void main() {
  const parser = OfxParser();

  test('lê o saldo final (LEDGERBAL) de uma conta corrente', () {
    final e = parser.parsear(_b('''OFXHEADER:100
<OFX><BANKMSGSRSV1><STMTTRNRS><STMTRS>
<BANKTRANLIST>
<STMTTRN><DTPOSTED>20261005<TRNAMT>-50.00<FITID>1<NAME>Mercado</STMTTRN>
</BANKTRANLIST>
<LEDGERBAL><BALAMT>1234.56<DTASOF>20261031</LEDGERBAL>
<AVAILBAL><BALAMT>999.00<DTASOF>20261031</AVAILBAL>
</STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>'''));

    expect(e.saldoFinal, 1234.56);
    expect(e.ehCartao, isFalse);
  });

  test('fatura de cartão (CCSTMTRS) é reconhecida e sem saldo não quebra', () {
    final e = parser.parsear(_b('''OFXHEADER:100
<OFX><CREDITCARDMSGSRSV1><CCSTMTTRNRS><CCSTMTRS>
<BANKTRANLIST>
<STMTTRN><DTPOSTED>20261005<TRNAMT>-50.00<FITID>1<NAME>Loja</STMTTRN>
</BANKTRANLIST>
</CCSTMTRS></CCSTMTTRNRS></CREDITCARDMSGSRSV1></OFX>'''));

    expect(e.ehCartao, isTrue);
    expect(e.saldoFinal, isNull);
  });

  test('reconhece pagamento de fatura e não confunde com compra comum', () {
    expect(pareceTransferenciaDeFatura('Pagamento de fatura'), isTrue);
    expect(pareceTransferenciaDeFatura('PAGTO FATURA CARTÃO'), isTrue);
    expect(pareceTransferenciaDeFatura('Pagamento recebido'), isTrue);
    expect(pareceTransferenciaDeFatura('Mercado Pago'), isFalse);
    expect(pareceTransferenciaDeFatura('Pagamento de boleto'), isFalse);
    expect(pareceTransferenciaDeFatura('Fatura de internet'), isFalse);
  });
}
