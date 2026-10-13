---
description: Cria um Service novo em core/ (cross-cutting, usado por múltiplas features)
argument-hint: <NomeService>
allowed-tools: Read, Grep, Glob, Write, Edit, Bash
---

Crie o service **$ARGUMENTS** em `core/.../` seguindo `.claude/templates/feature/service_template.dart`.

1. Confirme que o serviço é genuinamente cross-cutting (usado por 2+ features) — se for específico de uma feature, ele pertence lá, não em `core/`.
2. `core/` nunca importa de `features/*` (ver `.claude/rules/architecture.md`).
3. Exponha o service via `core/providers/core_providers.dart`, nunca reinstanciado por cada feature.
4. Se o service envolve dado sensível (credencial, biometria, chave), siga `.claude/rules/security.md`.
5. Gere teste unitário cobrindo o comportamento público do service.
