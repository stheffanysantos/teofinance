---
description: Revisão de performance focada em custo de leitura/escrita do Firestore e desempenho da IA local
argument-hint: [feature]
allowed-tools: Read, Grep, Glob, Bash
---

Revise $ARGUMENTS (ou o diff atual) com foco em performance e custo:

1. **Firestore**: alguma query recarrega o histórico inteiro de uma coleção quando um agregado/página já resolveria (ex.: dashboard relendo todas as transações em vez de usar um resumo pré-computado ou paginação)? Ver nota de custo em `.claude/memory/tech-stack.md`.
2. **Listeners**: algum `StreamProvider`/listener do Firestore permanece ativo além do necessário (sem `autoDispose`), gerando leituras contínuas desnecessárias?
3. **IA local**: se a mudança toca `features/ai_assistant/`, o prompt montado para o Gemma inclui mais dado do que o necessário para responder à pergunta (ex.: histórico financeiro inteiro em vez de um resumo/agregado)?
4. **Importação**: o parser de CSV/OFX processa arquivos grandes de forma incremental/streamed, evitando travar a UI em arquivos extensos?
5. **Build/rebuild Flutter**: algum `ConsumerWidget` reconstrói a árvore inteira quando `ref.watch` poderia ser escopado a um `select`.

Liste achados priorizados por impacto, citando arquivo/linha.
