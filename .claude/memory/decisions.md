# Log de Decisões Arquiteturais (ADR curto)

> Toda decisão nova entra no topo, formato Y-statement resumido. Decisões não são editadas retroativamente — se uma decisão muda, registra-se uma nova entrada marcando a anterior como `superseded`, com link cruzado.

---

## 0006 — Gemma entra atras de contratos; runtime LiteRT-LM (nao MediaPipe) e download fora de `ai_assistant/`
**Status**: accepted (integracao do plugin pendente)
**Data**: 2026-10-19

No contexto de integrar o Gemma local (decisao 0004), pesquisamos o plugin em 2026-10-19: `flutter_gemma` foi descontinuado em favor de `flutter_edge_ai` + `flutter_edge_ai_litertlm`; o motor MediaPipe esta so em manutencao e o plugin recomenda `.litertlm`. As versoes atuais do motor exigem Dart >= 3.12 (o projeto esta em 3.11.3) e Android `minSdk` 30, arm64. O modelo candidato e Gemma-3 1B (~0,5 GB), sem token no Hugging Face. Decidimos preparar tudo atras de contratos (`InferenciaLocal`, `GerenciadorModelo`, `MotorResposta`) com fallback por regras (`MotorRespostaPorRegras`), de modo que o assistente funcione sem o modelo, e manter o **download do modelo fora de `features/ai_assistant/`** (futuro `core/services/`), para o teste de privacidade continuar provando que a inferencia nao usa rede.

**Consequencias**:
- Positivo: o usuario sempre recebe resposta; trocar o plugin so afeta uma classe e um provider.
- Pendente: atualizar o Flutter (Dart >= 3.12), escolher onde hospedar o arquivo do modelo (Hugging Face direto ou Firebase Storage), subir `minSdk` para 30 e validar em aparelho de entrada antes de assumir viabilidade.

---

## 0005 — Monetização adiada; nenhuma decisão de arquitetura de assinatura tomada ainda
**Status**: accepted
**Data**: 2026-10-13

No contexto do item "a definir" da especificação (seção 10 — freemium com IA local/gamificação premium vs. pago único), decidimos **não** modelar nenhuma estrutura de assinatura/paywall no MVP. Qualquer ponto de extensão (ex.: feature flag por nível de conta) deve ser mantido simples e isolado, para não acoplar o domínio financeiro a uma decisão de modelo de negócio ainda não tomada.

**Consequências**: features de Fase 3/4 (gamificação avançada, IA local) não devem assumir que "todo usuário tem acesso" nem que "é preciso checar um plano" — ambas as premissas são válidas até a decisão de monetização ser tomada, e o código não deve antecipar nenhuma das duas.

---

## 0004 — IA local (Gemma/MediaPipe) isolada em `features/ai_assistant/`, proibida de acessar Firestore/arquivo de extrato diretamente
**Status**: accepted
**Data**: 2026-10-13

No contexto da proposta de valor central do produto ser "privacidade total dos dados financeiros processados pela IA" (especificação, seções 1 e 7.2), decidimos que `features/ai_assistant/` só pode ler dados através dos repositories já existentes das outras features (que já encapsulam a decisão local×remoto) — nunca abrir uma conexão própria com Firestore, nem ler arquivos de extrato brutos.

**Consequências**:
- Positivo: a garantia "nenhum dado financeiro sai do dispositivo para gerar uma resposta da IA" fica auditável em um módulo único, sem precisar inspecionar o app inteiro.
- Negativo/atenção: qualquer novo tipo de dado que a IA precise consumir exige expor um método novo no repository da feature dona do dado — mais fricção de propósito, para preservar o isolamento.

---

## 0003 — Importação de extrato é sempre manual (CSV/OFX), sem agregador de Open Finance
**Status**: accepted
**Data**: 2026-10-13

No contexto de o mercado brasileiro não ter um padrão único de exportação de extrato entre bancos (especificação, seção 10) e de um agregador de Open Finance ter custo mensal recorrente e exigir credenciamento regulatório, decidimos que o MVP e as fases seguintes do roadmap **não** implementam conexão bancária automática. O usuário exporta o extrato do próprio banco e importa manualmente; o app aprende o mapeamento de colunas (Perfil de Banco) na primeira vez e reaplica nas seguintes.

**Consequências**:
- Positivo: sem custo recorrente de agregador; parsing 100% local reforça a história de privacidade do produto.
- Negativo/atenção: se o banco mudar o layout do export, o perfil salvo quebra — o app deve detectar isso (ex.: número de colunas não bate) e pedir remapeamento, nunca importar dado errado silenciosamente. Ver `.claude/rules/architecture.md`, seção de importação.
- Follow-up registrado: suporte a Open Finance pode ser reavaliado em uma fase futura não planejada ainda; exigiria uma nova decisão aqui antes de implementar.

---

## 0002 — Riverpod como gerência de estado (não BLoC nem GetX)
**Status**: accepted
**Data**: 2026-10-13

A especificação sugere Riverpod ou BLoC, citando "Riverpod tem melhor suporte a testes e DI" como diferencial. Decidimos Riverpod com geração de código (`@riverpod`), por reduzir boilerplate de injeção de dependência (`Provider`/`ref.watch`) comparado a BLoC puro, e por permitir testar `Notifier`s isoladamente sem widget tree, sem o acoplamento de DI+rotas+estado que GetX introduz.

**Consequências**: toda a camada `presentation/` é escrita contra a API do Riverpod (`Notifier`, `AsyncNotifier`, `Provider`, `ref`) — ver `.claude/rules/riverpod.md`. Testar um `Notifier` não exige nenhum widget montado, só o `ProviderContainer`.

---

## 0001 — Arquitetura cloud-first com Firebase; Drift só como cache offline (não fonte de verdade)
**Status**: accepted
**Data**: 2026-10-13

A especificação descreve explicitamente uma arquitetura "cloud-first com Firebase": a maior parte dos dados fica no Firestore, com cache offline local no dispositivo. Decidimos que o Firestore é a fonte de verdade para transações/categorias/metas/orçamentos/perfis de banco, e que `drift` existe exclusivamente como cache de leitura offline e fila de escrita pendente (`SyncStatus`) — nunca como banco "principal" que o Firestore replica.

**Consequências**:
- Positivo: um único modelo mental de onde o dado "realmente mora"; simplifica resolução de conflito (o Firestore sempre vence, exceto escrita local ainda não sincronizada).
- Negativo/atenção: o app depende de desenhar o schema do Firestore pensando em custo de leitura/escrita desde o início (ver `.claude/memory/tech-stack.md`, nota de custo) — não é um detalhe a ser resolvido depois.
