---
description: Revisão de UI/Design System — tokens, Modo Discreto, dark mode, gráficos
argument-hint: <screen-ou-widget>
allowed-tools: Read, Grep, Glob, Bash
---

Revise $ARGUMENTS seguindo `.claude/rules/material3.md` e `.claude/memory/design-system.md`:

1. Zero hardcode de cor/espaçamento/tipografia fora de `app/theme/`/`core/widgets/`.
2. Valores monetários usam `AppAmountText` (ou equivalente) e respeitam o Modo Discreto.
3. `income`/`expense` usados corretamente (nunca confundidos com `success`/`error`).
4. Revisão em light e dark.
5. Gráficos usam `fl_chart` envolvido por `AppChartCard`, cores de série vindas de `app/theme/app_chart_colors.dart`.
6. Ação destrutiva (excluir transação/perfil de banco) usa `AppConfirmDialog`.
7. Componente novo adicionado ao inventário de `.claude/memory/design-system.md` com golden test (light/dark).

Liste achados citando arquivo/linha.
