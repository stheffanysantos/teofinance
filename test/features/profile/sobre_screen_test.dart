import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:teofinance/core/theme/app_theme.dart';
import 'package:teofinance/features/auth/domain/repositories/auth_repository.dart';
import 'package:teofinance/features/lgpd/domain/repositories/lgpd_repository.dart';
import 'package:teofinance/features/lgpd/domain/usecases/excluir_minha_conta_usecase.dart';
import 'package:teofinance/features/lgpd/domain/usecases/exportar_meus_dados_usecase.dart';
import 'package:teofinance/features/lgpd/presentation/notifiers/meus_dados_notifier.dart';
import 'package:teofinance/features/lgpd/presentation/providers/lgpd_providers.dart';
import 'package:teofinance/features/profile/presentation/providers/app_info_provider.dart';
import 'package:teofinance/features/profile/presentation/screens/sobre_screen.dart';

class _FakeLgpd implements LgpdRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuth implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app({AsyncValue<PackageInfo>? info}) {
  return ProviderScope(
    overrides: [
      meusDadosNotifierProvider.overrideWith((ref) => MeusDadosNotifier(
            exportar: ExportarMeusDadosUseCase(repository: _FakeLgpd(), auth: _FakeAuth()),
            excluir: ExcluirMinhaContaUseCase(repository: _FakeLgpd(), auth: _FakeAuth()),
          )),
      appInfoProvider.overrideWith((ref) async {
        final valor = info;
        if (valor == null || valor.hasValue) {
          return valor?.requireValue ??
              PackageInfo(appName: 'teofinance', packageName: 'x', version: '1.2.3', buildNumber: '45');
        }
        throw valor.error!;
      }),
    ],
    child: MaterialApp(theme: AppTheme.light(), home: const SobreScreen()),
  );
}

void main() {
  testWidgets('mostra o nome e a versão real do pacote', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('TeoFinance'), findsOneWidget);
    expect(find.text('Versão 1.2.3 (45)'), findsOneWidget);
  });

  testWidgets('sem conseguir ler a versão, a tela abre sem ela', (tester) async {
    await tester.pumpWidget(_app(info: AsyncValue.error('falhou', StackTrace.empty)));
    await tester.pumpAndSettle();

    expect(find.text('TeoFinance'), findsOneWidget);
    expect(find.textContaining('Versão'), findsNothing);
  });

  testWidgets('explica as garantias de privacidade', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.textContaining('lidos só no seu aparelho'), findsOneWidget);
    expect(find.textContaining('sem enviar suas perguntas'), findsOneWidget);
    expect(find.textContaining('exportar ou apagar'), findsOneWidget);
  });

  testWidgets('Licenças de código aberto abre a página de licenças', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Licenças de código aberto'));
    await tester.pumpAndSettle();

    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('Privacidade e dados leva para a tela de direitos do titular', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacidade e dados'));
    await tester.pumpAndSettle();

    expect(find.text('Exportar meus dados'), findsOneWidget);
    expect(find.text('Excluir minha conta'), findsOneWidget);
  });
}
