# Hooks — o que é real e o que é heurística

Hooks do Claude Code são **comandos de shell determinísticos** disparados por eventos (`PreToolUse`, `PostToolUse`, `SessionStart`, etc.), configurados em `.claude/settings.json`. Eles **não** são "a IA revisando o código" — são scripts Python que recebem um JSON via stdin com dados do evento (`tool_name`, `tool_input`, `cwd`, ...) e podem:
- **Bloquear a ação** (`exit 2`, mensagem no `stderr` vira o motivo mostrado);
- **Deixar passar e injetar contexto** (JSON no `stdout` com `hookSpecificOutput.additionalContext`/`systemMessage`).

| O que o hook faz | Script | Tipo |
|---|---|---|
| Bloqueia import de Flutter/Riverpod/Firebase/drift dentro de `domain/`; bloqueia import de `features/` dentro de `core/`; bloqueia `features/ai_assistant/` acessando Firestore/Storage/rede diretamente | `guard_architecture.py` | Bloqueio real (regex/substring, não linter semântico completo) |
| Bloqueia Notifier instanciando Repository/DataSource diretamente (em vez de via `ref`); alerta sobre provider de feature declarado em `core/providers/`; alerta sobre State sem `@freezed` | `guard_riverpod_pattern.py` | Bloqueio real (parcial) |
| Detecta `Color(0x...)`, `TextStyle(fontSize: ...)` literal, `Colors.*` direto fora de `app/theme`/`core/widgets`; alerta sobre uso de `AppColors.error/success` em contexto de valor monetário (deveria ser `income`/`expense`) | `guard_design_tokens.py` | Aviso não bloqueante (falso-positivo real existe) |
| Lembrete pós-escrita: rodar `build_runner`, checar checklist de `.claude/reviews/`, revisar `firestore.rules` ao tocar datasource remoto, confirmar isolamento do parser de importação | `post_write_reminder.py` | Injeta contexto, não edita nada sozinho |
| Intercepta `git commit` e roda `dart analyze --fatal-infos`; bloqueia o commit se falhar | `pre_commit_gate.py` | Bloqueio real e determinístico |
| Início de sessão: injeta lembrete curto do checklist obrigatório | `session_start_briefing.py` | Injeta contexto |

## Dependência técnica
Scripts usam **Python 3**, chamado como `python` em `.claude/settings.json`. No Windows `python3` costuma ser só o atalho da Microsoft Store (não executa nada e o erro não bloqueia, então os hooks parecem ativos mas nunca rodam); por isso o comando é `python`. Em outra máquina, ajuste o comando em `settings.json` se o Python 3 tiver outro nome, ou reescreva os scripts (Dart/Node) e documente no onboarding.

O hook **real do git** (`.githooks/pre-commit`: `dart analyze --fatal-infos` + `flutter test`) vale para qualquer commit, não só os do Claude Code. Ative uma vez por clone: `git config core.hooksPath .githooks`.

## Onde estão
- Configuração: `.claude/settings.json` (chave `"hooks"`).
- Scripts: `.claude/hooks/scripts/*.py`.

## O que um hook não faz
Não substitui revisão real de arquitetura/segurança/performance — isso continua sendo função dos agentes (`.claude/agents/`) e dos comandos `/review-*`, invocados explicitamente. Os hooks aqui cobrem checagens mecânicas e determinísticas; julgamento fica com os agentes.
