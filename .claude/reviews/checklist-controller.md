# Checklist — Novo Notifier (Riverpod)

- [ ] `@riverpod` com geração de código, não API legada (`StateNotifierProvider` manual).
- [ ] Usecase(s) injetado(s) via `ref.watch`/`ref.read`, nunca instanciado diretamente.
- [ ] Um único `State` freezed por Notifier, cobrindo todos os casos (inicial/loading/dados/erro/vazio quando aplicável).
- [ ] `AsyncNotifier`/`AsyncValue` usado para qualquer estado dependente de I/O.
- [ ] Reflete a tela/fluxo específico, não a feature inteira.
- [ ] `autoDispose` deliberado e comentado quando aplicável.
- [ ] Teste via `ProviderContainer` com overrides mockados, cobrindo estado inicial, loading, sucesso, erro.
