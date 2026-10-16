# Sprint 02 — Parcelamento de Cartão

> Objetivo: Usuário consegue cadastrar uma compra de cartão em N parcelas. Cada parcela aparece como transação separada no dashboard e lista, com data de vencimento distribuída pelos meses seguintes.

## Arquitetura

```
domain/
  entities/
    parcelamento.dart         # Entity nova: id, transacao_original_id, num_parcelas, etc
  repositories/
    parcelamento_repository.dart    # Interface
    
data/
  models/
    parcelamento_model.dart
  datasources/
    parcelamento_remote_data_source.dart
    parcelamento_local_data_source.dart   # Drift queries
  repositories/
    parcelamento_repository_impl.dart
    
presentation/
  parcelamento_providers.dart       # DI Riverpod
  screens/
    parcelar_transacao_screen.dart  # Modal: "Parcelar esta compra?"
  widgets/
    parcelamento_indicator.dart      # Badge: "Parcela 3/12"
```

## Tarefas Detalhadas

### 1. Expandir Schema Drift (data/app_database.dart)
```dart
// Adicionar tabela parcelamento
@DataClassName('ParcelamentoData')
class Parcelamentos extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get transacaoOriginalId => text()();  // FK → transacoes
  RealColumn get totalOriginal => real()();
  IntColumn get numeroParcelas => integer()();
  DateTimeColumn get dataPrimeiraParc => dateTime()();
  DateTimeColumn get dataCriacao => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [[userId, id]];
}

// Expandir Transacoes
class Transacoes {
  // Novos campos:
  RealColumn get valorParcela => real().nullable()();
  IntColumn get numeroParcela => integer().nullable()();  // 1, 2, 3...
  TextColumn get parcelamentoId => text().nullable()();    // FK
  BoolColumn get ehParcela => boolean()();
  TextColumn get statusParcela => text().nullable()();     // pendente | pago | atrasado
}
```

**Rotar versão Drift**: v1 → v2

### 2. Entities (domain/)
```dart
// parcelamento.dart
@freezed
class Parcelamento with _$Parcelamento {
  const factory Parcelamento({
    required String id,
    required String userId,
    required String transacaoOriginalId,
    required double totalOriginal,
    required int numeroParcelas,
    required DateTime dataPrimeiraParc,
    required DateTime dataCriacao,
  }) = _Parcelamento;
}

// Expandir transacao.dart
@freezed
class Transacao with _$Transacao {
  const factory Transacao({
    // ... campos existentes ...
    double? valorParcela,
    int? numeroParcela,
    String? parcelamentoId,
    @Default(false) bool ehParcela,
    String? statusParcela,
  }) = _Transacao;
}
```

### 3. Repositories
```dart
// parcelamento_repository.dart (abstract)
abstract class ParcelamentoRepository {
  Future<Either<Failure, Parcelamento>> criarParcelamento(
    String transacaoId,
    int numeroParcelas,
    DateTime dataPrimeira,
  );
  
  Future<Either<Failure, List<Parcelamento>>> listarPorUsuario(String userId);
  Future<Either<Failure, void>> deletarParcelamento(String parcelamentoId);
}

// parcelamento_repository_impl.dart
class ParcelamentoRepositoryImpl implements ParcelamentoRepository {
  final ParcelamentoRemoteDataSource _remote;
  final ParcelamentoLocalDataSource _local;
  
  @override
  Future<Either<Failure, Parcelamento>> criarParcelamento(...) async {
    try {
      final parcelamento = Parcelamento(...);
      
      // 1. Cria registro de parcelamento
      await _local.salvarParcelamento(ParcelamentoModel.fromDomain(parcelamento));
      
      // 2. Cria N transações filhas
      for (int i = 1; i <= numeroParcelas; i++) {
        final dataVencimento = dataPrimeira.add(Duration(days: 30 * (i - 1)));
        final valorParcela = transacao.valor / numeroParcelas;
        
        final transacaoFilha = Transacao(
          id: const Uuid().v4(),
          descricao: '${transacao.descricao} (${i}/$numeroParcelas)',
          valor: valorParcela,
          categoria: transacao.categoria,
          parcelamentoId: parcelamento.id,
          numeroParcela: i,
          ehParcela: true,
          dataTransacao: dataVencimento,
          statusParcela: 'pendente',
          syncStatus: SyncStatus.pendingCreate,
        );
        
        await _local.salvarTransacao(TransacaoModel.fromDomain(transacaoFilha));
      }
      
      // 3. Marca transação original como "pai"
      await _local.marcarComoParcelada(transacaoId, parcelamento.id);
      
      // 4. Sync offline
      return Right(parcelamento);
    } catch (e) {
      return Left(_traduzirException(e));
    }
  }
}
```

### 4. UseCase
```dart
// criar_parcelamento_usecase.dart
class CriarParcelamentoUseCase extends UseCase<Parcelamento, CriarParcelamentoParams> {
  final ParcelamentoRepository repository;
  
  CriarParcelamentoUseCase(this.repository);
  
  @override
  Future<Either<Failure, Parcelamento>> call(CriarParcelamentoParams params) async {
    // Validações
    if (params.numeroParcelas < 2 || params.numeroParcelas > 12) {
      return Left(ValidationFailure('Entre 2 e 12 parcelas'));
    }
    
    return repository.criarParcelamento(
      params.transacaoId,
      params.numeroParcelas,
      params.dataPrimeira,
    );
  }
}

class CriarParcelamentoParams {
  final String transacaoId;
  final int numeroParcelas;
  final DateTime dataPrimeira;
  
  CriarParcelamentoParams({...});
}
```

### 5. Notifier (Riverpod)
```dart
// parcelamento_notifier.dart
@riverpod
class ParcelamentoNotifier extends _$ParcelamentoNotifier {
  late ParcelamentoRepository _repository;
  
  @override
  Future<List<Parcelamento>> build() async {
    _repository = ref.watch(parcelamentoRepositoryProvider);
    final userId = ref.watch(userIdProvider);
    
    final result = await _repository.listarPorUsuario(userId);
    return result.fold(
      (failure) => throw failure,
      (parcelamentos) => parcelamentos,
    );
  }
  
  Future<void> criarParcelamento(
    String transacaoId,
    int numeroParcelas,
    DateTime dataPrimeira,
  ) async {
    state = const AsyncValue.loading();
    
    final usecase = ref.read(criarParcelamentoUsecaseProvider);
    final result = await usecase(CriarParcelamentoParams(...));
    
    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (parcelamento) {
        state = AsyncValue.data([...?state.value, parcelamento]);
      },
    );
  }
}
```

### 6. Screens & Widgets
```dart
// parcelar_transacao_screen.dart (Modal)
class ParcelarTransacaoScreen extends ConsumerStatefulWidget {
  final Transacao transacao;
  
  const ParcelarTransacaoScreen({required this.transacao});
  
  @override
  ConsumerState<ParcelarTransacaoScreen> createState() => _State();
}

class _State extends ConsumerState<ParcelarTransacaoScreen> {
  late int _numeroParcelas = 2;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parcelar Compra')),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Exibir resumo da transação
            TransacaoCard(transacao: widget.transacao),
            const SizedBox(height: 24),
            
            // Slider: número de parcelas
            Text('Número de parcelas: $_numeroParcelas'),
            Slider(
              value: _numeroParcelas.toDouble(),
              min: 2,
              max: 12,
              divisions: 10,
              onChanged: (v) => setState(() => _numeroParcelas = v.toInt()),
            ),
            
            // Preview das parcelas
            Text(
              'Parcelas de ${(widget.transacao.valor / _numeroParcelas).toStringAsFixed(2)}',
              style: AppTextStyles.subtitle2,
            ),
            
            const Spacer(),
            
            // Botão
            AppButton(
              label: 'Parcelar',
              onPressed: () async {
                await ref.read(parcelamentoNotifierProvider.notifier).criarParcelamento(
                  widget.transacao.id,
                  _numeroParcelas,
                  DateTime.now(),
                );
                
                if (!mounted) return;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// parcelamento_indicator.dart (Widget para exibir "Parcela 3/12")
class ParcelamentoIndicator extends StatelessWidget {
  final Transacao transacao;
  
  const ParcelamentoIndicador({required this.transacao});
  
  @override
  Widget build(BuildContext context) {
    if (!transacao.ehParcela) return const SizedBox.shrink();
    
    return Chip(
      label: Text(
        'Parcela ${transacao.numeroParcela}/${parcelamento.numeroParcelas}',
        style: AppTextStyles.caption,
      ),
      backgroundColor: AppColors.primary.withOpacity(0.1),
    );
  }
}
```

### 7. Testes
```dart
// test/features/parcelamento/domain/usecases/criar_parcelamento_usecase_test.dart
void main() {
  group('CriarParcelamentoUseCase', () {
    late CriarParcelamentoUseCase usecase;
    late MockParcelamentoRepository mockRepository;
    
    setUp(() {
      mockRepository = MockParcelamentoRepository();
      usecase = CriarParcelamentoUseCase(mockRepository);
    });
    
    test('deve criar parcelamento com N parcelas', () async {
      // Arrange
      const params = CriarParcelamentoParams(...);
      final parcelamento = Parcelamento(...);
      when(() => mockRepository.criarParcelamento(...))
        .thenAnswer((_) async => Right(parcelamento));
      
      // Act
      final result = await usecase(params);
      
      // Assert
      expect(result, Right(parcelamento));
      verify(() => mockRepository.criarParcelamento(...)).called(1);
    });
    
    test('deve rejeitar se numeroParcelas < 2 ou > 12', () async {
      const params = CriarParcelamentoParams(numeroParcelas: 13, ...);
      final result = await usecase(params);
      
      expect(result, isA<Left>());
      expect(result.fold((l) => l, (_) => null), isA<ValidationFailure>());
    });
  });
}

// test/features/parcelamento/presentation/parcelamento_notifier_test.dart
void main() {
  group('ParcelamentoNotifier', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer(
        overrides: [
          parcelamentoRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });
    
    test('deve criar parcelamento e atualizar estado', () async {
      // ...
    });
  });
}
```

## Checklist de Implementação

- [ ] Expandir schema Drift (parcelamentos table, novos campos em transacoes)
- [ ] Rotar versão Drift (v1 → v2)
- [ ] Criar entities `Parcelamento` + expandir `Transacao`
- [ ] Implementar repository (remote + local)
- [ ] Implementar usecase
- [ ] Implementar Notifier Riverpod
- [ ] Tela modal: "Parcelar transação"
- [ ] Widget: `ParcelamentoIndicator`
- [ ] Expandir `TransacaoListScreen` para filtrar/exibir parcelas corretamente
- [ ] Expandir Dashboard para somar parcelas (não a transação-mãe)
- [ ] Testes unitários (repository, usecase, notifier)
- [ ] Widget tests (ParcelarTransacaoScreen, ParcelamentoIndicator)
- [ ] Atualizar Firestore rules (nova coleção `parcelamentos`)
- [ ] Sync: garantir que parcelas são sincronizadas com Firestore
- [ ] Screenshot + gif para PR

## Estimativa
~20–25h de trabalho (considerando testes).
