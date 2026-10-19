import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/contas/domain/entities/conta_a_pagar.dart';
import 'package:teofinance/features/contas/domain/repositories/conta_repository.dart';
import 'package:teofinance/features/contas/domain/services/proxima_ocorrencia.dart';
import 'package:teofinance/features/transacao/domain/repositories/transacao_repository.dart';

/// Registra o pagamento de uma conta: cria a despesa correspondente, marca a
/// conta como paga e, se ela se repete, já deixa a próxima na lista.
class MarcarContaComoPagaUseCase {
  MarcarContaComoPagaUseCase({
    required ContaRepository contas,
    required TransacaoRepository transacoes,
    DateTime Function() agora = DateTime.now,
  })  : _contas = contas,
        _transacoes = transacoes,
        _agora = agora;

  final ContaRepository _contas;
  final TransacaoRepository _transacoes;
  final DateTime Function() _agora;

  /// [valorPago] é o valor real (pode diferir do esperado em conta variável).
  /// [categoria] vazia usa a categoria da própria conta.
  Future<Either<Failure, Unit>> call({
    required ContaAPagar conta,
    required double valorPago,
    DateTime? dataPagamento,
    String? categoria,
  }) async {
    if (conta.paga) return const Left(ValidationFailure('Esta conta já foi paga.'));
    if (valorPago.isNaN || valorPago.isInfinite || valorPago <= 0) {
      return const Left(ValidationFailure('Informe o valor pago, maior que zero.'));
    }

    final data = dataPagamento ?? _agora();

    final despesa = await _transacoes.criar(
      descricao: conta.descricao,
      valor: -valorPago,
      data: data,
      categoria: (categoria == null || categoria.trim().isEmpty) ? conta.categoria : categoria.trim(),
    );
    return despesa.fold(
      (falha) => Future.value(Left(falha)),
      (transacao) => _concluir(conta, transacao.id, valorPago, data),
    );
  }

  Future<Either<Failure, Unit>> _concluir(ContaAPagar conta, String transacaoId, double valorPago, DateTime data) async {
    final marcada = await _contas.marcarComoPaga(
      id: conta.id,
      valorPago: valorPago,
      dataPagamento: data,
      transacaoId: transacaoId,
    );

    if (marcada.isLeft()) {
      // Sem desfazer, a despesa ficaria registrada com a conta ainda em aberto,
      // e um novo "pagar" a contaria duas vezes.
      await _transacoes.excluir(transacaoId);
      return marcada;
    }

    return _criarProxima(conta);
  }

  Future<Either<Failure, Unit>> _criarProxima(ContaAPagar conta) async {
    final proximo = proximoVencimento(
      vencimento: conta.vencimento,
      diaBase: conta.diaBase,
      recorrencia: conta.recorrencia,
    );
    if (proximo == null) return const Right(unit);

    // Já existe (ex.: veio de outro aparelho): não duplica.
    final existentes = await _contas.observarTodas().first;
    final jaExiste = existentes.any(
      (c) => !c.paga && c.descricao == conta.descricao && soDia(c.vencimento) == soDia(proximo),
    );
    if (jaExiste) return const Right(unit);

    final criada = await _contas.criar(
      descricao: conta.descricao,
      valor: conta.valor,
      vencimento: proximo,
      categoria: conta.categoria,
      recorrencia: conta.recorrencia,
      diasAntesLembrete: conta.diasAntesLembrete,
      diaBase: conta.diaBase,
    );
    return criada.fold(
      (_) => const Left(CacheFailure('Conta paga, mas não foi possível criar a próxima. Crie-a manualmente.')),
      (_) => const Right(unit),
    );
  }
}
