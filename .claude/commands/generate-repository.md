---
description: Cria um Repository (contrato + impl) novo, decidindo local x remoto, com datasources separados
argument-hint: <feature> <nome-da-entidade>
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Crie o repository de **$ARGUMENTS** seguindo `.claude/templates/feature/repository_template.dart` e `repository_impl_template.dart`.

1. `domain/repositories/<nome>_repository.dart` — contrato abstrato, métodos retornando `Either<Failure, T>`.
2. `data/datasources/<nome>_remote_data_source.dart` — único ponto de acesso ao Firestore/Storage para esta entidade.
3. `data/datasources/<nome>_local_data_source.dart` — único ponto de acesso às tabelas `drift` para esta entidade.
4. `data/repositories/<nome>_repository_impl.dart` — decide local×remoto (Firestore é fonte de verdade, ver `.claude/memory/decisions.md` decisão 0001), traduz toda exception em `Failure` tipado.
5. Se a entidade é sincronizável, implemente `sincronizarPendentes()` com tratamento de falha parcial, e aplique `.claude/reviews/checklist-repository.md` antes de considerar pronto.
6. Gere testes cobrindo sucesso remoto, fallback local offline e tradução de exception em Failure.
