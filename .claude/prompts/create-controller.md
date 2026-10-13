# Prompt: Criar Notifier (Riverpod)

## Quando usar
Use para criar um Notifier novo para uma tela específica dentro de uma feature já existente.

## Prompt

```
Crie o Notifier "<Nome>Notifier" para a tela <NomeTela> da feature `features/<nome>/`:

1. `@riverpod` + `AsyncNotifier`/`Notifier`, injetando o(s) usecase(s) <lista de usecases> via `ref.watch`/`ref.read` — nunca instanciando repository/datasource diretamente.
2. State freezed único (`<Nome>State`), cobrindo: <liste os casos esperados: inicial, loading, dados com <campos>, erro>.
3. Nunca ler Notifier de outra feature não relacionada — se precisar de um dado compartilhado, usar um provider em `core/providers/` ou um usecase que ambos chamem.
4. Gere teste via `ProviderContainer` com overrides mockados (`mocktail`), cobrindo estado inicial, loading, sucesso, erro.

Regras: `.claude/rules/riverpod.md`, `.claude/rules/testing.md`.
```
