import 'dart:math' as math;

import 'package:teofinance/features/parcelamento/domain/services/calculo_parcelas.dart';
import 'package:teofinance/features/recorrentes/domain/entities/gasto_recorrente.dart';
import 'package:teofinance/features/transacao/domain/entities/transacao.dart';

/// Tolerância para dois valores serem "o mesmo" numa assinatura.
const _toleranciaValor = 0.02;

/// Proporção mínima das cobranças que precisa estar no ritmo esperado.
const _proporcaoNoRitmo = 0.75;

/// Valores que variam mais que isso (maior/menor) não são uma conta recorrente.
const _razaoMaximaVariavel = 3.0;

const _palavrasSemSentido = {
  'compra', 'debito', 'credito', 'cartao', 'pagamento', 'pagto', 'pgto', 'pix',
  'transferencia', 'transf', 'enviada', 'enviado', 'recebida', 'recebido', 'para',
  'com', 'via', 'por', 'dos', 'das', 'ltda', 'eireli', 'online', 'visa', 'master',
};

/// Reduz uma descrição de extrato à sua parte estável: sem acentos, sem números,
/// datas ou pontuação e sem palavras de ruído, mantendo as 3 primeiras palavras
/// ("NETFLIX.COM 12/10" e "Netflix 4521" viram "netflix"). Vazio = sem identidade.
String normalizarDescricao(String descricao) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final semAcento = StringBuffer();
  for (final ch in descricao.toLowerCase().split('')) {
    final i = de.indexOf(ch);
    semAcento.write(i == -1 ? ch : para[i]);
  }

  final palavras = semAcento
      .toString()
      .replaceAll(RegExp(r'[^a-z\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((p) => p.length >= 3 && !_palavrasSemSentido.contains(p))
      .take(3);
  return palavras.join(' ');
}

class _Cobranca {
  _Cobranca(this.data, this.valor, this.descricao);

  final DateTime data;
  double valor;
  final String descricao;
}

/// Acha despesas que se repetem num ritmo regular: assinaturas, mensalidades e
/// contas. Função pura sobre o histórico, sem I/O.
///
/// Fora da conta: receitas, parcelas (já têm tela própria), grupos com poucas
/// cobranças ou fora de qualquer ritmo, e valores muito dispersos (compras de
/// supermercado, por exemplo, nunca viram "recorrente").
List<GastoRecorrente> detectarRecorrentes(List<Transacao> transacoes, {DateTime? agora}) {
  final hoje = agora ?? DateTime.now();

  final porChave = <String, List<_Cobranca>>{};
  for (final t in transacoes) {
    if (t.ehParcela || t.valorContabilizado >= 0) continue;
    final chave = normalizarDescricao(t.descricao);
    if (chave.isEmpty) continue;

    final dia = DateTime(t.data.year, t.data.month, t.data.day);
    final grupo = porChave.putIfAbsent(chave, () => []);
    // Duas cobranças no mesmo dia viram uma só, senão o intervalo seria zero.
    final repetida = grupo.where((c) => c.data == dia).firstOrNull;
    if (repetida != null) {
      repetida.valor += -t.valorContabilizado;
    } else {
      grupo.add(_Cobranca(dia, -t.valorContabilizado, t.descricao));
    }
  }

  final achados = <GastoRecorrente>[];
  porChave.forEach((chave, cobrancas) {
    cobrancas.sort((a, b) => a.data.compareTo(b.data));
    final gasto = _analisar(chave, cobrancas, hoje);
    if (gasto != null) achados.add(gasto);
  });

  achados.sort((a, b) {
    if (a.ativa != b.ativa) return a.ativa ? -1 : 1;
    return b.valorMensalEstimado.compareTo(a.valorMensalEstimado);
  });
  return achados;
}

GastoRecorrente? _analisar(String chave, List<_Cobranca> cobrancas, DateTime hoje) {
  final cadencia = _cadencia(cobrancas);
  if (cadencia == null) return null;

  final valores = cobrancas.map((c) => c.valor).toList();
  final ultimo = cobrancas.last;

  final RegularidadeGasto regularidade;
  final double valorTipico;
  double? variacao;

  if (cadencia == CadenciaGasto.anual) {
    // Só duas cobranças distantes: exige valor praticamente igual.
    final mediana = _mediana(valores);
    if (!_todosProximos(valores, mediana)) return null;
    regularidade = RegularidadeGasto.fixo;
    valorTipico = mediana;
  } else {
    final anteriores = valores.sublist(0, valores.length - 1);
    final medianaAnteriores = _mediana(anteriores);

    if (anteriores.length >= 2 && _proporcaoProxima(anteriores, medianaAnteriores) >= 0.8) {
      regularidade = RegularidadeGasto.fixo;
      valorTipico = medianaAnteriores;
      final mudanca = (ultimo.valor - medianaAnteriores) / medianaAnteriores;
      if (mudanca.abs() > _toleranciaValor) variacao = mudanca;
    } else {
      final menor = valores.reduce(math.min);
      final maior = valores.reduce(math.max);
      if (menor <= 0 || maior / menor > _razaoMaximaVariavel) return null;
      regularidade = RegularidadeGasto.variavel;
      valorTipico = _mediana(valores);
    }
  }

  return GastoRecorrente(
    chave: chave,
    descricao: ultimo.descricao.trim(),
    cadencia: cadencia,
    regularidade: regularidade,
    valorTipico: valorTipico,
    ultimoValor: ultimo.valor,
    ultimaData: ultimo.data,
    proximaData: _proxima(ultimo.data, cadencia),
    ocorrencias: cobrancas.length,
    ativa: _estaAtiva(ultimo.data, cadencia, hoje),
    variacaoDoUltimo: variacao,
  );
}

CadenciaGasto? _cadencia(List<_Cobranca> cobrancas) {
  if (cobrancas.length < 2) return null;

  final intervalos = [
    for (var i = 1; i < cobrancas.length; i++) cobrancas[i].data.difference(cobrancas[i - 1].data).inDays,
  ];

  double noRitmo(int de, int ate) => intervalos.where((d) => d >= de && d <= ate).length / intervalos.length;

  if (cobrancas.length >= 4 && noRitmo(6, 8) >= _proporcaoNoRitmo) return CadenciaGasto.semanal;
  if (cobrancas.length >= 3 && noRitmo(25, 36) >= _proporcaoNoRitmo) return CadenciaGasto.mensal;
  if (noRitmo(350, 380) == 1.0) return CadenciaGasto.anual;
  return null;
}

DateTime _proxima(DateTime ultima, CadenciaGasto cadencia) => switch (cadencia) {
      CadenciaGasto.semanal => ultima.add(const Duration(days: 7)),
      CadenciaGasto.mensal => dataDaParcela(ultima, 1),
      CadenciaGasto.anual => dataDaParcela(ultima, 12),
    };

/// Ativa enquanto o atraso da próxima cobrança não passa de metade do período.
bool _estaAtiva(DateTime ultima, CadenciaGasto cadencia, DateTime hoje) {
  final limiteEmDias = switch (cadencia) {
    CadenciaGasto.semanal => 11,
    CadenciaGasto.mensal => 45,
    CadenciaGasto.anual => 440,
  };
  return hoje.difference(ultima).inDays <= limiteEmDias;
}

double _mediana(List<double> valores) {
  final ordenados = [...valores]..sort();
  final meio = ordenados.length ~/ 2;
  return ordenados.length.isOdd ? ordenados[meio] : (ordenados[meio - 1] + ordenados[meio]) / 2;
}

bool _todosProximos(List<double> valores, double referencia) => _proporcaoProxima(valores, referencia) == 1.0;

double _proporcaoProxima(List<double> valores, double referencia) {
  if (referencia <= 0) return 0;
  final proximos = valores.where((v) => (v - referencia).abs() / referencia <= _toleranciaValor).length;
  return proximos / valores.length;
}
