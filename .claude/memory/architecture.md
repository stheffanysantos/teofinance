# Snapshot de Arquitetura — TeoFinance

> Complementa `.claude/rules/architecture.md` (regras) e `.claude/docs/ARCHITECTURE.md` (diagrama completo). Este arquivo é o resumo narrativo, lido sob demanda.

## Em uma frase
Clean Architecture (domain/data/presentation) + MVVM adaptado a Riverpod + Repository Pattern + Feature-First, sobre um backend **cloud-first com Firebase** (Firestore/Auth/Storage/FCM), com cache local `drift` offline-first e uma camada de IA 100% on-device (Gemma via MediaPipe) que nunca envia conteúdo de pergunta a um servidor externo.

## Por que cloud-first (e não só local-first)
Diferente de um app que trata o servidor como opcional, aqui o Firestore é a fonte de verdade: a maior parte dos dados (transações, categorias, metas, orçamentos, perfis de banco) vive no Firestore, com cache offline local no dispositivo para uso sem internet. A importação de extrato (CSV/OFX) é a única parte do fluxo que é **sempre** local — o arquivo nunca sai do dispositivo durante o parsing, só as Transações resultantes são sincronizadas.

## Camadas (resumo)
```
presentation → domain ← data
```
`domain` é Dart puro (zero Flutter/Riverpod/firebase_*/drift). `data` fala com Firestore/Firebase Storage (remoto) e `drift` (cache local). `presentation` é Riverpod (`Notifier`/`AsyncNotifier` + `Provider` + `Screen`).

## Peça mais crítica: `features/sync/`
Não é "mais uma feature" — é quem varre todas as entidades com `SyncStatus != synced` em todas as outras features e orquestra push/pull com o Firestore. As demais features nunca implementam sua própria sincronização; só marcam o status ao salvar localmente.

## Peça mais sensível: `features/import/`
Responsável pelo parsing de CSV/OFX, detecção automática de separador/encoding e pelos Perfis de Banco (mapeamento de colunas salvo e reaplicado). Roda inteiramente local — nenhuma rede envolvida no parsing em si. Deve ser defensivo: se o número de colunas não bater com o perfil salvo, avisa o usuário para remapear em vez de importar dado errado silenciosamente (ver `.claude/rules/architecture.md`, seção de importação).

## Peça mais isolada: `features/ai_assistant/`
Único ponto de integração com o MediaPipe LLM Inference API (Gemma). Consome dados já sincronizados do Firestore/cache local através dos repositories existentes das outras features — nunca acessa Firestore ou arquivos de extrato diretamente. Isso garante que a fronteira de privacidade ("nada sai do dispositivo para gerar uma resposta") seja auditável em um único módulo.

## Onde cada decisão foi registrada
Ver `.claude/memory/decisions.md` para o porquê de cada escolha estrutural (Riverpod vs. BLoC/GetX, Firebase cloud-first vs. backend próprio, Drift vs. sqflite puro, importação manual vs. Open Finance).
