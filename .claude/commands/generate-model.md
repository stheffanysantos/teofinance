---
description: Cria um Model (DTO) novo com fromJson/toJson e conversão toEntity()/fromEntity(), a partir de uma entity já existente
argument-hint: <feature> <nome-da-entidade>
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Crie o model **$ARGUMENTS** seguindo `.claude/templates/feature/model_template.dart`.

1. Confirme que a entity correspondente já existe em `domain/entities/` — se não existir, sugira criá-la primeiro.
2. Gere `data/models/<nome>_model.dart` (`@freezed` + `@JsonSerializable`), com `fromJson`/`toJson` gerados e extensions `toEntity()`/`fromEntity()` manuais, mapeando os nomes de campo exatos de um documento Firestore.
3. Nunca inclua regra de negócio no model — só campos de serialização e a conversão.
4. Se o campo do Firestore tem nome diferente do campo da entidade, documente o mapeamento em comentário no ponto da conversão.
5. Rode `dart run build_runner build --delete-conflicting-outputs` ao final.
