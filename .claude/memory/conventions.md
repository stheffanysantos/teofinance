# Convenções — Referência Rápida

> Resumo de bolso. A fonte completa é `.claude/rules/`. Se este arquivo divergir de `.claude/rules/`, `.claude/rules/` vence.

- **Arquitetura**: `presentation → domain ← data`. `domain` sem Flutter/Riverpod/firebase_*/drift. Ver `.claude/rules/architecture.md`.
- **Nomenclatura**: `snake_case.dart`, sufixo por tipo (`_notifier.dart`, `_repository.dart`, `_usecase.dart`...). Ver `.claude/rules/naming.md`.
- **Formatação**: `dart format` com `page_width: 100` (declarado em `analysis_options.yaml`).
- **Riverpod**: estado por `Notifier`/`AsyncNotifier` com `@riverpod` (code gen); nunca estado mutável solto em `StatefulWidget` para dado de domínio. Ver `.claude/rules/riverpod.md`.
- **UI**: zero hardcode de cor/espaçamento/tipografia — tudo via `app/theme/` (Material 3). Ver `.claude/rules/material3.md`.
- **Segurança**: credenciais/tokens via `flutter_secure_storage`, regras do Firestore restritivas por usuário, nunca URL/chave hardcoded fora de `--dart-define`. Ver `.claude/rules/security.md`.
- **Testes**: usecase novo sem teste = PR incompleta. Ver `.claude/rules/testing.md`.
- **Git**: Conventional Commits em português, escopo em inglês. Ver `.claude/rules/git-workflow.md`.
- **Sincronização**: decisão local×remoto é do `Repository`, nunca do `Notifier`/Screen. Ver `.claude/docs/DATABASE.md`.
- **Privacidade da IA**: `features/ai_assistant/` nunca faz chamada de rede para gerar uma resposta — só lê dados já sincronizados localmente. Qualquer exceção é uma decisão de arquitetura, registrada em `.claude/memory/decisions.md` antes de implementada.
