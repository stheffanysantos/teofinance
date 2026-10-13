# Prompt: Criar Migração de Schema (Drift)

## Quando usar
Use ao adicionar/alterar uma coluna ou tabela no cache local `drift`, ou ao adicionar uma coleção nova no Firestore que exija regra nova.

## Prompt

```
Crie a migração de schema para <descreva a mudança: nova tabela/coluna/coleção>:

1. drift: incremente `schemaVersion`, adicione a `Migrator` correspondente em `core/database/app_database.dart`, com guarda explícita (`from >= X`) cobrindo só o caminho de migração necessário — nunca uma migração destrutiva (DROP) sem justificativa explícita registrada em `.claude/memory/decisions.md`.
2. Se a mudança adiciona uma coleção nova no Firestore: adicione a regra correspondente em `firestore.rules` restringindo ao próprio usuário, e um teste de regra via emulador.
3. Documente a mudança em `.claude/docs/DATABASE.md` (schema atual) e, se for uma decisão arquitetural relevante, registre em `.claude/memory/decisions.md`.
4. Teste de migração cobrindo dado existente antes/depois da migração (não só "a migração roda sem erro").

Regras: `.claude/reviews/checklist-migration.md`.
```
