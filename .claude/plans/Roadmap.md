# Roadmap por Fases

> Fonte: especificação, seção 9. Este é o plano vivo — `.claude/memory/roadmap-snapshot.md` é só o resumo, atualizado quando uma fase muda de estado material.

## Fase 1 — MVP (Revisado 2026-10-15)
Ver `.claude/plans/MVP-V2-Revisado.md`. 

**Core** (Sprint 01 — ✅ Pronto):
- Importação de CSV com detecção automática de separador/encoding
- Categorização manual + automática
- Dashboard básico (saldo, receitas, despesas, gráficos)
- Cadastro de rendas (fixa + variável)
- Cadastro de metas com progresso
- Sincronização offline-first (Firestore + Drift)

**Novo** (Sprint 02–03 — Em Progresso):
- **Parcelamento de cartão** (Sprint 02): Compra de R$3000 em 12x → 12 transações filhas, 1/mês
- **Reconciliação** (Sprint 03): Fim do mês, importa novo extrato → App compara manual vs. banco → Relatório de matches/orphans/unmatched

**Removido**:
- ❌ Carteira simulada (portfolio) — não resolve problema real
- ❌ Gamificação com carteira fictícia — será Fase 3, com dados reais

## Fase 2 — Expansão de Importação + Controle Avançado
- Suporte a mais perfis de banco (reaproveitando o mecanismo de Perfil de Banco) e a OFX.
- Divisão de contas/gastos compartilhados (split bill) — você pagou R$100, mas foi para 3 pessoas → seu custo é R$33,33.
- Modo "envelope" (orçamento por categoria) e limites mensais com alerta.
- Controle de contas a pagar com lembretes (depende de `features/notificacoes/`, FCM).
- Reconhecimento de gastos recorrentes/assinaturas.
- Exportação de relatórios em PDF/CSV.
- Melhorias na reconciliação: matching semântico via IA local (ex.: "supermercado X" ↔ "MERCADO...")
**Por que depois do MVP**: depende de ter dados reais fluindo pelas importações + reconciliação funcionando.

## Fase 3 — Gamificação e Educação Financeira
- Trilhas de aprendizado por nível, com quizzes.
- Indicadores econômicos (Selic, CDI, IPCA) conectados ao contexto do usuário.
- Simulador de juros compostos, comparador de investimentos (CDB vs. Tesouro vs. Fundos).
- Streaks, badges, Score Financeiro, desafios (customizados e sugeridos), modo "detox de gastos".
- Desafios em grupo opcionais.
**Por que depois da Fase 2**: se beneficia de já ter dados de uso reais do usuário para personalizar trilhas, desafios e insights.

## Fase 4 — IA Local (Gemma)
- Assistente conversacional local via MediaPipe LLM Inference API.
- Geração de insights automáticos, sugestões de economia, análise de padrão de gasto por impulso.
- Widget de home screen com saldo/gasto do dia/progresso de meta.
**Por que por último**: exige mais engenharia (LLM on-device com performance aceitável em dispositivos de entrada) e se beneficia de um histórico de dados maior do usuário para gerar insights relevantes.

## Transversal a todas as fases
- Segurança/privacidade (`.claude/rules/security.md`) e Modo Discreto.
- LGPD: exportação e exclusão de dados sob demanda.
- Monitoramento de custo Firestore conforme o volume de dados cresce (ver `.claude/memory/tech-stack.md`).
