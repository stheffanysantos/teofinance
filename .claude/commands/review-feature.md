---
description: Revisa uma feature completa contra o checklist de arquitetura, segurança, testes e UI
argument-hint: <feature>
allowed-tools: Read, Grep, Glob, Bash
---

Revise `lib/features/$ARGUMENTS/` seguindo `.claude/reviews/checklist-feature.md`:

1. Arquitetura: fluxo `presentation → domain ← data` respeitado, `domain` sem Flutter/Riverpod/Firebase/drift.
2. Riverpod: Notifiers injetados via `ref`, State único freezed por tela.
3. Segurança: nenhuma credencial fora de `flutter_secure_storage`, `firestore.rules` restringindo ao próprio usuário se a feature toca coleção nova.
4. Se a feature é `ai_assistant`: confirme isolamento total de Firestore/Storage/rede (prioridade máxima desta revisão).
5. Se a feature é `import`: confirme que o parsing nunca sai do dispositivo e falha explicitamente em perfil incompatível.
6. Se a feature é sincronizável: confirme `SyncStatus` e tratamento de falha parcial em `sync/`.
7. Testes: cobertura mínima por artefato (ver `.claude/rules/testing.md`).
8. UI: zero hardcode de tema, Modo Discreto respeitado em valores monetários.

Liste violações citando arquivo/linha e a regra específica.
