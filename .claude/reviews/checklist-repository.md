# Checklist — Novo Repository

- [ ] Contrato (`abstract class`) em `domain/repositories/`, sem implementação.
- [ ] Implementação (`data/repositories/*_repository_impl.dart`) é o ÚNICO lugar que decide local×remoto para esta entidade.
- [ ] Toda exception de `cloud_firestore`/`drift` é traduzida em um `Failure` tipado antes de retornar — nenhuma exception crua vaza para `domain`/`presentation`.
- [ ] `RemoteDataSource` e `LocalDataSource` são classes separadas, injetadas por construtor no repository.
- [ ] Firestore tratado como fonte de verdade (ver `.claude/memory/decisions.md`, decisão 0001) — exceto escrita local ainda pendente de envio.
- [ ] Se a entidade é sincronizável: `sincronizarPendentes()` implementado com tratamento de falha parcial (uma entidade falhar não interrompe as demais).
- [ ] Testes cobrindo: sucesso remoto, fallback local sem conexão, exception→Failure e (se sincronizável) sem-conexão/conflito/falha-parcial.
