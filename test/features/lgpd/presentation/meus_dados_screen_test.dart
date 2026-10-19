import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:teofinance/core/errors/failure.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/auth/domain/repositories/auth_repository.dart';
import 'package:teofinance/features/lgpd/domain/repositories/lgpd_repository.dart';
import 'package:teofinance/features/lgpd/domain/usecases/excluir_minha_conta_usecase.dart';
import 'package:teofinance/features/lgpd/domain/usecases/exportar_meus_dados_usecase.dart';
import 'package:teofinance/features/lgpd/presentation/notifiers/meus_dados_notifier.dart';
import 'package:teofinance/features/lgpd/presentation/providers/lgpd_providers.dart';
import 'package:teofinance/features/lgpd/presentation/screens/meus_dados_screen.dart';

class _FakeLgpd implements LgpdRepository {
  String? senhaRecebida;
  int exclusoes = 0;
  Either<Failure, Unit> respostaExclusao = const Right(unit);
  Either<Failure, String> respostaExportacao = const Left(CacheFailure('Não foi possível reunir seus dados.'));

  @override
  Future<Either<Failure, String>> exportarDados() async => respostaExportacao;

  @override
  Future<Either<Failure, Unit>> excluirTodosOsDados({required String senha}) async {
    exclusoes++;
    senhaRecebida = senha;
    return respostaExclusao;
  }
}

class _FakeAuth implements AuthRepository {
  @override
  Future<bool> biometriaDisponivel() async => false;

  @override
  Future<bool> biometriaHabilitada() async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(_FakeLgpd repo) {
  final auth = _FakeAuth();
  return ProviderScope(
    overrides: [
      meusDadosNotifierProvider.overrideWith((ref) => MeusDadosNotifier(
            exportar: ExportarMeusDadosUseCase(repository: repo, auth: auth),
            excluir: ExcluirMinhaContaUseCase(repository: repo, auth: auth),
          )),
    ],
    child: MaterialApp(theme: AppTheme.light(), home: const MeusDadosScreen()),
  );
}

Future<void> _abrirExclusao(WidgetTester tester) async {
  await tester.tap(find.text('Excluir conta'));
  await tester.pumpAndSettle();
}

void main() {
  late _FakeLgpd repo;

  setUp(() => repo = _FakeLgpd());

  testWidgets('mostra as duas opções do titular', (tester) async {
    await tester.pumpWidget(_app(repo));

    expect(find.text('Privacidade e dados'), findsOneWidget);
    expect(find.text('Exportar meus dados'), findsOneWidget);
    expect(find.text('Excluir minha conta'), findsOneWidget);
  });

  testWidgets('cancelar na primeira confirmação não apaga nada', (tester) async {
    await tester.pumpWidget(_app(repo));
    await _abrirExclusao(tester);

    expect(find.text('Excluir minha conta?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(repo.exclusoes, 0);
    expect(find.text('Confirme sua senha'), findsNothing);
  });

  testWidgets('cancelar na senha não apaga nada', (tester) async {
    await tester.pumpWidget(_app(repo));
    await _abrirExclusao(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Confirme sua senha'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(repo.exclusoes, 0);
  });

  testWidgets('confirmar e informar a senha envia a exclusão com a senha digitada', (tester) async {
    await tester.pumpWidget(_app(repo));
    await _abrirExclusao(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'minhaSenha1');
    await tester.tap(find.text('Excluir tudo'));
    await tester.pumpAndSettle();

    expect(repo.exclusoes, 1);
    expect(repo.senhaRecebida, 'minhaSenha1');
  });

  testWidgets('senha vazia mostra o erro de validação e não chega ao repository', (tester) async {
    await tester.pumpWidget(_app(repo));
    await _abrirExclusao(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Excluir tudo'));
    await tester.pumpAndSettle();

    expect(find.text('Digite sua senha para confirmar.'), findsOneWidget);
    expect(repo.exclusoes, 0);
  });

  testWidgets('falha na exclusão aparece na tela e os botões voltam a funcionar', (tester) async {
    repo.respostaExclusao = const Left(AuthFailure('Senha incorreta.'));
    await tester.pumpWidget(_app(repo));
    await _abrirExclusao(tester);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'errada');
    await tester.tap(find.text('Excluir tudo'));
    await tester.pumpAndSettle();

    expect(find.text('Senha incorreta.'), findsOneWidget);
    final botao = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Excluir conta'));
    expect(botao.onPressed, isNotNull);
  });

  testWidgets('falha ao exportar mostra o motivo', (tester) async {
    await tester.pumpWidget(_app(repo));

    await tester.tap(find.text('Exportar'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível reunir seus dados.'), findsOneWidget);
  });
}
