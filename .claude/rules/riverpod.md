# Regra: Riverpod

Substitui, neste projeto, o papel que `getx.md` tinha num app GetX — define os antipadrões de gerência de estado a evitar.

## Geração de código
- Todo `Notifier`/`AsyncNotifier`/`Provider` de feature usa o anotador `@riverpod` (`riverpod_generator`), nunca a API legada (`StateNotifierProvider`/`ChangeNotifierProvider`) em código novo.
- Rodar `dart run build_runner build --delete-conflicting-outputs` após qualquer `Notifier` novo ou alterado.

## Injeção de dependência
- Repository/UseCase são injetados nos Notifiers **via `ref.watch(xProvider)`/`ref.read(xProvider)`**, nunca instanciados diretamente dentro do Notifier (`XRepositoryImpl()` dentro do `build()` é proibido — quebra testabilidade e DI).
- Um `Notifier` nunca lê outro `Notifier` de uma feature não relacionada para "economizar" uma consulta — se dois Notifiers precisam do mesmo dado, o dado sobe para um provider compartilhado em `core/providers/` ou é modelado como um usecase que os dois chamam.

## Estado
- Um único `State` (freezed, union de casos) por Notifier — nunca múltiplos campos soltos de estado mutável dentro do mesmo `Notifier` representando a mesma tela.
- `AsyncNotifier`/`AsyncValue` é o padrão para qualquer estado que depende de I/O (Firestore, drift, MediaPipe) — nunca modelar loading/error manualmente com `bool`s soltos quando `AsyncValue` já resolve isso.

## Escopo e ciclo de vida
- `Provider`/`Notifier` de uma feature específica vive em `<feature>_providers.dart`, nunca em `core/providers/` (reservado para serviços globais: Firestore, drift, auth, secure storage, MediaPipe runtime).
- `ref.keepAlive()`/`autoDispose` deliberado e comentado quando usado — nunca manter estado vivo "por acidente" sem justificativa (ex.: um `AsyncNotifier` de uma tela de detalhe deve ser `autoDispose` por padrão).

## O que rejeitar em revisão
- `Notifier` instanciando repository/datasource diretamente em vez de via `ref`.
- Estado de tela modelado com campos soltos em vez de um único `State` freezed.
- Provider de feature específica declarado em `core/providers/`.
- Widget lendo `ref.watch` de um provider de `data/` diretamente, pulando o Notifier da feature.
