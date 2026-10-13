# Banco de Dados — Firestore (fonte de verdade) + Drift (cache offline)

## Modelo geral
Firestore é a fonte de verdade (ver decisão 0001). Drift é cache de leitura + fila de escrita pendente. Toda entidade sincronizável tem:
- um ID de documento Firestore (string, nulo até a primeira sincronização bem-sucedida);
- um ID local autoincrement (drift);
- um `SyncStatus` (`pendingCreate` | `pendingUpdate` | `synced`).

## Coleções Firestore propostas (escopadas por usuário)
```
/users/{uid}/transacoes/{transacaoId}
/users/{uid}/perfis_banco/{perfilId}
/users/{uid}/categorias/{categoriaId}
/users/{uid}/rendas/{rendaId}
/users/{uid}/metas/{metaId}
/users/{uid}/orcamentos/{orcamentoId}
/users/{uid}/desafios/{desafioId}          (Fase 3)
/users/{uid}/carteira_simulada/{posicaoId} (Fase 3)
```

## Regra de segurança (esqueleto)
```
match /users/{userId}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```
Toda coleção nova deve ser coberta por esta estrutura de path (`/users/{uid}/...`) — nunca uma coleção raiz desprotegida por usuário.

## Tabelas Drift (cache local) — exemplo de padrão
```dart
class Transacoes extends Table {
  IntColumn get idLocal => integer().autoIncrement()();
  TextColumn get idRemoto => text().nullable()();
  TextColumn get descricao => text()();
  RealColumn get valor => real()();
  DateTimeColumn get data => dateTime()();
  TextColumn get categoriaId => text()();
  IntColumn get syncStatus => intEnum<SyncStatus>()();
}
```
Mesma estrutura (par de IDs + `SyncStatus`) se repete em `PerfisBanco`, `Rendas`, `Metas`, `Orcamentos`.

## Migrações
Ver `.claude/reviews/checklist-migration.md` e `.claude/prompts/create-migration.md` — toda mudança de schema (drift ou Firestore) é uma migração versionada e documentada aqui.

## Custo
Ver nota de custo em `.claude/memory/tech-stack.md` — desenhar queries pensando em paginação e agregados pré-computados (ex.: um documento de "resumo mensal" em vez de somar transações no cliente a cada abertura do dashboard).
