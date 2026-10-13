# Arquitetura — TeoFinance

## Visão geral
App de finanças pessoais em Flutter, cloud-first com Firebase. Três frentes de produto sobre a mesma base arquitetural: controle de gastos/renda, educação financeira gamificada, e um assistente de IA local (Gemma).

```
┌─────────────────────────────┐
│          Cliente            │   Flutter + Dart, Riverpod, Clean Architecture
│  (Android / iOS)            │   Cache offline: drift (SQLite)
└──────────────┬───────────────┘
               │  cloud_firestore / firebase_auth / firebase_storage / FCM
┌──────────────▼───────────────┐
│    Backend mínimo (Firebase) │   Firestore (dados), Auth, Storage, FCM
└──────────────┬───────────────┘
               │  (nada, por design)
┌──────────────▼───────────────┐
│  Serviços externos opcionais  │   Cotação/indicadores de mercado (carteira simulada,
│                               │   comparador de investimentos) — único tráfego de rede
│                               │   fora do Firebase
└───────────────────────────────┘
```

A IA local (Gemma via MediaPipe) roda **dentro do cliente**, consumindo dados já sincronizados do Firestore — não é uma quarta camada de rede, é parte do processo do app, sem round-trip externo.

## Camadas internas (por feature)
```
presentation → domain ← data
```
- `domain/`: entities, repositories (contrato), usecases. Dart puro.
- `data/`: models, datasources (`remote` = Firestore/Storage, `local` = drift), repository (impl).
- `presentation/`: providers (DI), notifiers (Riverpod), screens, widgets.
- `core/`: cross-cutting (tema, providers globais, serviços compartilhados). Nunca importa de `features/`.

## Features e suas fronteiras
| Feature | Fronteira principal |
|---|---|
| `auth` | Firebase Authentication + biometria local |
| `import` | Parsing de CSV/OFX 100% local; nunca envia o arquivo bruto para fora do dispositivo |
| `transacao` | Dono do conceito de Transação; consumido por `dashboard`, `orcamento`, `gamificacao`, `ai_assistant` |
| `renda` | Renda fixa/variável |
| `meta` | Metas de investimento |
| `orcamento` | Orçamento/limites, contas a pagar, split |
| `dashboard` | Agregação read-only de outras features, nunca dono de dado próprio |
| `sync` | Único orquestrador de push/pull com o Firestore |
| `educacao` / `carteira_simulada` / `gamificacao` | Fase 3, consomem dados de `transacao`/`orcamento` via repository, nunca acessam Firestore direto |
| `ai_assistant` | Fase 4, consome dados via repositories de outras features, isolado de Firestore/Storage/rede |

## Decisões centrais
Ver `.claude/memory/decisions.md`: Firestore como fonte de verdade (0001), Riverpod (0002), importação manual sem Open Finance (0003), isolamento de privacidade da IA (0004).
