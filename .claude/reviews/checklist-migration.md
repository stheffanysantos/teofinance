# Checklist — Migração de Schema (Drift) / Mudança no Firestore

- [ ] `schemaVersion` do drift incrementado, com `Migrator` guardado por versão de origem (`from >= X`).
- [ ] Nenhuma migração destrutiva (DROP/perda de dado) sem decisão explícita registrada em `.claude/memory/decisions.md`.
- [ ] Se nova coleção no Firestore: regra correspondente em `firestore.rules`, restringindo ao próprio usuário.
- [ ] Teste de migração cobrindo dado existente antes/depois (não só "a migração roda sem erro").
- [ ] Teste de `firestore.rules` via emulador para a coleção nova/alterada.
- [ ] `.claude/docs/DATABASE.md` atualizado com o schema real pós-migração.
