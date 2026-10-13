# Regra: Git Workflow

## Commits
Conventional Commits, mensagem em português, escopo = nome da feature/módulo em inglês minúsculo:

```
<tipo>(<escopo>): <descrição no imperativo>

tipo: feat | fix | refactor | perf | test | docs | style | chore | build | ci
```

Exemplos:
```
feat(import): adiciona parser de OFX com deteccao automatica de encoding
fix(sync): corrige conflito de SyncStatus em transacao editada offline
refactor(orcamento): extrai calculo de progresso de categoria para usecase
test(ai-assistant): cobre que o datasource de inferencia nunca recebe client http
```

## Branches
- `main` — protegida, só recebe merge (release), **nunca commit direto**.
- `develop` — branch de integração; é onde o trabalho do dia a dia é commitado.
- `feature/<nome>` — uma feature/tela por branch a partir de `develop`, referenciando `.claude/plans/Features.md`.
- `fix/<descricao-curta>` — correções pontuais a partir de `develop`.

## Antes de commitar
- `pre_commit_gate.py` (`.claude/hooks/scripts/`) — intercepta `git commit` **quando rodado pelo Claude Code** e roda `dart analyze --fatal-infos`.
- `.githooks/pre-commit` — hook real do git, roda `dart analyze --fatal-infos` + `flutter test` para **qualquer** commit (terminal, IDE, Claude Code). Precisa ser ativado uma vez por clone:
  ```bash
  git config core.hooksPath .githooks
  ```

Se qualquer um falhar, o commit é bloqueado — corrigir os apontamentos antes de tentar novamente, nunca usar `--no-verify` para contornar.

## CI (GitHub Actions)
`.github/workflows/ci.yml` roda `dart analyze --fatal-infos` + `flutter test` (+ checagem de que `.freezed.dart`/`.g.dart` estão em dia) em todo push/PR para `develop`. Regras do Firestore (`firestore.rules`) são testadas com o emulador (`firebase emulators:exec`) no mesmo pipeline.

## Pull Requests
Toda PR deve conter:
- Descrição do problema/objetivo (o "porquê", não só o "o quê").
- Checklist marcado (`.claude/reviews/code-review-checklist.md`).
- Screenshots/gif para mudanças de UI (light + dark, e Modo Discreto quando aplicável).
- Menção a testes adicionados/alterados.
- Menção a migração de schema `drift` e/ou mudança em `firestore.rules`, se houver (`.claude/reviews/checklist-migration.md`).

Revisão segue o agente **Code Reviewer** (`.claude/agents/code-reviewer.md`) e o comando `/review-feature`.
