---
description: Cria um Notifier (Riverpod) novo para uma tela, com State freezed e teste via ProviderContainer
argument-hint: <feature> <NomeTela>
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Crie o Notifier de **$ARGUMENTS** seguindo `.claude/templates/feature/notifier_template.dart` e `state_template.dart`.

1. `presentation/notifiers/<nome>_notifier.dart` — `@riverpod` `Notifier`/`AsyncNotifier`, injeção de usecases via `ref.watch`/`ref.read` (nunca instanciado diretamente — ver `.claude/rules/riverpod.md`).
2. `presentation/notifiers/<nome>_state.dart` — único `State` freezed (union de casos: inicial, loading, dados, erro).
3. Reflita a tela/fluxo específico, nunca a feature inteira (ex.: `TransacaoListNotifier`, não `TransacaoNotifier` genérico).
4. Gere teste via `ProviderContainer` com overrides do(s) usecase(s) mockado(s) via `mocktail`, cobrindo estado inicial, loading, sucesso e erro.
5. Rode `dart run build_runner build --delete-conflicting-outputs` ao final.
