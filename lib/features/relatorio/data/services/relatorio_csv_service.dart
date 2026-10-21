import 'package:csv/csv.dart';
import 'package:teofinance/features/relatorio/domain/entities/relatorio_mensal.dart';

/// Gera o CSV do mês. Separador `;` e vírgula decimal, que é o que o Excel
/// em pt-BR abre direto sem assistente de importação.
class RelatorioCsvService {
  const RelatorioCsvService();

  String gerar(RelatorioMensal relatorio) {
    final linhas = <List<String>>[
      [
        'Data',
        'Descrição',
        'Categoria',
        'Valor cobrado',
        'Minha parte',
        'Parcela',
      ],
      for (final t in relatorio.transacoes)
        [
          _data(t.data),
          t.descricao,
          t.precisaCategoria ? RelatorioMensal.semCategoria : t.categoria,
          _numero(t.valorCobrado),
          _numero(t.valorContabilizado),
          t.ehParcela && t.numeroParcela != null ? '${t.numeroParcela}' : '',
        ],
    ];
    return Csv(fieldDelimiter: ';').encode(linhas);
  }

  String _data(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _numero(double v) => v.toStringAsFixed(2).replaceAll('.', ',');
}
