import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/app_database.dart';
import 'core/providers/core_providers.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/notificacao_service.dart';
import 'core/theme/app_theme.dart';
import 'demo/auth_repository_demo.dart';
import 'demo/dados_demo.dart';
import 'demo/lgpd_repository_demo.dart';
import 'demo/modo_demo.dart';
import 'demo/moldura_demo.dart';
import 'features/ai_assistant/data/services/gerenciador_modelo_indisponivel.dart';
import 'features/ai_assistant/data/services/inferencia_local_indisponivel.dart';
import 'features/ai_assistant/presentation/providers/ai_assistant_providers.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/auth/presentation/screens/auth_gate.dart';
import 'features/lgpd/data/datasources/lgpd_local_data_source.dart';
import 'features/lgpd/presentation/providers/lgpd_providers.dart';
import 'features/sync/presentation/providers/sync_providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kModoDemo) {
    final db = AppDatabase();
    await semearDadosDemo(db);
    runApp(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authRepositoryProvider.overrideWithValue(AuthRepositoryDemo()),
          syncEngineProvider.overrideWithValue(null),
          // O modelo de IA (LiteRT) não roda no navegador: só as respostas por regras.
          inferenciaLocalProvider.overrideWithValue(const InferenciaLocalIndisponivel()),
          gerenciadorModeloProvider.overrideWithValue(const GerenciadorModeloIndisponivel()),
          lgpdRepositoryProvider.overrideWith(
            (ref) => LgpdRepositoryDemo(LgpdLocalDataSource(db, ref.watch(secureStorageProvider))),
          ),
          notificacaoServiceProvider.overrideWithValue(const NotificacaoServiceNulo()),
        ],
        child: const TeoFinanceApp(),
      ),
    );
    return;
  }

  final firebaseApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Motor do assistente local. Se falhar (aparelho sem suporte), o app segue e o
  // assistente responde só pelas regras.
  try {
    await FlutterEdgeAi.initialize(inferenceEngines: [LiteRtLmEngine()]);
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [firebaseAppProvider.overrideWithValue(firebaseApp)],
      child: const TeoFinanceApp(),
    ),
  );
}

class TeoFinanceApp extends ConsumerWidget {
  const TeoFinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'TeoFinance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      builder: kModoDemo ? (context, child) => MolduraDemo(child: child ?? const SizedBox.shrink()) : null,
      home: const AuthGate(),
    );
  }
}
