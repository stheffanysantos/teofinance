---
description: Cria uma feature completa (domain/data/presentation) do zero, seguindo a arquitetura Clean + Riverpod do TeoFinance
argument-hint: <nome-da-feature>
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Crie a feature **$ARGUMENTS** completa em `lib/features/$ARGUMENTS/`, seguindo exatamente `.claude/templates/feature/FEATURE_STRUCTURE.md`:

1. `domain/entities/` — entidade(s) de negócio pura(s), sem dependência externa.
2. `domain/repositories/` — contrato abstrato, retorno `Either<Failure, T>`.
3. `domain/usecases/` — um usecase por intenção de negócio.
4. `data/models/` — Model (@freezed + @JsonSerializable) com `toEntity()`/`fromEntity()`.
5. `data/datasources/` — remoto (Firestore) e local (drift) em arquivos separados.
6. `data/repositories/` — `RepositoryImpl`, decidindo local×remoto (Firestore como fonte de verdade).
7. `presentation/providers/` — `<feature>_providers.dart`, injeção via `ref`.
8. `presentation/notifiers/` + `presentation/screens/` + `presentation/widgets/`.
9. Rotas em `app/routes/app_routes.dart`.
10. Testes (unit para usecases/repository/notifiers, widget test por screen).

Releia antes de codar: `.claude/rules/architecture.md`, `.claude/rules/naming.md`, `.claude/rules/riverpod.md`, `.claude/rules/material3.md`, `.claude/rules/testing.md`. Se a feature envolver entidade sincronizável, siga `.claude/docs/DATABASE.md` e aplique o padrão de `SyncStatus`. Ao final, rode `dart run build_runner build --delete-conflicting-outputs` e atualize `.claude/plans/Features.md`.
