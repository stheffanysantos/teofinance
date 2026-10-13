# Regra: UI / Material 3

## Tema único, zero hardcode
- Toda cor, raio, espaçamento e estilo de texto vem de `app/theme/` (`AppColors`, `AppSpacing`, `AppRadius`, `AppTextStyles`) — nunca `Color(0x...)`, `TextStyle(fontSize: ...)` ou `Colors.*` literal direto em uma Screen/Widget de feature.
- Exceção: arquivos dentro de `app/theme/` e `core/widgets/` são onde os tokens são *definidos* — hardcode ali é esperado.
- `AppTheme.light()`/`AppTheme.dark()` compõem um `ColorScheme`/`TextTheme` Material 3 a partir desses tokens; dark mode é obrigatório desde a primeira tela, nunca um "depois".

## Semântica de cor financeira
- `AppColors.income` (receita) e `AppColors.expense` (despesa) são tokens **distintos** de `AppColors.success`/`AppColors.error` — um gasto normal não é um "erro do app", e uma receita não é necessariamente "sucesso" (ex.: estorno). Nunca reutilizar `error`/`success` para representar valor financeiro positivo/negativo.
- `AppColors.warning` é reservado para alerta de limite de orçamento próximo do teto e para pendência de sincronização — não usar para destacar categoria/valor comum.

## Modo Discreto
- Qualquer `AppAmountText`/valor monetário na tela deve respeitar o estado global de "Modo Discreto" (ocultar valores com um toque) — a máscara (`•••••`) é aplicada no componente de Design System, nunca reimplementada ad-hoc em cada tela que mostra dinheiro.

## Gráficos (`fl_chart`)
- Todo gráfico (patrimônio líquido, comparativo mensal, progresso de carteira simulada) é envolvido por `AppChartCard`, que já aplica padding/tema consistentes — nunca um `LineChart`/`BarChart` solto direto na Screen sem o wrapper.
- Cores de série do gráfico vêm de uma paleta categórica definida em `app/theme/app_chart_colors.dart`, não cores arbitrárias por gráfico.

## Acessibilidade
- Contraste mínimo AA em texto sobre cor semântica (`income`/`expense`/`warning`/`error`) — verificar ao definir um tom novo.
- Toda ação destrutiva (excluir transação, excluir perfil de banco) exige `AppConfirmDialog`, nunca exclusão direta ao toque único.

## Revisão
Ver o agente **UI Engineer** (`.claude/agents/ui-engineer.md`) e o comando `/review-ui`. Lembrete não bloqueante automatizado por `guard_design_tokens.py` (ver `.claude/hooks/README.md`).
