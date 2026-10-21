import 'package:flutter_test/flutter_test.dart';
import 'package:teofinance/features/relatorio/data/services/relatorio_csv_service.dart';
import 'package:teofinance/features/relatorio/data/services/relatorio_pdf_service.dart';
import 'package:teofinance/features/relatorio/domain/entities/relatorio_mensal.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

void main() {
  final relatorio = RelatorioMensal.de(
    [
      Transacao(
        id: '1',
        descricao: 'Padaria; "Pão"',
        categoria: 'Mercado',
        valor: -12.5,
        data: DateTime(2026, 10, 3),
      ),
      Transacao(
        id: '2',
        descricao: 'Salário',
        categoria: 'Renda',
        valor: 3000,
        data: DateTime(2026, 10, 1),
      ),
    ],
    ano: 2026,
    mes: 10,
  );

  test('CSV usa ; e vírgula decimal e escapa campos com aspas e separador', () {
    final linhas = const RelatorioCsvService()
        .gerar(relatorio)
        .trim()
        .split(RegExp(r'\r?\n'));
    expect(
      linhas.first,
      'Data;Descrição;Categoria;Valor cobrado;Minha parte;Parcela',
    );
    expect(linhas[1], '01/10/2026;Salário;Renda;3000,00;3000,00;');
    expect(linhas[2], '03/10/2026;"Padaria; ""Pão""";Mercado;-12,50;-12,50;');
  });

  test('PDF é gerado com assinatura válida', () async {
    final bytes = await const RelatorioPdfService().gerar(relatorio);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('PDF de mês vazio também é gerado', () async {
    final bytes = await const RelatorioPdfService().gerar(
      RelatorioMensal.de([], ano: 2026, mes: 1),
    );
    expect(bytes.length, greaterThan(100));
  });
}
