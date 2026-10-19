# MVP V2 — Escopo Revisado (Reconciliação + Parcelamento)

> Atualizado: 2026-10-19 — **MVP V2 entregue**. O estado atual e o que falta estão em `Backlog.md`; este arquivo registra o escopo e as decisões da época.
> Mudança: Remover simulação (portfolio/trail), focar em reconciliação e parcelamento — o que resolve o problema real de controle financeiro.

## Dentro do Escopo

### ✅ Já Implementado (Sprint 01)
1. **`core/`** — Tema, widgets base, providers globais
2. **`auth/`** — Firebase Authentication + biometria
3. **`import/`** — Parser CSV/OFX com detecção automática
4. **`transacao/`** — Cadastro e listagem manual (será expandido)
5. **`renda/`** — Renda fixa e variável
6. **`dashboard/`** — Saldo, receitas, despesas, gráficos
7. **`meta/`** — Criação de metas com progresso
8. **`sync/`** — Sincronização offline-first

### 🆕 Novos (Sprint 02–03)
9. **`parcelamento/`** — Compras de cartão divididas em parcelas
   - Usuário compra notebook em 12x → 12 transações filhas, 1 por mês
   - Cada parcela é uma linha no extrato
   - Dashboard mostra "R$250 (parcela 3/12 de notebook)"
10. **`reconciliation/`** — Comparar manual vs. banco no fim do mês
    - Importa novo extrato → Compara com transações inseridas
    - Matching automático (valor + data), com curador manual para exceções
    - Relatório: "Você registrou X, banco registrou Y — diferença: Z"
    - IA local (depois) para matching semântico

### 📦 Fora do MVP V2 (Fase 2+)
- ~~`divisao_despesa/`~~ — **entregue**: a divisão mora em `features/transacao/` (campos `minhaParte`/`divididoCom`), contando só a parte do usuário.
- Open Finance (download automático de extrato) — Fase 2
- Modo Simulação / Carteira Fictícia — REMOVIDO
- Gamificação (trail) — REMOVIDO

## Entidades Novas (Drift + Firestore)

### `parcelamento`
```dart
@DataClassName('ParcelamentoData')
class Parcelamento {
  final String id;
  final String userId;
  final String transacaoOriginalId;  // FK → transacao
  final double totalOriginal;        // R$3000
  final int numeroParcelas;          // 12
  final DateTime dataPrimeiraParc;
  late final DateTime dataCriacao;
  
  // Cada parcela é uma transacao_id filha com parcelamento_id = este id
}
```

### `transacao` (expansão)
```dart
// Novos campos:
double? valorParcela;              // null se não é parcela
int? numeroParcela;                // 1, 2, 3... (null se não é parcela)
String? parcelamentoId;            // FK → parcelamento (null se não é parcela)
bool ehParcela;                    // true se é filho de parcelamento
String? statusParcela;             // pendente | pago | atrasado (null se não é parcela)

// Existentes (continuam):
String id, userId, descricao, categoria, etc...
```

### `reconciliation_match` (nova tabela)
```dart
@DataClassName('ReconciliationMatchData')
class ReconciliationMatch {
  final String id;
  final String userId;
  final String transacaoId;         // FK → transacao (a que o usuário inseriu)
  final String linhaExtratoId;      // FK → linha do extrato importado
  final DateTime dataReconciliacao;
  final String status;              // auto_matched | manual_matched | unmatched | orphan
  final double confidence;          // 0.0–1.0 (1.0 = match perfeito)
}
```

## Fluxo de Implementação

### Sprint 02: Parcelamento
1. Expandir `Transacao` entity com campos de parcela
2. Criar feature `parcelamento/` (domain + data + presentation)
3. Tela: "Parcelar esta transação?" ao cadastrar
4. Dashboard: exibir parcelas (não a transação-mãe)
5. Testes: parcelamento + impacto no dashboard
6. Sync: garantir que parcelas são sincronizadas

### Sprint 03: Reconciliação
1. Criar feature `reconciliation/` 
2. UseCase: `MatchTransacoesCom ExtratoUseCase`
3. Algoritmo: matching valor + data
4. Tela: "Reconciliar extrato" → lista de matches (auto + manual)
5. Dashboard: campo "Status reconciliação: X de Y"
6. Relatório: fim do mês, diferenças
7. Testes: matching automático, curador manual

### Fase 2 (depois):
- Divisão de despesas (`divisao_despesa/`)
- IA para matching semântico
- Alertas de transações não reconciliadas

## Critério de MVP V2 Fechado
Um usuário consegue:
1. ✅ Cadastrar e importar transações
2. ✅ Inserir uma compra de cartão em 12x → ver 12 parcelas no dashboard
3. ✅ No fim do mês, importar novo extrato → App compara (matching automático)
4. ✅ Resolver conflitos manualmente se houver
5. ✅ Ver relatório: "gastei R$X de verdade (considerando parcelamentos)"
6. ✅ Tudo sincronizado offline-first no Firestore

---

## Próximas Ações
Concluídas: schema Drift (parcelamento, reconciliação, orçamento, contas), sync dos novos dados, features `parcelamento/` e `reconciliation/`.

**Diferenças em relação ao plano original** (decididas durante a implementação):
- `extrato_linhas` e `reconciliation_matches` **não** vão ao Firestore: o conteúdo do extrato nunca sai do aparelho.
- A tabela de matches não tem `userId` e ganhou o status `rejected` (par recusado não volta a ser sugerido).
- Regras do Firestore: as da `develop` isolam `users/{uid}/**` ao dono e bastam para o app pessoal; a versão mais restrita está na branch `feature/firestore-rules`.
