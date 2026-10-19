import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../reconciliation/presentation/providers/reconciliation_providers.dart';
import '../../../transacao/presentation/providers/transacao_providers.dart';
import '../../data/datasources/perfil_banco_local_datasource.dart';
import '../../data/repositories/import_repository_impl.dart';
import '../../data/repositories/perfil_banco_repository_impl.dart';
import '../../data/services/bank_profile_matcher.dart';
import '../../data/services/csv_dialect_detector.dart';
import '../../data/services/csv_table_parser.dart';
import '../../data/services/valor_celula_parser.dart';
import '../../domain/repositories/import_repository.dart';
import '../../domain/repositories/perfil_banco_repository.dart';
import '../../domain/usecases/detectar_duplicatas_usecase.dart';
import '../../domain/usecases/importar_extrato_usecase.dart';
import '../../domain/usecases/salvar_perfil_banco_usecase.dart';

/// Infraestrutura de composição (DI) — ver `.claude/rules/architecture.md`.
final csvDialectDetectorProvider = Provider((ref) => CsvDialectDetector());
final csvTableParserProvider = Provider((ref) => CsvTableParser());
final bankProfileMatcherProvider = Provider((ref) => BankProfileMatcher());
final valorCelulaParserProvider = Provider((ref) => ValorCelulaParser());

final perfilBancoLocalDataSourceProvider = Provider((ref) {
  return PerfilBancoLocalDataSource(ref.watch(appDatabaseProvider));
});

final perfilBancoRepositoryProvider = Provider<PerfilBancoRepository>((ref) {
  return PerfilBancoRepositoryImpl(
    ref.watch(perfilBancoLocalDataSourceProvider),
    ref.watch(bankProfileMatcherProvider),
  );
});

final importRepositoryProvider = Provider<ImportRepository>((ref) {
  return ImportRepositoryImpl(
    detector: ref.watch(csvDialectDetectorProvider),
    parser: ref.watch(csvTableParserProvider),
    matcher: ref.watch(bankProfileMatcherProvider),
    valorParser: ref.watch(valorCelulaParserProvider),
    perfilBancoRepository: ref.watch(perfilBancoRepositoryProvider),
  );
});

final importarExtratoUseCaseProvider = Provider((ref) {
  return ImportarExtratoUseCase(ref.watch(importRepositoryProvider));
});

final salvarPerfilBancoUseCaseProvider = Provider((ref) {
  return SalvarPerfilBancoUseCase(ref.watch(perfilBancoRepositoryProvider));
});

final detectarDuplicatasUseCaseProvider = Provider((ref) {
  return DetectarDuplicatasUseCase(
    transacoes: ref.watch(transacaoRepositoryProvider),
    reconciliacao: ref.watch(reconciliationRepositoryProvider),
  );
});
