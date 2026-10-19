import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/auth/domain/repositories/auth_repository.dart';
import 'package:teofinance/features/lgpd/domain/repositories/lgpd_repository.dart';
import 'package:teofinance/features/lgpd/domain/usecases/excluir_minha_conta_usecase.dart';
import 'package:teofinance/features/lgpd/domain/usecases/exportar_meus_dados_usecase.dart';

class _FakeLgpd implements LgpdRepository {
  int exportacoes = 0;
  String? senhaRecebida;
  bool falharNaExclusao = false;

  @override
  Future<Either<Failure, String>> exportarDados() async {
    exportacoes++;
    return const Right('{"ok":true}');
  }

  @override
  Future<Either<Failure, Unit>> excluirTodosOsDados({required String senha}) async {
    senhaRecebida = senha;
    return falharNaExclusao ? const Left(ServerFailure('boom')) : const Right(unit);
  }
}

class _FakeAuth implements AuthRepository {
  bool disponivel = false;
  bool habilitada = false;
  bool biometriaConfirma = true;
  int pedidosDeBiometria = 0;

  @override
  Future<bool> biometriaDisponivel() async => disponivel;

  @override
  Future<bool> biometriaHabilitada() async => habilitada;

  @override
  Future<Either<Failure, Unit>> autenticarComBiometria() async {
    pedidosDeBiometria++;
    return biometriaConfirma ? const Right(unit) : const Left(AuthFailure('Confirmação biométrica não realizada.'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Failure _falha<T>(Either<Failure, T> r) => r.swap().getOrElse((_) => throw StateError('esperava Left'));

void main() {
  late _FakeLgpd repo;
  late _FakeAuth auth;

  setUp(() {
    repo = _FakeLgpd();
    auth = _FakeAuth();
  });

  group('ExportarMeusDadosUseCase', () {
    test('sem biometria ativada exporta direto, sem pedir confirmação', () async {
      final r = await ExportarMeusDadosUseCase(repository: repo, auth: auth)();

      expect(r.getOrElse((_) => ''), '{"ok":true}');
      expect(auth.pedidosDeBiometria, 0);
    });

    test('com biometria ativada, pede a confirmação antes de exportar', () async {
      auth
        ..disponivel = true
        ..habilitada = true;

      final r = await ExportarMeusDadosUseCase(repository: repo, auth: auth)();

      expect(r.isRight(), isTrue);
      expect(auth.pedidosDeBiometria, 1);
    });

    test('biometria recusada impede a exportação', () async {
      auth
        ..disponivel = true
        ..habilitada = true
        ..biometriaConfirma = false;

      final r = await ExportarMeusDadosUseCase(repository: repo, auth: auth)();

      expect(_falha(r), isA<AuthFailure>());
      expect(repo.exportacoes, 0);
    });

    test('sincroniza antes de exportar e uma falha na sincronização não impede', () async {
      var sincronizou = false;
      final r = await ExportarMeusDadosUseCase(
        repository: repo,
        auth: auth,
        antesDeExportar: () async {
          sincronizou = true;
          throw StateError('sem conexão');
        },
      )();

      expect(sincronizou, isTrue);
      expect(r.isRight(), isTrue);
      expect(repo.exportacoes, 1);
    });
  });

  group('ExcluirMinhaContaUseCase', () {
    test('senha vazia é recusada sem tocar no repository nem na biometria', () async {
      auth
        ..disponivel = true
        ..habilitada = true;

      final r = await ExcluirMinhaContaUseCase(repository: repo, auth: auth)(senha: '');

      expect(_falha(r), isA<ValidationFailure>());
      expect(repo.senhaRecebida, isNull);
      expect(auth.pedidosDeBiometria, 0);
    });

    test('biometria recusada impede a exclusão', () async {
      auth
        ..disponivel = true
        ..habilitada = true
        ..biometriaConfirma = false;

      final r = await ExcluirMinhaContaUseCase(repository: repo, auth: auth)(senha: 'abc123');

      expect(_falha(r), isA<AuthFailure>());
      expect(repo.senhaRecebida, isNull);
    });

    test('com tudo confirmado, entrega a senha ao repository', () async {
      final r = await ExcluirMinhaContaUseCase(repository: repo, auth: auth)(senha: 'abc123');

      expect(r.isRight(), isTrue);
      expect(repo.senhaRecebida, 'abc123');
    });

    test('propaga a falha do repository', () async {
      repo.falharNaExclusao = true;

      final r = await ExcluirMinhaContaUseCase(repository: repo, auth: auth)(senha: 'abc123');

      expect(_falha(r).message, 'boom');
    });
  });
}
