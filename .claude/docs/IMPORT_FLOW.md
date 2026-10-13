# Fluxo de Importação de Extrato (CSV/OFX)

> Equivalente, neste projeto, ao papel que um "fluxo operacional" (ex. OS_FLOW) tem em outros apps do portfólio — aqui, é o fluxo de dado mais sensível do produto em termos de variabilidade/risco (ver especificação, seção 10).

## Passo a passo
1. Usuário escolhe um arquivo (CSV ou OFX) via seletor de arquivo nativo.
2. `ImportParserService` detecta o tipo (extensão + conteúdo) e, para CSV, detecta separador (`,`/`;`) e encoding (UTF-8/Latin-1) automaticamente.
3. `BankProfileMatcher` procura um Perfil de Banco salvo compatível (mesmo número/ordem de colunas esperado). 
   - **Perfil encontrado e compatível** → aplica o mapeamento automaticamente, pula para o passo 5.
   - **Nenhum perfil compatível** (banco novo, ou perfil existente mas layout mudou) → segue para o passo 4.
4. Mostra uma prévia das colunas do arquivo; usuário indica manualmente qual coluna é Data/Descrição/Valor/Categoria (quando houver). Esse mapeamento é salvo como um Perfil de Banco novo (ou atualiza o existente, se o usuário escolher "atualizar perfil" em vez de "criar novo").
5. Parseia o arquivo inteiro aplicando o mapeamento, gera uma lista de `Transacao` em memória (ainda não persistida).
6. Mostra uma tela de revisão (quantidade de transações, possíveis duplicatas já existentes) antes de confirmar.
7. Usuário confirma → transações são persistidas localmente (`pendingCreate`) e `features/sync/` as envia ao Firestore quando houver conexão.

## Detecção de incompatibilidade (passo 3)
Se um Perfil de Banco é aplicado mas o número de colunas do arquivo atual não bate com o esperado pelo perfil, a importação **para** nesse ponto com um erro explícito — nunca mapeia colunas erradas silenciosamente e nunca gera transações a partir de um mapeamento que não bateu. O usuário é levado de volta ao passo 4 (remapeamento), com a opção de salvar como um perfil separado se preferir manter o antigo.

## Onde cada parte mora no código
- `features/import/data/services/csv_dialect_detector.dart` — separador/encoding.
- `features/import/data/services/bank_profile_matcher.dart` — compatibilidade de perfil.
- `features/import/domain/usecases/importar_extrato_usecase.dart` — orquestra os passos 2-7 (via dependências injetadas, não hardcoded).
- `features/import/domain/entities/perfil_banco.dart` — entidade do mapeamento salvo.
- `features/import/data/repositories/perfil_banco_repository_impl.dart` — persistência do perfil (sincronizável, mesmo padrão de `SyncStatus`).

## Fronteira de privacidade
Nenhum passo deste fluxo envolve rede — o arquivo nunca é lido por `features/sync/` nem por `features/ai_assistant/`. Só as `Transacao`s resultantes (já estruturadas, sem o arquivo original) entram no fluxo de sincronização padrão.
