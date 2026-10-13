# Features — Backlog Detalhado

> Fonte viva de escopo por feature. `.claude/memory/roadmap-snapshot.md` referencia este arquivo.

## `auth` (Fase 1)
- Login/cadastro via Firebase Authentication (e-mail/senha; provedor social é opcional, não bloqueia o MVP).
- Biometria local (`local_auth`) como segunda camada antes de abrir o app.
- Status: não iniciado.

## `import` (Fase 1, expandida na Fase 2)
- Importação de CSV com prévia de colunas e mapeamento manual na primeira vez por banco.
- Detecção automática de separador (`,`/`;`) e encoding (UTF-8/Latin-1).
- Perfil de Banco: salvo, reaplicado, editável, suporta múltiplos perfis.
- Falha explícita quando o número de colunas não bate com o perfil salvo.
- OFX (Fase 1 se esforço baixo, senão Fase 2).
- Status: não iniciado.

## `transacao` (Fase 1)
- Listagem, cadastro manual, categorização automática (regra + correção manual).
- Categorias padrão + customizáveis pelo usuário.
- Status: não iniciado.

## `renda` (Fase 1)
- Renda fixa (recorrência) e variável.
- Projeção de saldo futuro com base em receitas/despesas fixas já cadastradas.
- Status: não iniciado.

## `dashboard` (Fase 1)
- Saldo/receitas/despesas do período, progresso de metas.
- Gráfico de patrimônio líquido ao longo do tempo.
- Relatório mensal comparando com o mês anterior.
- Exportação de relatórios PDF/CSV (pode escorregar para Fase 2).
- Status: não iniciado.

## `meta` (Fase 1)
- Criação de meta (valor-alvo, prazo, aporte sugerido), progresso visual.
- Sugestão automática de realocação de aporte quando a meta atrasa (pode escorregar para Fase 2/3).
- Status: não iniciado.

## `sync` (Fase 1, transversal)
- Push de pendências ao reconectar + manual; pull ao abrir tela.
- `SyncStatus` único por entidade sincronizável.
- Status: não iniciado.

## `orcamento` (Fase 2)
- Modo envelope por categoria, limites mensais com alerta.
- Contas a pagar com lembretes, split de gastos compartilhados.
- Histórico de preço de itens recorrentes.
- Status: planejado.

## `notificacoes` (Fase 2)
- FCM (push remoto) + `flutter_local_notifications` (lembretes locais).
- Resumo semanal/mensal, lembrete de conta a pagar, lembrete de aporte.
- Widget de home screen.
- Status: planejado.

## `educacao` (Fase 3)
- Trilhas por nível, quizzes, indicadores econômicos contextualizados.
- Simulador de juros compostos, comparador de investimentos.
- Status: planejado.

## `carteira_simulada` (Fase 3)
- Investimento fictício com dados de mercado reais.
- Status: planejado.

## `gamificacao` (Fase 3)
- Streaks, badges, Score Financeiro, desafios customizados/sugeridos, modo detox de gastos.
- Status: planejado.

## `ai_assistant` (Fase 4)
- Assistente conversacional local (Gemma/MediaPipe), insights automáticos, análise de padrão de gasto por impulso.
- Status: planejado, maior risco de engenharia do roadmap.
