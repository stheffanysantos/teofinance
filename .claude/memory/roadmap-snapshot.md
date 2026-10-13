# Roadmap — Snapshot

> Foto do estado atual. A fonte completa/viva é `.claude/plans/` (`MVP.md`, `Roadmap.md`, `Features.md`, `Sprint01.md`, `TechDebt.md`). Atualizar este snapshot quando o roadmap mudar de forma material, não a cada tarefa pequena.

## Estado atual
MVP (Fase 1) **completo** em 2026-10-13: `core`, `auth`, `import` (CSV genérico por Perfil de Banco), `transacao`, `renda`, `dashboard` (dados reais), `meta` e `sync` (push/pull Firestore ↔ Drift) todos implementados e ligados na UI. Firebase real configurado (`teofinance-142e3`), `firestore.rules` publicada. Lista completa do que falta por fase em `.claude/plans/Backlog.md`. Próximo passo: Fase 2 (Orçamento real + mais Perfis de Banco/OFX), a combinar.

## Fases do roadmap (da especificação, seção 9)
1. **MVP (Fase 1)** — validar a proposta central com o menor escopo possível: importação de CSV, categorização, dashboard básico, cadastro de rendas e metas. Sem integração bancária automática nem IA.
2. **Fase 2** — expandir o importador para mais bancos (perfis reaproveitáveis) e construir orçamento/limites, que dependem de dados reais fluindo pelas importações.
3. **Fase 3** — gamificação e educação financeira, que se beneficia de já ter dados de uso reais para personalizar trilhas e desafios.
4. **Fase 4** — IA local (Gemma) como diferencial avançado; exige mais engenharia (LLM on-device com performance aceitável) e se beneficia de um histórico de dados maior do usuário.

## Fora do escopo desta fase (registrar se mudar)
- Integração bancária automática via Open Finance/agregador (custo recorrente, credenciamento regulatório) — decisão de produto deliberada, não lacuna técnica.
- Backend de aplicação próprio fora do Firebase.
- Monetização/assinaturas — a definir, afeta decisões de arquitetura quando decidido (ver seção 10 da especificação).
