# Design System — Snapshot

> Inventário de tokens e componentes esperados. Consultar antes de criar qualquer widget/cor/espaçamento novo (evita duplicação — ver `.claude/rules/material3.md`). Nenhum componente foi implementado ainda — este arquivo define o ponto de partida proposto, a ser atualizado assim que `app/theme/` e `core/widgets/` existirem de fato.

## Paleta proposta (semântica financeira)
| Token | Uso |
|---|---|
| `AppColors.primary` | Ações principais, AppBar, saldo em destaque no dashboard |
| `AppColors.secondary` | Ações secundárias, progresso de meta, item selecionado de navegação |
| `AppColors.income` | Valores de receita/entrada (tom esverdeado) |
| `AppColors.expense` | Valores de despesa/saída (tom avermelhado, nunca igual a `error` para não confundir "gasto normal" com "erro do app") |
| `AppColors.success` | Meta concluída, streak ativo, importação bem-sucedida |
| `AppColors.warning` | Limite de orçamento próximo de estourar, sincronização pendente |
| `AppColors.error` | Falha de importação, erro de autenticação, limite estourado |
| `AppColors.light` / `AppColors.dark` | `ColorScheme` completo (Material 3), claro e escuro — **Modo Discreto** (ocultar valores) não é um tema, é um estado de UI (mascarar texto), não confundir os dois conceitos |

## Espaçamento (`app_spacing.dart`)
| Token | Valor sugerido |
|---|---|
| `AppSpacing.xs` | 4 |
| `AppSpacing.sm` | 8 |
| `AppSpacing.md` | 16 |
| `AppSpacing.lg` | 24 |
| `AppSpacing.xl` | 32 |

## Componentes de `core/widgets/` esperados (inventário — atualizar a cada componente novo)
| Componente | Status | Papel |
|---|---|---|
| `AppButton` | A criar | Botão padrão com estado de loading |
| `AppTextField` | A criar | Campo de formulário M3 |
| `AppCurrencyField` | A criar | Campo de entrada monetária formatada (BRL), usado em cadastro de transação/renda/meta |
| `AppAmountText` | A criar | Texto de valor monetário com cor semântica (`income`/`expense`) e suporte ao **Modo Discreto** (mascarar com `•••••` quando ativo) |
| `AppLoadingIndicator` | A criar | Estado de carregamento padrão |
| `AppErrorState` | A criar | Estado de erro com "tentar novamente" |
| `AppEmptyState` | A criar | Estado vazio (ex.: nenhuma transação no período) |
| `AppSyncBadge` | A criar | Indicador de pendência de sincronização com o Firestore |
| `AppCategoryChip` | A criar | Chip de categoria de transação, com ícone e cor por categoria |
| `AppProgressRing`/`AppBudgetBar` | A criar | Progresso de orçamento por categoria (modo envelope) e de meta de investimento |
| `AppStreakBadge` | A criar | Indicador de streak de dias dentro do orçamento |
| `AppChartCard` | A criar | Card padrão envolvendo um gráfico `fl_chart` (patrimônio líquido, comparativo mensal) |

## Regra de manutenção
Todo componente criado em `core/widgets/` deve ser adicionado a esta tabela na mesma PR (comando `/generate-docs` automatiza isso quando aplicável).
