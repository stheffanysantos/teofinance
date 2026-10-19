import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/features/lgpd/data/datasources/lgpd_conta_data_source.dart';
import 'package:teofinance/features/lgpd/data/datasources/lgpd_local_data_source.dart';
import 'package:teofinance/features/lgpd/data/datasources/lgpd_remote_data_source.dart';
import 'package:teofinance/features/lgpd/domain/repositories/lgpd_repository.dart';

class LgpdRepositoryImpl implements LgpdRepository {
  LgpdRepositoryImpl(this._local, this._remote, this._conta, {DateTime Function() agora = DateTime.now})
      : _agora = agora;

  final LgpdLocalDataSource _local;
  final LgpdRemoteDataSource _remote;
  final LgpdContaDataSource _conta;
  final DateTime Function() _agora;

  @override
  Future<Either<Failure, String>> exportarDados() async {
    try {
      final dados = await _local.exportarTudo();
      final arquivo = {
        'versao': 1,
        'exportadoEm': _agora().toIso8601String(),
        'conta': {'uid': _conta.uid, 'email': _conta.email},
        'dados': dados,
      };
      return Right(const JsonEncoder.withIndent('  ').convert(arquivo));
    } catch (_) {
      return const Left(CacheFailure('Não foi possível reunir seus dados.'));
    }
  }

  /// Ordem pensada para poder repetir a operação sem perder o acesso:
  /// 1. reautentica (senha errada não apaga nada);
  /// 2. apaga o Firestore (precisa da sessão ainda válida);
  /// 3. apaga a conta; 4. só então apaga o que é local.
  /// Se algo falhar no meio, o usuário continua logado e tenta de novo.
  @override
  Future<Either<Failure, Unit>> excluirTodosOsDados({required String senha}) async {
    final uid = _conta.uid;
    if (uid == null) return const Left(AuthFailure('Entre na sua conta para continuar.'));

    try {
      await _conta.reautenticar(senha);
    } on fb.FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mensagemReautenticacao(e)));
    } catch (_) {
      return const Left(AuthFailure('Não foi possível confirmar sua senha.'));
    }

    try {
      await _remote.excluirDadosDoUsuario(uid);
    } on FirebaseException catch (_) {
      return const Left(ServerFailure(
        'Não foi possível apagar seus dados na nuvem. Verifique a conexão e tente de novo.',
      ));
    }

    try {
      await _conta.excluirConta();
    } on fb.FirebaseAuthException catch (_) {
      return const Left(AuthFailure(
        'Seus dados foram apagados, mas a conta não. Saia, entre de novo e repita a exclusão.',
      ));
    }

    try {
      await _local.apagarTudo();
    } catch (_) {
      return const Left(CacheFailure(
        'Sua conta foi excluída, mas os dados deste aparelho não foram limpos. Desinstale o app para removê-los.',
      ));
    }
    return const Right(unit);
  }

  String _mensagemReautenticacao(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Senha incorreta.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente de novo.';
      default:
        return 'Não foi possível confirmar sua senha.';
    }
  }
}
