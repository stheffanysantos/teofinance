# Sprint 03 — Reconciliação de Transações

> **Status: entregue (2026-10-19).** O desenho abaixo é o plano original; o implementado difere nestes pontos:
> - **Não há sync da reconciliação** (nem datasource remoto, nem `userId`): o extrato nunca sai do aparelho (ver `.claude/rules/security.md`). As tabelas `ExtratoLinhasTable` e `ReconciliationMatchesTable` são só locais.
> - O matching é por **valor + data** (+ similaridade de descrição como reforço), com limiar de 0,95 para `auto_matched`; o resto vira candidato `unmatched` para o usuário aprovar ou rejeitar. Há o status extra `rejected` e o **vínculo manual** de uma linha órfã a uma transação.
> - Casos de uso em `domain/usecases/` (`FazerReconciliacao`, `AprovarMatch`, `RejeitarMatch`, `VincularManualmente`, `ObterStatusReconciliacao`); o notifier é `StateNotifier`, não `@riverpod`.
> - O Dashboard mostra o card "Reconciliação do mês"; a tela traz o relatório registrado × banco e as transações fora do extrato.
> - O matching semântico por IA depende do Gemma (decisão 0006).
> O checklist no fim deste arquivo está histórico; não o use como lista de pendências.

> Objetivo: Fim do mês, usuário importa novo extrato → App compara automaticamente transações inseridas manualmente com linhas do extrato → Exibe relatório com matches, orphans (só no extrato) e unmatched.

## Arquitetura

```
domain/
  entities/
    reconciliation.dart        # Status de reconciliação
    reconciliation_match.dart  # Match entre transacao + linha de extrato
  repositories/
    reconciliation_repository.dart
    
data/
  models/
    reconciliation_match_model.dart
  datasources/
    reconciliation_remote_data_source.dart
    reconciliation_local_data_source.dart
  repositories/
    reconciliation_repository_impl.dart
  services/
    transacao_matcher_service.dart     # Algoritmo de matching
    
presentation/
  screens/
    reconciliation_screen.dart         # Tela principal
    reconciliation_detail_screen.dart  # Detalhe de um match/conflict
  widgets/
    match_card.dart
    orphan_card.dart
  providers/
    reconciliation_providers.dart
```

## Tarefas Detalhadas

### 1. Expandir Schema Drift

```dart
// data/app_database.dart

@DataClassName('ReconciliationMatchData')
class ReconciliationMatches extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get transacaoId => text()();              // FK → transacoes
  TextColumn get linhaExtratoId => text()();          // ID da linha do extrato (último importado)
  DateTimeColumn get dataReconciliacao => dateTime()();
  TextColumn get status => text()();                  // auto_matched | manual_matched | unmatched | orphan
  RealColumn get confidence => real()();              // 0.0–1.0
  
  @override
  Set<Column> get primaryKey => {id};
}

// Expandir Transacoes
class Transacoes {
  // Novo campo:
  TextColumn get reconciliationStatus => text().nullable()();  // pendente | reconciliada | orfao
}

// Expandir Imports (já existe, mas vamos usar)
class ExtratoLinhas extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get importId => text()();                // FK → imports
  TextColumn get descricao => text()();               // "SUPERMERCADO X 123"
  RealColumn get valor => real()();
  DateTimeColumn get data => dateTime()();
  TextColumn get tipo => text()();                    // D | C (débito/crédito)
  
  // Extra para ajudar em matching:
  TextColumn get nomeBancoOriginal => text()();       // "MERCADO X" como veio do banco
  
  @override
  Set<Column> get primaryKey => {id};
}
```

**Rotar versão Drift**: v2 → v3

### 2. Entities (domain/)

```dart
// reconciliation_match.dart
@freezed
class ReconciliationMatch with _$ReconciliationMatch {
  const factory ReconciliationMatch({
    required String id,
    required String userId,
    required String transacaoId,        // O que o usuário inseriu
    required String linhaExtratoId,     // Linha do extrato
    required DateTime dataReconciliacao,
    required String status,             // auto_matched | manual_matched | unmatched | orphan
    required double confidence,         // 0.0–1.0
  }) = _ReconciliationMatch;
}

// reconciliation_status.dart
enum ReconciliationStatus {
  pendente,      // Transação criada, aguardando reconciliação
  reconciliada,  // Bateu com o extrato
  orfao,         // Nunca apareceu no extrato (pode estar pendente ou perdida)
}
```

### 3. TransacaoMatcher Service

O algoritmo de matching automático:

```dart
// data/services/transacao_matcher_service.dart
class TransacaoMatcherService {
  /// Algoritmo de matching: valor + data (simples mas eficaz)
  /// 
  /// Regras:
  /// - Valor exato + data ±2 dias = MATCH 100% (confidence: 1.0)
  /// - Valor ±5% + data ±3 dias = POSSÍVEL MATCH (confidence: 0.7–0.9)
  /// - Sem correspondência = UNMATCHED
  
  List<(Transacao, ExtratoLinha, double)> encontrarMatches({
    required List<Transacao> transacoesUsuario,
    required List<ExtratoLinha> linhasExtrato,
  }) {
    final matches = <(Transacao, ExtratoLinha, double)>[];
    
    for (final transacao in transacoesUsuario) {
      // Se já foi reconciliada ou é orfã, skip
      if (transacao.reconciliationStatus == 'reconciliada' || 
          transacao.reconciliationStatus == 'orfao') {
        continue;
      }
      
      for (final linha in linhasExtrato) {
        final confidence = _calcularConfianca(transacao, linha);
        
        if (confidence >= 0.7) {  // Threshold mínimo
          matches.add((transacao, linha, confidence));
        }
      }
    }
    
    // Ordenar por confiança decrescente
    matches.sort((a, b) => b.$3.compareTo(a.$3));
    
    return matches;
  }
  
  double _calcularConfianca(Transacao t, ExtratoLinha l) {
    double score = 0.0;
    
    // 1. Valor: 50% do score
    final diferencaValor = (t.valor - l.valor).abs();
    final percentualDiferenca = diferencaValor / t.valor;
    
    if (percentualDiferenca == 0.0) {
      score += 0.5;  // Valor exato
    } else if (percentualDiferenca <= 0.05) {
      score += 0.5 * (1 - percentualDiferenca / 0.05);  // Até 5%
    }
    
    // 2. Data: 50% do score
    final diferencaDias = t.dataTransacao.difference(l.data).inDays.abs();
    
    if (diferencaDias == 0) {
      score += 0.5;  // Mesma data
    } else if (diferencaDias <= 2) {
      score += 0.5 * (1 - diferencaDias / 2);
    } else if (diferencaDias <= 3) {
      score += 0.25;  // Tolerância maior = menos confiança
    }
    
    return score.clamp(0.0, 1.0);
  }
}
```

### 4. Repository

```dart
// domain/repositories/reconciliation_repository.dart
abstract class ReconciliationRepository {
  /// Faz matching automático entre transações do usuário e linhas do extrato
  Future<Either<Failure, List<ReconciliationMatch>>> fazerMatching({
    required String userId,
    required List<Transacao> transacoes,
    required List<ExtratoLinha> linhasExtrato,
  });
  
  /// Aprova um match manualmente
  Future<Either<Failure, void>> aprovarMatch(String matchId);
  
  /// Rejeita um match e marca como unmatched
  Future<Either<Failure, void>> rejeitarMatch(String matchId);
  
  /// Cria um match manual (usuário liga dois manualmente)
  Future<Either<Failure, ReconciliationMatch>> criarMatchManual(
    String transacaoId,
    String linhaExtratoId,
  );
  
  /// Lista status de reconciliação do período
  Future<Either<Failure, ReconciliationStatus>> obterStatusReconciliacao({
    required String userId,
    required DateTime dataInicio,
    required DateTime dataFim,
  });
}

// data/repositories/reconciliation_repository_impl.dart
class ReconciliationRepositoryImpl implements ReconciliationRepository {
  final ReconciliationRemoteDataSource _remote;
  final ReconciliationLocalDataSource _local;
  final TransacaoMatcherService _matcher;
  
  @override
  Future<Either<Failure, List<ReconciliationMatch>>> fazerMatching({...}) async {
    try {
      // 1. Encontra matches usando o serviço
      final matches = _matcher.encontrarMatches(
        transacoesUsuario: transacoes,
        linhasExtrato: linhasExtrato,
      );
      
      // 2. Cria registros de ReconciliationMatch
      final recordados = <ReconciliationMatch>[];
      for (final (transacao, linha, confidence) in matches) {
        final match = ReconciliationMatch(
          id: const Uuid().v4(),
          userId: userId,
          transacaoId: transacao.id,
          linhaExtratoId: linha.id,
          dataReconciliacao: DateTime.now(),
          status: confidence == 1.0 ? 'auto_matched' : 'manual_matched',
          confidence: confidence,
        );
        
        await _local.salvarMatch(ReconciliationMatchModel.fromDomain(match));
        recordados.add(match);
        
        // 3. Atualiza status da transação
        await _local.atualizarStatusTransacao(
          transacao.id,
          'reconciliada',
        );
      }
      
      // 4. Identifica orphans (linhas do extrato sem correspondência)
      final linhasMatched = matches.map((m) => m.$2.id).toSet();
      final orphans = linhasExtrato
          .where((l) => !linhasMatched.contains(l.id))
          .toList();
      
      for (final linha in orphans) {
        final match = ReconciliationMatch(
          id: const Uuid().v4(),
          userId: userId,
          transacaoId: '',  // Sem transação correspondente
          linhaExtratoId: linha.id,
          dataReconciliacao: DateTime.now(),
          status: 'orphan',
          confidence: 0.0,
        );
        
        await _local.salvarMatch(ReconciliationMatchModel.fromDomain(match));
        recordados.add(match);
      }
      
      return Right(recordados);
    } catch (e) {
      return Left(_traduzirException(e));
    }
  }
  
  // ... outros métodos ...
}
```

### 5. UseCase

```dart
// domain/usecases/fazer_reconciliacao_usecase.dart
class FazerReconciliacao UseCase
    extends UseCase<List<ReconciliationMatch>, FazerReconciliacaoParams> {
  final ReconciliationRepository repository;
  final TransacaoRepository transacaoRepository;
  final ImportRepository importRepository;
  
  FazerReconciliacao UseCase(this.repository, ...);
  
  @override
  Future<Either<Failure, List<ReconciliationMatch>>> call(
    FazerReconciliacaoParams params,
  ) async {
    // 1. Busca transações do período
    final transacoesResult =
        await transacaoRepository.listarPorPeriodo(params.userId, ...);
    
    // 2. Busca linhas do extrato importado
    final linhasResult = await importRepository.obterLinhasDoUltimoExtrato(
      params.userId,
    );
    
    // 3. Combina e faz matching
    return transacoesResult.fold(
      (f) => Left(f),
      (transacoes) => linhasResult.fold(
        (f) => Left(f),
        (linhas) => repository.fazerMatching(
          userId: params.userId,
          transacoes: transacoes,
          linhasExtrato: linhas,
        ),
      ),
    );
  }
}

class FazerReconciliacaoParams {
  final String userId;
  final DateTime dataInicio;
  final DateTime dataFim;
  
  FazerReconciliacaoParams({...});
}
```

### 6. Notifier (Riverpod)

```dart
// presentation/reconciliation_notifier.dart
@riverpod
class ReconciliationNotifier extends _$ReconciliationNotifier {
  late ReconciliationRepository _repository;
  
  @override
  Future<List<ReconciliationMatch>> build() async {
    _repository = ref.watch(reconciliationRepositoryProvider);
    final userId = ref.watch(userIdProvider);
    final dataInicio = ref.watch(dataInicioReconciliacaoProvider);
    final dataFim = ref.watch(dataFimReconciliacaoProvider);
    
    final usecase = ref.read(fazerReconciliacaoUsecaseProvider);
    final result = await usecase(FazerReconciliacaoParams(
      userId: userId,
      dataInicio: dataInicio,
      dataFim: dataFim,
    ));
    
    return result.fold(
      (failure) => throw failure,
      (matches) => matches,
    );
  }
  
  Future<void> aprovarMatch(String matchId) async {
    // Otimistic update
    final current = state.value ?? [];
    state = AsyncValue.data([
      ...current.map((m) => m.id == matchId
          ? m.copyWith(status: 'manual_matched')
          : m),
    ]);
    
    final result = await _repository.aprovarMatch(matchId);
    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (_) => null,  // Mantém otimistic update
    );
  }
  
  // ... rejeitarMatch, criarMatchManual, etc ...
}
```

### 7. Screens

```dart
// reconciliation_screen.dart
class ReconciliationScreen extends ConsumerWidget {
  const ReconciliationScreen();
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(reconciliationNotifierProvider);
    
    return matchesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: AppLoadingIndicator()),
      ),
      error: (error, st) => Scaffold(
        body: AppErrorState(
          error: error.toString(),
          onRetry: () => ref.refresh(reconciliationNotifierProvider),
        ),
      ),
      data: (matches) {
        // Agrupar matches por status
        final matched = matches.where((m) => m.status.contains('matched')).toList();
        final orphans = matches.where((m) => m.status == 'orphan').toList();
        final unmatched = matches.where((m) => m.status == 'unmatched').toList();
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Reconciliar Extrato'),
          ),
          body: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              // Resumo
              _ResumoReconciliacao(
                total: matches.length,
                matched: matched.length,
                orphans: orphans.length,
                unmatched: unmatched.length,
              ),
              
              const SizedBox(height: 24),
              
              // Matches (automáticos)
              if (matched.isNotEmpty) ...[
                Text(
                  '✅ Reconciliadas (${matched.length})',
                  style: AppTextStyles.headline6,
                ),
                ...matched.map((m) => MatchCard(match: m)),
              ],
              
              const SizedBox(height: 24),
              
              // Orphans (só no extrato)
              if (orphans.isNotEmpty) ...[
                Text(
                  '⚠️ Só no extrato (${orphans.length})',
                  style: AppTextStyles.headline6,
                ),
                ...orphans.map((m) => OrphanCard(match: m)),
              ],
              
              const SizedBox(height: 24),
              
              // Unmatched (só foi inserida)
              if (unmatched.isNotEmpty) ...[
                Text(
                  '❌ Não reconciliadas (${unmatched.length})',
                  style: AppTextStyles.headline6,
                ),
                ...unmatched.map((m) => UnmatchedCard(match: m)),
              ],
              
              const SizedBox(height: 24),
              
              // Botão: Salvar reconciliação
              AppButton(
                label: 'Finalizar Reconciliação',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reconciliação salva!')),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResumoReconciliacao extends StatelessWidget {
  final int total;
  final int matched;
  final int orphans;
  final int unmatched;
  
  const _ResumoReconciliacao({...});
  
  @override
  Widget build(BuildContext context) {
    final percentualReconciliado = (matched / total * 100).toStringAsFixed(0);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(
              '$percentualReconciliado% Reconciliado',
              style: AppTextStyles.headline5.copyWith(
                color: AppColors.income,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem('Matches', matched),
                _StatItem('Orphans', orphans),
                _StatItem('Pendentes', unmatched),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int valor;
  
  const _StatItem(this.label, this.valor);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor.toString(), style: AppTextStyles.headline5),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
```

### 8. Testes

```dart
// test/features/reconciliation/domain/usecases/fazer_reconciliacao_usecase_test.dart
void main() {
  group('FazerReconciliacao UseCase', () {
    test('deve encontrar matches automáticos (valor exato + data próxima)', () async {
      // Arrange
      final transacao = Transacao(
        id: '1',
        valor: 100.0,
        dataTransacao: DateTime(2026, 10, 15),
        ...
      );
      final linhaExtrato = ExtratoLinha(
        id: 'l1',
        valor: 100.0,
        data: DateTime(2026, 10, 15),
        ...
      );
      
      // Act
      final matches = matcherService.encontrarMatches([transacao], [linhaExtrato]);
      
      // Assert
      expect(matches, hasLength(1));
      expect(matches.first.$3, equals(1.0));  // 100% confidence
    });
    
    test('deve identificar orphans (linhas do extrato sem transação)', () async {
      // ...
    });
    
    test('deve marcar como unmatched quando não há correspondência', () async {
      // ...
    });
  });
}
```

## Checklist de Implementação

- [ ] Expandir schema Drift (reconciliation_matches table, novos campos)
- [ ] Rotar versão Drift (v2 → v3)
- [ ] Criar entities `ReconciliationMatch` + `ReconciliationStatus`
- [ ] Implementar `TransacaoMatcherService` (algoritmo de matching)
- [ ] Implementar repository (remote + local)
- [ ] Implementar usecase
- [ ] Implementar Notifier Riverpod
- [ ] Tela principal: `ReconciliationScreen`
- [ ] Widgets: `MatchCard`, `OrphanCard`, `UnmatchedCard`
- [ ] Testes unitários (matcher, repository, usecase)
- [ ] Widget tests (ReconciliationScreen)
- [ ] Atualizar Firestore rules (nova coleção `reconciliation_matches`)
- [ ] Sync: garantir que matches são sincronizados
- [ ] Integração com Dashboard (exibir status "X% reconciliado")
- [ ] Screenshot + gif para PR

## Estimativa
~25–30h de trabalho (matching algorithm + testes são críticos).
