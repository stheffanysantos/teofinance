import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:teofinance/core/utils/currency_format.dart';
import 'package:teofinance/core/utils/date_label.dart';
import 'package:teofinance/features/relatorio/domain/entities/relatorio_mensal.dart';

/// Gera o PDF do mês: totais, despesas por categoria e a lista de lançamentos.
/// Usa a fonte padrão do PDF (sem U+2212), por isso o sinal é o hífen simples.
class RelatorioPdfService {
  const RelatorioPdfService();

  Future<Uint8List> gerar(RelatorioMensal relatorio) async {
    final doc = pw.Document(title: 'TeoFinance - ${titulo(relatorio)}');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            'TeoFinance',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(titulo(relatorio), style: const pw.TextStyle(fontSize: 13)),
          pw.SizedBox(height: 16),
          _totais(relatorio),
          if (relatorio.despesasPorCategoria.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text(
              'Despesas por categoria',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ['Categoria', 'Total', '% das despesas'],
              data: [
                for (final e in relatorio.despesasPorCategoria.entries)
                  [
                    e.key,
                    formatCurrency(e.value),
                    '${(e.value / relatorio.despesas * 100).toStringAsFixed(1)}%',
                  ],
              ],
              cellAlignments: {
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
              },
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
          pw.SizedBox(height: 16),
          pw.Text(
            'Lançamentos',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (relatorio.vazio)
            pw.Text('Nenhum lançamento neste mês.')
          else
            pw.TableHelper.fromTextArray(
              headers: ['Data', 'Descrição', 'Categoria', 'Valor'],
              data: [
                for (final t in relatorio.transacoes)
                  [
                    '${t.data.day.toString().padLeft(2, '0')}/${t.data.month.toString().padLeft(2, '0')}',
                    t.descricao,
                    t.precisaCategoria
                        ? RelatorioMensal.semCategoria
                        : t.categoria,
                    formatCurrency(t.valorContabilizado),
                  ],
              ],
              columnWidths: {
                0: const pw.FixedColumnWidth(44),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(1.4),
                3: const pw.FixedColumnWidth(80),
              },
              cellAlignments: {3: pw.Alignment.centerRight},
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
        ],
      ),
    );

    return doc.save();
  }

  static String titulo(RelatorioMensal r) =>
      '${kMesesPorExtenso[r.mes - 1]} de ${r.ano}';

  pw.Widget _totais(RelatorioMensal r) {
    pw.Widget item(String rotulo, double valor) => pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              rotulo,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              formatCurrency(valor),
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    return pw.Row(
      children: [
        item('Receitas', r.receitas),
        pw.SizedBox(width: 8),
        item('Despesas', r.despesas),
        pw.SizedBox(width: 8),
        item('Saldo', r.saldo),
      ],
    );
  }
}
