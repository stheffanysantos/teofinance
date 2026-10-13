---
description: Atualiza .claude/docs/ e os snapshots de .claude/memory/ a partir do estado real do código
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Aja como o agente **Documentation Writer** (`.claude/agents/documentation-writer.md`):

1. Releia a estrutura real de `lib/` e compare com `.claude/docs/FOLDER_STRUCTURE.md` — atualize divergências.
2. Releia `core/widgets/` e atualize a tabela de inventário em `.claude/memory/design-system.md`.
3. Releia o estado real das features em `lib/features/` e atualize `.claude/memory/roadmap-snapshot.md` e `.claude/plans/Features.md` se houver divergência material.
4. Confirme que todo termo de negócio novo encontrado no código está em `.claude/memory/domain-glossary.md`.
5. Nunca documente algo aspiracional como se já existisse — se uma feature está parcialmente implementada, diga isso explicitamente.
