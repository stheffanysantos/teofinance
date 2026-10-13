# Regra: Testes

## Cobertura mínima por tipo de artefato

| Artefato | Tipo de teste | Cobertura mínima |
|---|---|---|
| UseCase | Unit (`mocktail` no repository) | Caminho feliz + pelo menos 1 caminho de falha (`Left(Failure)`) |
| Repository impl | Unit (`mocktail` nos datasources local/remoto) | Sucesso remoto (Firestore), fallback local (sem conexão), exception traduzida em `Failure` |
| Notifier (Riverpod) | Unit (`ProviderContainer` + `mocktail` nos usecases) | Estado inicial, loading, sucesso, erro — usando `AsyncValue` |
| Screen | Widget test | loading / data / error / empty (quando aplicável) |
| Datasource remoto | Unit (fake/mock de `FirebaseFirestore`, `fake_cloud_firestore`) | Parsing de documento válido e de documento malformado |
| Parser de importação (`features/import/`) | Unit | CSV com separador `,`/`;`, encoding UTF-8/Latin-1, OFX válido, perfil incompatível (número de colunas não bate) deve falhar explicitamente |
| Usecases de `sync/` | Unit | **Obrigatório também**: sem conexão, conflito local×remoto, falha parcial (ex.: uma transação sincroniza e outra falha) |
| `features/ai_assistant/` | Unit | Garantir, via teste, que o datasource/serviço de inferência nunca é instanciado com um client de rede — ver `.claude/rules/architecture.md` |

## Convenções
- Estrutura de teste espelha `lib/` 1:1: `lib/features/transacao/domain/usecases/x.dart` → `test/features/transacao/domain/usecases/x_test.dart`.
- Nenhum teste usa `Future.delayed` para "esperar" um estado assíncrono — usar `await` direto, ou `pumpAndSettle` em widget test.
- Notifiers em teste unitário são exercitados via `ProviderContainer` com overrides (`xRepositoryProvider.overrideWithValue(mockRepository)`), **nunca** subindo um widget inteiro só para testar lógica de estado.
- Widget tests que precisam de um Notifier real usam `ProviderScope(overrides: [...])` explícito no `pumpWidget`, nunca dependendo do provider de produção.

## Mocks
- `mocktail` é a lib padrão (não `mockito`). Fakes de `Repository`/`UseCase` implementam a interface abstrata diretamente quando o comportamento é simples; `mocktail` (`Mock` + `when()`) quando o teste precisa verificar interação/chamadas.
- `fake_cloud_firestore` para testes de datasource remoto que precisam de um Firestore "de verdade" em memória, sem mockar cada chamada individualmente.

## O que não é aceitável
- PR de feature nova sem nenhum teste de usecase.
- Teste que só verifica "não lançou exception" sem verificar o valor/estado resultante.
- Golden test ausente para componente novo de `core/widgets/` (Design System) — golden test cobre light e dark, e, quando aplicável, estado "Modo Discreto" ativo/inativo (ex.: `AppAmountText`).
- Teste de `features/ai_assistant/` que não verifica a ausência de chamada de rede.

Ver `.claude/reviews/checklist-feature.md` e `.claude/templates/feature/unit_test_template.dart` / `widget_test_template.dart`.
