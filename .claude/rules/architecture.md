# Regra: Arquitetura

## Camadas e fluxo de dependência

```
presentation → domain ← data
```

- `domain/`: **zero import** de `flutter/*`, `riverpod`, `cloud_firestore`, `firebase_*`, `drift`. Só Dart puro + `fpdart`. Se um arquivo em `domain/` precisa importar qualquer um desses, a lógica está na camada errada.
- `data/`: implementa os contratos de `domain/repositories/`. É o único lugar que importa `cloud_firestore`/`firebase_storage` (remoto) e `drift` (local).
- `presentation/`: importa `domain/` (entities, usecases) e o próprio `data/` **apenas dentro do `Provider`/`providers.dart` da feature** (para instanciar o repository e injetar no Notifier). Screens e Widgets nunca importam `data/` diretamente.
- `core/`: código cross-cutting. **Nunca** importa de `features/*`. Se `core/` precisar de algo de uma feature, essa "coisa" não pertence à feature — sobe para `core/` também.

## Regra de dependência entre datasources

- `data/datasources/<feature>_remote_data_source.dart`: única classe que chama Firestore/Firebase Storage dentro da feature.
- `data/datasources/<feature>_local_data_source.dart`: única classe que chama as tabelas `drift` dentro da feature.
- `data/repositories/<feature>_repository_impl.dart`: **decide** entre local e remoto, orquestra fallback offline, nunca expõe o tipo de exception cru do Firebase/drift para fora — sempre traduz em `Failure`.

## Regra de sincronização (específica deste app)

- Nenhuma feature fora de `features/sync/` implementa sua própria lógica de "varrer pendências e enviar". Outras features só marcam o `SyncStatus` da entidade ao salvar localmente; `sync/` é quem lê esse status e decide quando/como enviar ao Firestore.
- `Repository` é o único lugar autorizado a decidir "buscar do cache local ou do Firestore" — nunca o `Notifier`, nunca a Screen.
- O Firestore é a fonte de verdade (ver `.claude/memory/decisions.md`, decisão 0001); o Drift é cache de leitura + fila de escrita pendente, nunca o inverso.

## Regra de importação (específica de `features/import/`)

- Todo o parsing de CSV/OFX acontece **inteiramente no dispositivo**, dentro de `features/import/data/` — nunca envia o conteúdo bruto do arquivo para qualquer serviço remoto (nem Firebase).
- A detecção de separador/encoding e a aplicação de um Perfil de Banco salvo vivem em classes dedicadas (`BankProfileMatcher`, `CsvDialectDetector`), nunca inline no usecase de importação.
- Se o número de colunas detectado não bater com o perfil salvo, a importação é **interrompida com um erro explícito** pedindo remapeamento — nunca prossegue mapeando colunas erradas silenciosamente.

## Regra de privacidade da IA (específica de `features/ai_assistant/`)

- `features/ai_assistant/` nunca abre conexão própria com Firestore/Storage nem lê arquivos de extrato — só consome dados já expostos pelos repositories de outras features (ver decisão 0004 em `.claude/memory/decisions.md`).
- Nenhuma chamada de rede é permitida no caminho de "gerar uma resposta" do assistente — a inferência roda via MediaPipe local.

## Usecases

- Um usecase = uma intenção de negócio. Proibido usecase genérico (`CrudUseCase<T>`).
- Assinatura: `Future<Either<Failure, T>> call(Params params)` (ou sem `Params` quando não há parâmetro).
- Usecase não conhece Riverpod nem Firestore/drift diretamente — só o contrato `Repository` (abstract).

## Providers (DI, Riverpod)

- O arquivo `<feature>_providers.dart` é infraestrutura de composição, **não** lugar de regra de negócio. Um provider só instancia e injeta (`Provider((ref) => XRepositoryImpl(firestore: ref.watch(firestoreProvider), db: ref.watch(driftDbProvider)))`), nunca decide fluxo condicional de negócio.
- Serviços verdadeiramente globais (Firestore, drift, secure storage, MediaPipe) são expostos uma única vez em `core/providers/core_providers.dart` — features não os recriam.

## O que rejeitar em revisão

- Import de `flutter/material.dart`, `riverpod`, `cloud_firestore` ou `drift` dentro de `domain/`.
- Import de `features/*` dentro de `core/*`.
- Chamada a Firestore/tabela `drift` fora de `data/datasources/`.
- `Notifier` decidindo "se busca local ou remoto" em vez de delegar ao Repository.
- Lógica de negócio dentro de um arquivo `*_providers.dart` ou dentro de uma Screen/Widget.
- `features/ai_assistant/` com qualquer import de `cloud_firestore`/`firebase_storage`/leitura de arquivo de extrato.
