# Backlog — O que falta até o app "completo"

> Registrado em 2026-10-13, no fechamento da primeira versão (MVP/Fase 1) antes do primeiro commit. Ver `.claude/plans/MVP.md` para o escopo já entregue e `.claude/plans/Roadmap.md` para a visão de fases completa.

## Estado desta versão (Fase 1 — MVP): ✅ completo
- `core/` (tema, Firebase, Drift, secure storage)
- `auth` (login/cadastro e-mail+senha, biometria local)
- `import` (CSV genérico com Perfil de Banco reaproveitável — qualquer banco, não só Nubank/BB)
- `transacao` (listagem real via stream do Drift, cadastro manual, categorização)
- `renda` (fixa com recorrência + variável)
- `dashboard` (saldo, receitas/despesas do mês, patrimônio líquido, últimas transações — tudo calculado a partir de dados reais)
- `meta` (criação, aporte, progresso — persistido)
- `sync` (push/pull Firestore ↔ Drift, `SyncStatus` enum, gatilho automático + botão manual)

### Pendência técnica conhecida desta versão
- `test/widget_test.dart`: os testes de widget que passam por `SyncGate`/`AppShell` quebraram porque o fake de teste não sobrescreve `firebaseAppProvider`/`syncEngineProvider`. Corrigir antes (ou logo depois) do commit — não é um bug de produto, só o fake de teste desatualizado.

## Fase 2 — Expansão de importação + Orçamento/Limites
- [ ] Orçamento (modo envelope) **real e persistido** — hoje `BudgetScreen` é mock, sem tabela própria no Drift/Firestore.
- [ ] Mais Perfis de Banco testados + suporte a OFX (hoje só CSV).
- [ ] Contas a pagar com lembretes (depende de `features/notificacoes/` + FCM + `flutter_local_notifications`).
- [ ] Divisão de contas/gastos compartilhados (split).
- [ ] Histórico de preço de itens recorrentes.
- [ ] Detecção de gastos recorrentes/assinaturas.
- [ ] Exportação de relatórios em PDF/CSV.

## Fase 3 — Gamificação e Educação Financeira
- [ ] Trilhas de aprendizado reais e persistidas (hoje só uma lição estática de exemplo, sem progresso salvo).
- [ ] Indicadores econômicos (Selic, CDI, IPCA) conectados ao contexto do usuário.
- [ ] Simulador de juros compostos, comparador de investimentos (CDB vs. Tesouro vs. Fundos).
- [ ] Carteira simulada com dados de mercado **reais** (hoje é mock estático).
- [ ] Streaks, badges, Score Financeiro **real** (hoje é um número fixo no Perfil), desafios.
- [ ] Desafios em grupo opcionais.

## Fase 4 — IA Local (Gemma)
- [ ] Assistente conversacional via MediaPipe/Gemma on-device (hoje o Chat responde por regra de palavra-chave, não por inferência real).
- [ ] Insights automáticos, sugestões de economia, detecção de gasto por impulso.
- [ ] Widget de home screen (saldo/gasto do dia/progresso de meta).

## Transversal (qualquer fase, ainda pendente)
- [ ] Modo Discreto funcional — o toggle existe na tela de Perfil, mas ainda não oculta valores monetários de fato em nenhuma tela.
- [ ] Exportação/exclusão de dados sob demanda (LGPD).
- [ ] Flavors dev/prod do Firebase (hoje só existe um projeto, `teofinance-142e3`, usado para tudo).
- [ ] Botões "Notificações" e "Sobre o app" no Perfil ainda são `onTap: () {}` (vazios).
