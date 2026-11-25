import 'package:teofinance/features/budget/domain/entities/orcamento.dart';

enum SituacaoRitmo { estourado, acelerado, ok }

/// Como um envelope do orçamento está andando em relação ao calendário do mês.
class RitmoDoEnvelope {
  const RitmoDoEnvelope({
    required this.categoria,
    required this.gasto,
    required this.limite,
    required this.consumido,
    required this.previsto,
    required this.situacao,
  });

  final String categoria;
  final double gasto;
  final double limite;

  /// Fração do limite já usada (0 a mais de 1).
  final double consumido;

  /// Quanto se gastaria até o fim do mês mantendo o ritmo de agora.
  final double previsto;
  final SituacaoRitmo situacao;

  double get excedentePrevisto => previsto > limite ? previsto - limite : 0;
}

/// Antes deste dia do mês não dá para projetar: dois dias de gasto não dizem nada
/// sobre o mês.
const kDiaMinimoParaProjetar = 5;

/// Margem, em fração do mês, que o gasto pode estar à frente do calendário antes
/// de ser considerado acelerado.
const kMargemDeRitmo = 0.10;

/// Compara quanto de cada envelope já foi gasto com quanto do mês já passou.
/// Devolve primeiro os estourados, depois os acelerados (o que mais deve
/// estourar vem antes), depois os que estão em ordem.
List<RitmoDoEnvelope> avaliarRitmo({required List<EnvelopeOrcamento> envelopes, required DateTime hoje}) {
  final diasNoMes = DateTime(hoje.year, hoje.month + 1, 0).day;
  final decorrido = hoje.day / diasNoMes;
  final podeProjetar = hoje.day >= kDiaMinimoParaProjetar;

  final lista = <RitmoDoEnvelope>[];
  for (final e in envelopes) {
    final consumido = e.limite <= 0 ? 0.0 : e.gasto / e.limite;
    final previsto = podeProjetar && decorrido > 0 ? e.gasto / decorrido : e.gasto;
    final situacao = e.estourado
        ? SituacaoRitmo.estourado
        : (podeProjetar && previsto > e.limite && consumido > decorrido + kMargemDeRitmo
            ? SituacaoRitmo.acelerado
            : SituacaoRitmo.ok);
    lista.add(
      RitmoDoEnvelope(
        categoria: e.categoria,
        gasto: e.gasto,
        limite: e.limite,
        consumido: consumido,
        previsto: previsto,
        situacao: situacao,
      ),
    );
  }

  int ordem(RitmoDoEnvelope r) => switch (r.situacao) {
        SituacaoRitmo.estourado => 0,
        SituacaoRitmo.acelerado => 1,
        SituacaoRitmo.ok => 2,
      };
  lista.sort((a, b) {
    final porSituacao = ordem(a).compareTo(ordem(b));
    if (porSituacao != 0) return porSituacao;
    return a.situacao == SituacaoRitmo.acelerado
        ? b.excedentePrevisto.compareTo(a.excedentePrevisto)
        : b.consumido.compareTo(a.consumido);
  });
  return lista;
}
