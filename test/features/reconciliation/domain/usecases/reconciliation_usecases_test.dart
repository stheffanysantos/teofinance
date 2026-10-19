import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/reconciliation/domain/entities/extrato_linha.dart';
import 'package:teofinance/features/reconciliation/domain/entities/reconciliation_match.dart';
import 'package:teofinance/features/reconciliation/domain/repositories/reconciliation_repository.dart';
import 'package:teofinance/features/reconciliation/domain/usecases/aprovar_match_usecase.dart';
import 'package:teofinance/features/reconciliation/domain/usecases/fazer_reconciliacao_usecase.dart';
import 'package:teofinance/features/reconciliation/domain/usecases/obter_status_reconciliacao_usecase.dart';
import 'package:teofinance/features/reconciliation/domain/usecases/rejeitar_match_usecase.dart';
import 'package:teofinance/features/reconciliation/domain/usecases/vincular_manualmente_usecase.dart';

class _FakeRepository implements ReconciliationRepository {
  final chamadas = <String>[];
  bool falhar = false;

  Either<Failure, T> _resposta<T>(T valor) =>
      falhar ? const Left(ServerFailure('boom')) : Right(valor);

  @override
  Future<Either<Failure, ReconciliationResultado>> fazerMatching({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    chamadas.add('fazerMatching');
    return _resposta(const ReconciliationResultado(matches: [], linhas: {}, transacoes: {}));
  }

  @override
  Future<Either<Failure, void>> aprovarMatch(String matchId) async {
    chamadas.add('aprovarMatch:$matchId');
    return _resposta(null);
  }

  @override
  Future<Either<Failure, void>> rejeitarMatch(String matchId) async {
    chamadas.add('rejeitarMatch:$matchId');
    return _resposta(null);
  }

  @override
  Future<Either<Failure, ReconciliationMatch>> criarMatchManual({
    required String transacaoId,
    required String linhaExtratoId,
  }) async {
    chamadas.add('criarMatchManual');
    return _resposta(ReconciliationMatch(
      id: 'm1',
      transacaoId: transacaoId,
      linhaExtratoId: linhaExtratoId,
      dataReconciliacao: DateTime(2026, 10, 1),
      status: 'manual_matched',
      confidence: 1,
    ));
  }

  @override
  Future<Either<Failure, ReconciliationStatus>> obterStatusPeriodo({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  }) async {
    chamadas.add('obterStatusPeriodo');
    return _resposta(ReconciliationStatus(
      totalTransacoes: 2,
      totalLinhasExtrato: 2,
      matched: 1,
      orphans: 1,
      unmatched: 0,
      percentualReconciliado: 50,
    ));
  }

  @override
  Future<Either<Failure, List<ExtratoLinha>>> importarExtrato({
    required String importId,
    required List<Map<String, dynamic>> linhas,
  }) =>
      throw UnimplementedError();
}

Failure _falha<T>(Either<Failure, T> r) => r.swap().getOrElse((_) => throw StateError('esperava Left'));

void main() {
  late _FakeRepository repo;
  final inicio = DateTime(2026, 10, 1);
  final fim = DateTime(2026, 10, 31);

  setUp(() => repo = _FakeRepository());

  group('FazerReconciliacaoUseCase', () {
    test('delega ao repository com período válido', () async {
      final r = await FazerReconciliacaoUseCase(repo)(
        FazerReconciliacaoParams(userId: 'u', dataInicio: inicio, dataFim: fim),
      );

      expect(r.isRight(), isTrue);
      expect(repo.chamadas, ['fazerMatching']);
    });

    test('recusa período invertido sem chamar o repository', () async {
      final r = await FazerReconciliacaoUseCase(repo)(
        FazerReconciliacaoParams(userId: 'u', dataInicio: fim, dataFim: inicio),
      );

      expect(_falha(r), isA<ValidationFailure>());
      expect(repo.chamadas, isEmpty);
    });

    test('recusa usuário vazio', () async {
      final r = await FazerReconciliacaoUseCase(repo)(
        FazerReconciliacaoParams(userId: '', dataInicio: inicio, dataFim: fim),
      );

      expect(_falha(r), isA<ValidationFailure>());
      expect(repo.chamadas, isEmpty);
    });

    test('propaga a falha do repository', () async {
      repo.falhar = true;
      final r = await FazerReconciliacaoUseCase(repo)(
        FazerReconciliacaoParams(userId: 'u', dataInicio: inicio, dataFim: fim),
      );

      expect(_falha(r).message, 'boom');
    });
  });

  group('AprovarMatchUseCase / RejeitarMatchUseCase', () {
    test('aprovar delega com id válido e recusa id vazio', () async {
      expect((await AprovarMatchUseCase(repo)('m1')).isRight(), isTrue);
      expect((await AprovarMatchUseCase(repo)('')).isLeft(), isTrue);
      expect(repo.chamadas, ['aprovarMatch:m1']);
    });

    test('rejeitar delega com id válido e recusa id vazio', () async {
      expect((await RejeitarMatchUseCase(repo)('m1')).isRight(), isTrue);
      expect((await RejeitarMatchUseCase(repo)('')).isLeft(), isTrue);
      expect(repo.chamadas, ['rejeitarMatch:m1']);
    });

    test('aprovar propaga a falha do repository', () async {
      repo.falhar = true;
      expect(_falha(await AprovarMatchUseCase(repo)('m1')).message, 'boom');
    });
  });

  group('VincularManualmenteUseCase', () {
    test('cria o vínculo quando os dois ids existem', () async {
      final r = await VincularManualmenteUseCase(repo)(
        const VincularManualmenteParams(transacaoId: 't1', linhaExtratoId: 'l1'),
      );

      final match = r.getOrElse((_) => throw StateError('esperava Right'));
      expect(match.status, 'manual_matched');
      expect(match.transacaoId, 't1');
    });

    test('recusa quando falta transação ou linha', () async {
      final useCase = VincularManualmenteUseCase(repo);

      expect((await useCase(const VincularManualmenteParams(transacaoId: '', linhaExtratoId: 'l1'))).isLeft(), isTrue);
      expect((await useCase(const VincularManualmenteParams(transacaoId: 't1', linhaExtratoId: ''))).isLeft(), isTrue);
      expect(repo.chamadas, isEmpty);
    });
  });

  group('ObterStatusReconciliacaoUseCase', () {
    test('devolve o status do período', () async {
      final r = await ObterStatusReconciliacaoUseCase(repo)(
        ObterStatusReconciliacaoParams(userId: 'u', dataInicio: inicio, dataFim: fim),
      );

      expect(r.getOrElse((_) => throw StateError('esperava Right')).matched, 1);
    });

    test('recusa período invertido', () async {
      final r = await ObterStatusReconciliacaoUseCase(repo)(
        ObterStatusReconciliacaoParams(userId: 'u', dataInicio: fim, dataFim: inicio),
      );

      expect(_falha(r), isA<ValidationFailure>());
      expect(repo.chamadas, isEmpty);
    });
  });
}
