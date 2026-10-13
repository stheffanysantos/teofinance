---
description: Cria uma Screen nova consumindo um Notifier via Riverpod, com estados loading/data/error/empty
argument-hint: <feature> <NomeScreen>
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Crie a screen **$ARGUMENTS** seguindo `.claude/templates/feature/screen_template.dart`.

1. `ConsumerWidget`/`ConsumerStatefulWidget` consumindo o Notifier da feature via `ref.watch`.
2. Trate explicitamente os estados `AsyncValue` (loading/data/error) e o caso vazio (`AppEmptyState`) quando aplicável.
3. Zero hardcode de cor/espaçamento/tipografia — tudo via `app/theme/` (ver `.claude/rules/material3.md`). Se exibir valor monetário, use `AppAmountText` (respeita Modo Discreto).
4. Adicione a rota em `app/routes/app_routes.dart`.
5. Gere widget test cobrindo loading/data/error/empty.
