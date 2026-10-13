# Memória Persistente — como funciona de verdade

O Claude Code **não** tem um banco de memória de longo prazo nativo entre sessões (fora do harness específico do produto, se houver). O recurso oficial e documentado usado para simular "memória persistente" é:

1. **`CLAUDE.md` é carregado automaticamente em toda sessão** iniciada dentro deste repositório.
2. **Imports com `@caminho/arquivo`** dentro de `CLAUDE.md` (ou de qualquer arquivo importado, até 5 níveis) são resolvidos e injetados automaticamente no contexto no início da sessão.
3. Arquivos em `.claude/memory/` que **não** são importados automaticamente continuam existindo como memória "sob demanda": qualquer agente pode e deve lê-los quando a tarefa exigir (ex.: o UI Engineer sempre lê `design-system.md` antes de criar um componente).

Ver a lista de imports ativos no final do `CLAUDE.md` (seção "Memória Persistente — imports automáticos").

## Arquivos desta pasta

| Arquivo | Carregado automaticamente? | Conteúdo |
|---|---|---|
| `decisions.md` | Sim (import automático) | Log de decisões arquiteturais (ADR curto) — cresce ao longo do projeto |
| `domain-glossary.md` | Sim (import automático) | Glossário de domínio (transação, perfil de banco, meta, score financeiro...) — evita ambiguidade de nomenclatura |
| `architecture.md` | Não — sob demanda | Snapshot narrativo da arquitetura (complementa `.claude/rules/architecture.md`) |
| `design-system.md` | Não — sob demanda | Paleta, tokens, inventário de componentes existentes |
| `tech-stack.md` | Não — sob demanda | Stack fixada e por que cada peça foi escolhida (inclui Riverpod vs. BLoC/GetX, Firebase cloud-first) |
| `roadmap-snapshot.md` | Não — sob demanda | Foto do estado atual do roadmap (fonte completa é `.claude/plans/`) |
| `conventions.md` | Não — sob demanda | Resumo de referência rápida das convenções (aponta para `.claude/rules/`) |

## Regra de manutenção

- **`decisions.md`**: toda vez que uma decisão arquitetural relevante for tomada (trocar uma lib, mudar um padrão, aceitar uma exceção a uma regra), registre uma entrada nova ANTES de implementar. Nunca decida silenciosamente algo que contradiz `CLAUDE.md`/`.claude/rules/` sem registrar aqui o porquê.
- **`domain-glossary.md`**: todo termo de negócio novo é adicionado aqui no momento em que a feature é criada.
- Os demais arquivos são atualizados pelo agente **Documentation Writer** (`.claude/agents/documentation-writer.md`) ou pelo comando `/generate-docs` sempre que a arquitetura, o design system ou o roadmap mudarem de forma material — não a cada PR pequena.
