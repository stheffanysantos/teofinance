# Regra: Nomenclatura

## Imports
- **Sempre import absoluto** (`package:teofinance/...`), nunca relativo profundo (`../../../../`).
- Único caso de import relativo permitido: `part '<arquivo>.dart'`/`part of` (ex.: `part 'transacao.freezed.dart'`, `part 'transacao.g.dart'`).
- `analysis_options.yaml` habilita `always_use_package_imports` e `avoid_relative_lib_imports` — import relativo fora de um `part` falha em `dart analyze --fatal-infos` e bloqueia commit (ver `.claude/rules/git-workflow.md`).

## Arquivos
- Sempre `snake_case.dart`.
- Sufixo reflete o tipo: `_screen.dart`, `_widget.dart`, `_notifier.dart`, `_providers.dart`, `_state.dart`, `_repository.dart`, `_repository_impl.dart`, `_usecase.dart`, `_model.dart`, `_service.dart`, `_remote_data_source.dart`, `_local_data_source.dart`, `_test.dart`.
- Um arquivo = uma classe pública principal (exceção: `_state.dart` pode conter o union freezed inteiro de uma tela).

## Classes

| Tipo | Padrão | Exemplo |
|---|---|---|
| Entity (domain) | `PascalCase`, sem sufixo | `Transacao`, `PerfilBanco`, `Meta`, `Orcamento` |
| Model (data/DTO) | `PascalCase` + `Model` | `TransacaoModel`, `PerfilBancoModel` |
| Repository (contrato) | `PascalCase` + `Repository` (abstract) | `TransacaoRepository` |
| Repository (impl) | `PascalCase` + `RepositoryImpl` | `TransacaoRepositoryImpl` |
| UseCase | Verbo + Nome + `UseCase` | `ImportarExtratoUseCase`, `RegistrarMetaUseCase`, `SincronizarPendenciasUseCase` |
| Notifier (Riverpod) | `PascalCase` + `Notifier` | `TransacaoListNotifier`, `DashboardNotifier` |
| State | `PascalCase` + `State` (freezed) | `TransacaoListState` |
| Screen | `PascalCase` + `Screen` | `TransacaoListScreen`, `ImportarExtratoScreen` |
| Widget de feature | `PascalCase`, descritivo | `TransacaoCard`, `ProgressoMetaBar` |
| Widget de Design System | Prefixo `App` | `AppButton`, `AppCurrencyField`, `AppEmptyState` |
| Service (`core/`) | `PascalCase` + `Service` | `BiometriaService`, `SecureStorageService`, `GemmaInferenceService` |
| Failure | `PascalCase` + `Failure` | `NetworkFailure`, `ImportacaoFailure`, `SyncFailure`, `AuthFailure` |
| Exception (interna) | `PascalCase` + `Exception` | `PerfilBancoIncompativelException` |

## Notifiers e providers (Riverpod)
- Nome do Notifier reflete a tela/fluxo, não a feature inteira: `TransacaoListNotifier` (lista), `TransacaoFormNotifier` (formulário) — nunca um `TransacaoNotifier` genérico cobrindo lista+formulário+edição ao mesmo tempo.
- `Provider`/`Notifier` family (parametrizado) só quando há múltiplas instâncias simultâneas reais (ex.: `metaDetailProvider(metaId)`) — documentar o motivo em comentário.

## Rotas (go_router ou equivalente)
- Path constants em `app_routes.dart`, `kebab-case`, prefixado pela feature: `/transacoes`, `/metas/:id`, `/importar-extrato`.
- Nome da rota usa sempre a constante — nunca string literal solta espalhada pelo código.

## Pastas
- Sempre `snake_case`, plural quando representa coleção (`transacoes`), singular quando representa conceito único (`auth`, `dashboard`, `sync`, `ai_assistant`).

## Testes
- Espelham exatamente o caminho do arquivo testado: `lib/features/transacao/domain/usecases/importar_extrato_usecase.dart` → `test/features/transacao/domain/usecases/importar_extrato_usecase_test.dart`.

## Proibido
- Abreviações obscuras como nome de classe/variável pública (`mgr`, `svc`, `ntf`, `tmp`).
- Nomes que descrevem implementação em vez de intenção (`FetchDataUseCase`, `HandleStuff`, `DoAction`).
- Sufixo duplicado/redundante (`TransacaoModelModel`, `TransacaoScreenWidget`).
- Misturar idioma de domínio dentro do mesmo conceito (ex.: `dataTransacao` em um lugar e `transaction_date` em outro para a mesma coisa) — este projeto usa **português para nomes de domínio de negócio** (`Transacao`, `PerfilBanco`, `Meta`) e **inglês para termos técnicos genéricos** (`Repository`, `UseCase`, `Notifier`), de forma consistente em todo o projeto.
