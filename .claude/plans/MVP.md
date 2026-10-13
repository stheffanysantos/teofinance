# MVP (Fase 1) — Escopo Mínimo

> Fonte: especificação, seções 9 e 10. Objetivo: validar a proposta central (controle financeiro + visão unificada) com o menor escopo possível, antes de investir nas partes mais caras (Open Finance, IA local).

## Dentro do escopo do MVP
1. **`core/`** — `app_theme`, `core/providers/core_providers.dart` (Firebase app, Firestore, drift database, secure storage), `core/widgets/` base (`AppButton`, `AppTextField`, `AppCurrencyField`, `AppAmountText`, `AppLoadingIndicator`, `AppErrorState`, `AppEmptyState`).
2. **`auth`** — login + cadastro via Firebase Authentication; biometria local (`local_auth`) como segunda camada.
3. **`import`** — importação de extrato CSV (OFX pode entrar já no MVP se o esforço for baixo, senão Fase 2): prévia de colunas, mapeamento manual na primeira vez, detecção automática de separador/encoding, Perfil de Banco salvo e reaplicado.
4. **`transacao`** — listagem e cadastro manual de transações, categorização (regra simples + correção manual), categorias padrão pré-cadastradas.
5. **`renda`** — cadastro de renda fixa (com recorrência) e variável.
6. **`dashboard`** — saldo, receitas, despesas do período; gráfico de patrimônio líquido simples (`fl_chart`); comparativo com o mês anterior.
7. **`meta`** — criação de metas com valor-alvo, prazo, aporte sugerido, progresso visual.
8. **`sync`** — sincronização de todas as entidades acima com o Firestore (push ao reconectar + pull ao abrir tela), cache offline via drift.

## Fora do escopo do MVP (decisão deliberada)
- Integração bancária automática (Open Finance/agregador) — ver decisão 0003.
- Orçamento/limites (modo envelope), contas a pagar, divisão de contas — Fase 2.
- Gamificação, trilhas de aprendizado, carteira simulada, score financeiro — Fase 3.
- IA local (Gemma/MediaPipe), insights automáticos, assistente conversacional — Fase 4.
- Exportação de relatórios em PDF — pode entrar como item leve de Fase 2 se o esforço for baixo; não bloqueia o fechamento do MVP.

## Critério de "MVP fechado"
Um usuário consegue: importar um extrato CSV de pelo menos um banco (com perfil salvo e reaproveitado numa segunda importação), ver suas transações categorizadas no dashboard, cadastrar uma renda fixa e uma meta, e ver tudo refletido tanto offline (cache) quanto sincronizado no Firestore.
