import 'package:teofinance/features/planejamento/domain/services/historico_de_gastos.dart';
import 'package:teofinance/features/renda/domain/entities/renda.dart';

/// Categorias que o plano nunca corta: sem elas a vida não fecha.
const kCategoriasEssenciais = {'Moradia', 'Saúde', 'Mercado', 'Alimentação', 'Transporte', 'Educação'};

/// Uma categoria flexível pode ser reduzida até esta fração do que se gasta
/// hoje; abaixo disso o plano deixa de ser realista.
const kPisoFlexivel = 0.4;

class LinhaDoPlano {
  const LinhaDoPlano({
    required this.categoria,
    required this.mediaHistorica,
    required this.fixoDasContas,
    required this.limiteSugerido,
    required this.essencial,
  });

  final String categoria;

  /// Quanto se gasta nela por mês, em média.
  final double mediaHistorica;

  /// O que já está comprometido por contas a pagar do mês nesta categoria.
  final double fixoDasContas;

  /// Quanto o plano sugere gastar neste mês (em reais inteiros).
  final double limiteSugerido;
  final bool essencial;

  /// Quanto o plano pede para gastar a menos do que o normal.
  double get corte {
    final base = mediaHistorica > fixoDasContas ? mediaHistorica : fixoDasContas;
    return base > limiteSugerido ? base - limiteSugerido : 0;
  }
}

class PlanoDoMes {
  const PlanoDoMes({
    required this.salario,
    required this.metaGuardar,
    required this.linhas,
    required this.folga,
    required this.faltaCobrir,
    required this.guardarPossivel,
  });

  final double salario;

  /// Quanto separar para guardar/investir antes de gastar.
  final double metaGuardar;
  final List<LinhaDoPlano> linhas;

  /// O que sobra depois de cobrir todas as categorias do jeito que se gasta hoje.
  final double folga;

  /// O que falta mesmo cortando o que dá nas categorias flexíveis.
  final double faltaCobrir;

  /// O máximo que dá para guardar, cortando tudo o que é flexível ao piso.
  final double guardarPossivel;

  double get disponivel => salario - metaGuardar;
  double get totalLimites => linhas.fold(0.0, (a, l) => a + l.limiteSugerido);
  bool get viavel => faltaCobrir <= 0.005;
}

/// Renda mensal fixa esperada: soma das rendas fixas ativas, levando semanal e
/// anual para o equivalente mensal. Renda variável fica de fora de propósito.
double salarioMensal(List<Renda> rendas) {
  var total = 0.0;
  for (final r in rendas) {
    if (!r.isFixa || !r.ativa) continue;
    total += switch (r.recorrencia ?? RecorrenciaRenda.mensal) {
      RecorrenciaRenda.mensal => r.valor,
      RecorrenciaRenda.semanal => r.valor * 52 / 12,
      RecorrenciaRenda.anual => r.valor / 12,
    };
  }
  return total;
}

bool _essencial(String categoria) => kCategoriasEssenciais.contains(categoria);

/// Sugere quanto gastar em cada categoria neste mês, reservando antes a meta de
/// guardar ([percentualGuardar], de 0 a 1) sobre o [salario].
///
/// O ponto de partida é o que a pessoa já gasta (média do histórico), com o piso
/// das contas fixas do mês. Se couber, os limites são esses. Se não couber, só
/// as categorias flexíveis são reduzidas, proporcionalmente, até o piso; as
/// essenciais não são cortadas. O que não der para cobrir fica em
/// [PlanoDoMes.faltaCobrir].
PlanoDoMes calcularPlanoDoMes({
  required double salario,
  required double percentualGuardar,
  required HistoricoDeGastos historico,
  Map<String, double> contasFixasPorCategoria = const {},
}) {
  final pct = percentualGuardar.clamp(0.0, 1.0);
  final metaGuardar = salario * pct;
  final disponivel = salario - metaGuardar;

  final categorias = {...historico.mediaPorCategoria.keys, ...contasFixasPorCategoria.keys};
  final base = <String, double>{};
  final minimo = <String, double>{};
  for (final c in categorias) {
    final media = historico.mediaPorCategoria[c] ?? 0;
    final fixo = contasFixasPorCategoria[c] ?? 0;
    final b = media > fixo ? media : fixo;
    base[c] = b;
    minimo[c] = _essencial(c) ? b : (b * kPisoFlexivel > fixo ? b * kPisoFlexivel : fixo);
  }

  final totalBase = base.values.fold(0.0, (a, b) => a + b);
  final totalMinimo = minimo.values.fold(0.0, (a, b) => a + b);
  final capacidade = totalBase - totalMinimo;

  final deficit = totalBase - disponivel;
  final corteTotal = deficit <= 0 ? 0.0 : (deficit < capacidade ? deficit : capacidade);

  final linhas = <LinhaDoPlano>[];
  for (final c in categorias) {
    final cap = base[c]! - minimo[c]!;
    final corte = capacidade > 0 ? corteTotal * cap / capacidade : 0.0;
    final limite = (base[c]! - corte).roundToDouble();
    linhas.add(
      LinhaDoPlano(
        categoria: c,
        mediaHistorica: historico.mediaPorCategoria[c] ?? 0,
        fixoDasContas: contasFixasPorCategoria[c] ?? 0,
        limiteSugerido: limite < 1 ? 1 : limite,
        essencial: _essencial(c),
      ),
    );
  }
  linhas.sort((a, b) => b.limiteSugerido.compareTo(a.limiteSugerido));

  final guardarPossivel = salario - totalMinimo;
  return PlanoDoMes(
    salario: salario,
    metaGuardar: metaGuardar,
    linhas: linhas,
    folga: deficit < 0 ? -deficit : 0,
    faltaCobrir: deficit > capacidade ? deficit - capacidade : 0,
    guardarPossivel: guardarPossivel < 0 ? 0 : guardarPossivel,
  );
}
