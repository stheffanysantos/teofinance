---
description: Cria um UseCase novo (uma intenção de negócio), com teste unitário cobrindo caminho feliz e falha
argument-hint: <feature> <VerboNomeUseCase>
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Crie o usecase **$ARGUMENTS** seguindo `.claude/templates/feature/usecase_template.dart`.

1. Um usecase = uma intenção de negócio (nunca um `CrudUseCase<T>` genérico).
2. Assinatura `Future<Either<Failure, T>> call(Params params)` (ou sem `Params`).
3. Não conhece Riverpod/Firestore/drift diretamente — só o contrato `Repository`.
4. Crie `test/.../<nome>_usecase_test.dart` cobrindo caminho feliz e pelo menos um caminho de falha (`Left(Failure)`), usando `mocktail` no repository mockado.
