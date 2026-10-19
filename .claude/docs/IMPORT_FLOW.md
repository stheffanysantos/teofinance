# Fluxo de Importação de Extrato (CSV/OFX)

> Equivalente, neste projeto, ao papel que um "fluxo operacional" (ex. OS_FLOW) tem em outros apps do portfólio — aqui, é o fluxo de dado mais sensível do produto em termos de variabilidade/risco (ver especificação, seção 10).

## Passo a passo
1. Usuário escolhe um arquivo (CSV ou OFX) via seletor de arquivo nativo.
2. O formato é detectado pelo **conteúdo** (não pela extensão: bancos exportam OFX como `.ofx`, `.qfx` ou `.txt`). Para CSV, detecta separador (`,`/`;`) e encoding (UTF-8/Latin-1) automaticamente. **OFX pula os passos 3-4**: o arquivo já identifica cada campo (data, valor, descrição), então não há mapeamento de colunas nem Perfil de Banco — vai direto ao passo 6.
3. `BankProfileMatcher` procura um Perfil de Banco salvo compatível (mesmo número/ordem de colunas esperado). 
   - **Perfil encontrado e compatível** → aplica o mapeamento automaticamente, pula para o passo 5.
   - **Nenhum perfil compatível** (banco novo, ou perfil existente mas layout mudou) → segue para o passo 4.
4. Mostra uma prévia das colunas do arquivo; usuário indica manualmente qual coluna é Data/Descrição/Valor/Categoria (quando houver). Esse mapeamento é salvo como um Perfil de Banco novo (ou atualiza o existente, se o usuário escolher "atualizar perfil" em vez de "criar novo").
5. Parseia o arquivo inteiro aplicando o mapeamento, gera uma lista de `Transacao` em memória (ainda não persistida).
6. Mostra uma tela de revisão (quantidade de transações, possíveis duplicatas já existentes) antes de confirmar.
7. Usuário confirma → transações são persistidas localmente (`pendingCreate`) e `features/sync/` as envia ao Firestore quando houver conexão.

## OFX
`features/import/data/services/ofx_parser.dart` lê OFX 1.x (SGML, tags sem fechamento) e 2.x (XML), de conta corrente e de cartão. Regras:
- Sinal do `TRNAMT` define débito/crédito; ponto ou vírgula decimal e milhar nos dois estilos.
- Só o dia de `DTPOSTED` importa (o fuso não desloca a data); data impossível (31/02) é erro, nunca vira o mês seguinte.
- Descrição = `NAME` e/ou `MEMO` (unidos quando diferem; `Sem descrição` se ambos faltam).
- Qualquer transação sem data/valor ou com valor/data inválido **interrompe a importação inteira** apontando o número da transação — nunca se pula ou corrige em silêncio.
- A instituição (`<ORG>`) segue para a reconciliação como `nomeBancoOriginal`.

## Duplicatas (passo 6)
Ao confirmar, o app compara o arquivo com o que já existe e, se houver repetidas, pergunta: *importar só as novas*, *importar todas* ou *cancelar*. Nada é descartado sem o usuário escolher.
- Chave de comparação: **dia + centavos + descrição** (sem diferença de caixa/espaços). Mesma data e valor com descrição diferente não é duplicata.
- A comparação **conta ocorrências**: duas compras iguais no mesmo dia são legítimas. Com 1 já existente e 2 no arquivo, só uma é duplicata.
- O acervo comparado depende do destino. *Transações*: compara com as transações existentes. *Reconciliação*: compara **só com linhas de extrato já importadas** — comparar com as transações seria errado, porque casar o extrato com os lançamentos é o objetivo da reconciliação.
- Se não for possível ler o acervo, a checagem é ignorada (nunca bloqueia a importação).
- Limitação: o `FITID` do OFX daria uma identidade exata, mas hoje não é guardado nas transações; a chave é a heurística acima, então o mesmo lançamento com descrição editada no banco não é reconhecido.

## Detecção de incompatibilidade (passo 3)
Se um Perfil de Banco é aplicado mas o número de colunas do arquivo atual não bate com o esperado pelo perfil, a importação **para** nesse ponto com um erro explícito — nunca mapeia colunas erradas silenciosamente e nunca gera transações a partir de um mapeamento que não bateu. O usuário é levado de volta ao passo 4 (remapeamento), com a opção de salvar como um perfil separado se preferir manter o antigo.

## Onde cada parte mora no código
- `features/import/data/services/csv_dialect_detector.dart` — separador/encoding.
- `features/import/data/services/bank_profile_matcher.dart` — compatibilidade de perfil.
- `features/import/data/services/ofx_parser.dart` — leitura de OFX (detecção por conteúdo + parsing).
- `features/import/domain/usecases/importar_extrato_usecase.dart` — orquestra os passos 2-7 (via dependências injetadas, não hardcoded).
- `features/import/domain/entities/perfil_banco.dart` — entidade do mapeamento salvo.
- `features/import/data/repositories/perfil_banco_repository_impl.dart` — persistência do perfil (sincronizável, mesmo padrão de `SyncStatus`).

## Fronteira de privacidade
Nenhum passo deste fluxo envolve rede — o arquivo nunca é lido por `features/sync/` nem por `features/ai_assistant/`. Só as `Transacao`s resultantes (já estruturadas, sem o arquivo original) entram no fluxo de sincronização padrão.
