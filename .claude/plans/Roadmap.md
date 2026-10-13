# Roadmap por Fases

> Fonte: especificação, seção 9. Este é o plano vivo — `.claude/memory/roadmap-snapshot.md` é só o resumo, atualizado quando uma fase muda de estado material.

## Fase 1 — MVP
Ver `.claude/plans/MVP.md`. Importação de CSV, categorização, dashboard básico, cadastro de rendas e metas. Sem integração bancária automática nem IA.

## Fase 2 — Expansão de importação + Orçamento/Limites
- Suporte a mais perfis de banco (reaproveitando o mecanismo de Perfil de Banco do MVP) e a OFX, se não entrou na Fase 1.
- Modo "envelope" (orçamento por categoria) e limites mensais com alerta.
- Controle de contas a pagar com lembretes (depende de `features/notificacoes/`, FCM + `flutter_local_notifications`).
- Divisão de contas/gastos compartilhados (split).
- Histórico de preços de itens recorrentes.
- Reconhecimento de gastos recorrentes/assinaturas.
- Exportação de relatórios em PDF/CSV.
**Por que depois do MVP**: depende de ter dados reais fluindo pelas importações para o orçamento fazer sentido.

## Fase 3 — Gamificação e Educação Financeira
- Trilhas de aprendizado por nível, com quizzes.
- Indicadores econômicos (Selic, CDI, IPCA) conectados ao contexto do usuário.
- Simulador de juros compostos, comparador de investimentos (CDB vs. Tesouro vs. Fundos).
- Carteira simulada com dados de mercado reais.
- Streaks, badges, Score Financeiro, desafios (customizados e sugeridos), modo "detox de gastos".
- Desafios em grupo opcionais.
**Por que depois da Fase 2**: se beneficia de já ter dados de uso reais do usuário para personalizar trilhas e desafios.

## Fase 4 — IA Local (Gemma)
- Assistente conversacional local via MediaPipe LLM Inference API.
- Geração de insights automáticos, sugestões de economia, análise de padrão de gasto por impulso.
- Widget de home screen com saldo/gasto do dia/progresso de meta.
**Por que por último**: exige mais engenharia (LLM on-device com performance aceitável em dispositivos de entrada) e se beneficia de um histórico de dados maior do usuário para gerar insights relevantes.

## Transversal a todas as fases
- Segurança/privacidade (`.claude/rules/security.md`) e Modo Discreto.
- LGPD: exportação e exclusão de dados sob demanda.
- Monitoramento de custo Firestore conforme o volume de dados cresce (ver `.claude/memory/tech-stack.md`).
