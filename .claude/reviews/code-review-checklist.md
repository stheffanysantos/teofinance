# Checklist Geral de Code Review

- [ ] Arquitetura: `presentation → domain ← data` respeitado; `domain` sem Flutter/Riverpod/Firebase/drift; `core` sem import de `features`.
- [ ] Riverpod: Notifier injetado via `ref`, nunca instanciando repository/datasource diretamente; um único State freezed por Notifier.
- [ ] Nomenclatura: sufixos corretos por tipo de arquivo/classe (`.claude/rules/naming.md`); imports absolutos (`package:teofinance/...`).
- [ ] UI: zero hardcode de cor/espaçamento/tipografia; `income`/`expense` usados corretamente (nunca confundidos com `success`/`error`); Modo Discreto respeitado em valor monetário; revisão em light e dark.
- [ ] Segurança: credencial/token só via `flutter_secure_storage`; `firestore.rules` restringindo coleção nova ao próprio usuário; nenhum log de dado financeiro sensível.
- [ ] `features/ai_assistant/`: nenhum acesso direto a Firestore/Storage/rede — só via repositories de outras features; nenhuma chamada de rede no caminho de inferência.
- [ ] `features/import/`: parsing de extrato nunca sai do dispositivo; perfil de banco incompatível falha explicitamente.
- [ ] `features/sync/`: falha de uma entidade não bloqueia as demais; Firestore é a fonte de verdade.
- [ ] Testes: cobertura mínima por artefato (`.claude/rules/testing.md`); nenhum teste usando `Future.delayed` para esperar estado assíncrono.
- [ ] Documentação: `.claude/plans/Features.md`/`.claude/memory/design-system.md`/`.claude/docs/DATABASE.md` atualizados se a mudança for material.
- [ ] Git: commit segue Conventional Commits em português com escopo em inglês (`.claude/rules/git-workflow.md`).
