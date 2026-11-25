import 'package:teofinance/features/cartao/domain/services/projecao_faturas.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/services/proxima_ocorrencia.dart';
import 'package:teofinance/features/renda/domain/entities/renda.dart';

enum TipoEventoFluxo { entrada, conta, fatura }

class EventoDoFluxo {
  const EventoDoFluxo({required this.data, required this.descricao, required this.valor, required this.tipo});

  final DateTime data;
  final String descricao;

  /// Positivo entra na conta, negativo sai.
  final double valor;
  final TipoEventoFluxo tipo;
}

/// Um dia em que o saldo muda, já com o saldo ao fim do dia.
class DiaDoFluxo {
  const DiaDoFluxo({required this.data, required this.saldo, required this.eventos});

  final DateTime data;
  final double saldo;
  final List<EventoDoFluxo> eventos;
}

class FluxoDeCaixa {
  const FluxoDeCaixa({required this.saldoInicial, required this.dias, required this.horizonteDias});

  final double saldoInicial;

  /// Só os dias com algum evento, em ordem.
  final List<DiaDoFluxo> dias;
  final int horizonteDias;

  double get saldoFinal => dias.isEmpty ? saldoInicial : dias.last.saldo;

  /// O dia em que o saldo chega ao ponto mais baixo, ou nulo sem eventos.
  DiaDoFluxo? get menorSaldo => dias.isEmpty ? null : dias.reduce((a, b) => b.saldo < a.saldo ? b : a);

  /// Primeiro dia em que a conta fica negativa, se isso acontecer.
  DiaDoFluxo? get primeiraFalta {
    for (final d in dias) {
      if (d.saldo < 0) return d;
    }
    return null;
  }
}

DateTime _soDia(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _somarMeses(DateTime d, int meses, int diaBase) {
  final primeiro = DateTime(d.year, d.month + meses);
  final ultimo = DateTime(primeiro.year, primeiro.month + 1, 0).day;
  return DateTime(primeiro.year, primeiro.month, diaBase > ultimo ? ultimo : diaBase);
}

/// Datas em que uma renda cai entre [hoje] e [limite] (inclusive).
List<DateTime> _recebimentos(Renda r, DateTime hoje, DateTime limite) {
  final primeira = _soDia(r.dataRecebimento);
  if (!r.isFixa || r.recorrencia == null) {
    return !primeira.isBefore(hoje) && !primeira.isAfter(limite) ? [primeira] : const [];
  }

  final datas = <DateTime>[];
  var atual = primeira;
  var passo = 0;
  while (!atual.isAfter(limite) && passo < 400) {
    if (!atual.isBefore(hoje)) datas.add(atual);
    passo++;
    atual = switch (r.recorrencia!) {
      RecorrenciaRenda.semanal => primeira.add(Duration(days: 7 * passo)),
      RecorrenciaRenda.mensal => _somarMeses(primeira, passo, primeira.day),
      RecorrenciaRenda.anual => _somarMeses(primeira, 12 * passo, primeira.day),
    };
  }
  return datas;
}

/// Projeta o saldo da conta dia a dia pelos próximos [horizonteDias], a partir do
/// [saldoInicial] (o "saldo na conta" da Home). Entram: o que as rendas fixas
/// pagam, as contas a pagar em aberto (e a próxima ocorrência das que se repetem)
/// e as faturas de cartão em aberto, pelo valor que o banco cobra. Conta ou
/// fatura já vencida e não paga é tratada como saindo hoje. Reembolsos a receber
/// não entram: não têm data certa.
FluxoDeCaixa projetarFluxoDeCaixa({
  required double saldoInicial,
  required DateTime hoje,
  required List<Renda> rendas,
  required List<ContaAPagar> contas,
  required List<MesDeFaturas> faturas,
  int horizonteDias = 60,
}) {
  final inicio = _soDia(hoje);
  final limite = inicio.add(Duration(days: horizonteDias));
  final eventos = <EventoDoFluxo>[];

  for (final r in rendas) {
    if (!r.ativa) continue;
    for (final data in _recebimentos(r, inicio, limite)) {
      eventos.add(EventoDoFluxo(data: data, descricao: r.descricao, valor: r.valor, tipo: TipoEventoFluxo.entrada));
    }
  }

  for (final c in contas) {
    if (c.paga) continue;
    var venc = _soDia(c.vencimento);
    var repeticao = 0;
    while (!venc.isAfter(limite) && repeticao < 12) {
      eventos.add(
        EventoDoFluxo(
          data: venc.isBefore(inicio) ? inicio : venc,
          descricao: c.descricao,
          valor: -c.valor,
          tipo: TipoEventoFluxo.conta,
        ),
      );
      final proximo = proximoVencimento(vencimento: venc, diaBase: c.diaBase, recorrencia: c.recorrencia);
      if (proximo == null) break;
      venc = proximo;
      repeticao++;
    }
  }

  for (final mes in faturas) {
    for (final f in mes.faturas) {
      final venc = _soDia(f.vencimento);
      if (venc.isAfter(limite)) continue;
      eventos.add(
        EventoDoFluxo(
          data: venc.isBefore(inicio) ? inicio : venc,
          descricao: 'Fatura ${f.cartao.nome}',
          valor: -f.total,
          tipo: TipoEventoFluxo.fatura,
        ),
      );
    }
  }

  final porDia = <DateTime, List<EventoDoFluxo>>{};
  for (final e in eventos) {
    porDia.putIfAbsent(e.data, () => []).add(e);
  }

  final datas = porDia.keys.toList()..sort();
  var saldo = saldoInicial;
  final dias = <DiaDoFluxo>[];
  for (final data in datas) {
    final doDia = porDia[data]!..sort((a, b) => b.valor.compareTo(a.valor)); // entradas primeiro
    saldo += doDia.fold(0.0, (a, e) => a + e.valor);
    dias.add(DiaDoFluxo(data: data, saldo: saldo, eventos: doDia));
  }

  return FluxoDeCaixa(saldoInicial: saldoInicial, dias: dias, horizonteDias: horizonteDias);
}
