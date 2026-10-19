import 'package:teofinance/core/sync/sync_status.dart';

enum RecorrenciaConta {
  nenhuma('Não se repete'),
  mensal('Todo mês'),
  anual('Todo ano');

  const RecorrenciaConta(this.rotulo);

  final String rotulo;
}

enum StatusConta { paga, atrasada, venceHoje, aVencer }

DateTime soDia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Uma conta com vencimento (boleto, mensalidade, imposto) e lembrete.
class ContaAPagar {
  const ContaAPagar({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.vencimento,
    required this.diaBase,
    this.categoria = '',
    this.recorrencia = RecorrenciaConta.nenhuma,
    this.paga = false,
    this.dataPagamento,
    this.valorPago,
    this.diasAntesLembrete = 1,
    this.transacaoId,
    this.remoteId,
    this.syncStatus = SyncStatus.pendingCreate,
  });

  final String id;
  final String? remoteId;
  final String descricao;
  final String categoria;

  /// Valor esperado. Em conta variável (luz, água) é uma estimativa; o valor
  /// real fica em [valorPago] ao pagar.
  final double valor;
  final DateTime vencimento;

  /// Dia do mês do primeiro vencimento: mantém o dia 31 depois de fevereiro.
  final int diaBase;
  final RecorrenciaConta recorrencia;
  final bool paga;
  final DateTime? dataPagamento;
  final double? valorPago;
  final int diasAntesLembrete;

  /// Despesa criada quando a conta foi paga.
  final String? transacaoId;
  final SyncStatus syncStatus;

  StatusConta statusEm(DateTime hoje) {
    if (paga) return StatusConta.paga;
    final venc = soDia(vencimento);
    final dia = soDia(hoje);
    if (venc.isBefore(dia)) return StatusConta.atrasada;
    if (venc == dia) return StatusConta.venceHoje;
    return StatusConta.aVencer;
  }

  /// Dias até vencer (negativo = atrasada).
  int diasParaVencer(DateTime hoje) => soDia(vencimento).difference(soDia(hoje)).inDays;

  /// Data do lembrete: [diasAntesLembrete] dias antes do vencimento.
  DateTime get diaDoLembrete => soDia(vencimento).subtract(Duration(days: diasAntesLembrete));

  /// Muda o vencimento e o dia-base juntos (o dia do novo vencimento passa a
  /// valer para as próximas ocorrências). Editar só a descrição ou o valor, com
  /// [copyWith], preserva o dia-base.
  ContaAPagar reagendada(DateTime novoVencimento) {
    final dia = soDia(novoVencimento);
    return copyWith(vencimento: dia, diaBase: dia.day);
  }

  ContaAPagar copyWith({
    String? descricao,
    String? categoria,
    double? valor,
    DateTime? vencimento,
    int? diaBase,
    RecorrenciaConta? recorrencia,
    int? diasAntesLembrete,
  }) {
    return ContaAPagar(
      id: id,
      remoteId: remoteId,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      valor: valor ?? this.valor,
      vencimento: vencimento ?? this.vencimento,
      diaBase: diaBase ?? this.diaBase,
      recorrencia: recorrencia ?? this.recorrencia,
      paga: paga,
      dataPagamento: dataPagamento,
      valorPago: valorPago,
      diasAntesLembrete: diasAntesLembrete ?? this.diasAntesLembrete,
      transacaoId: transacaoId,
      syncStatus: syncStatus,
    );
  }
}
