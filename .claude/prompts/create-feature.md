# Prompt: Criar Feature Nova (end-to-end)

## Quando usar
Use este prompt quando um conceito de negócio novo e de primeira classe (ex.: "Meta de Investimento", "Importação de Extrato") precisa virar uma feature completa em `lib/features/`, com todas as camadas (domain, data, presentation), rotas e testes. Não use para uma tela nova dentro de uma feature já existente — nesse caso use `.claude/prompts/create-screen.md`.

## Prompt

```
Crie a feature "<nome_da_feature>" (pasta `features/<nome_da_feature>/`) completa, do zero, seguindo EXATAMENTE a arquitetura descrita em CLAUDE.md:

1. domain/entities/ — modele a(s) entidade(s) de negócio pura(s): <descreva os campos e invariantes de <NomeEntidade>, incluindo se é sincronizável (par de IDs local/Firestore + SyncStatus)>.
2. domain/repositories/ — contrato abstrato `<NomeEntidade>Repository` com os métodos que a feature precisa, retornando `Either<Failure, T>`.
3. domain/usecases/ — um usecase por intenção de negócio (ex.: `Registrar<NomeEntidade>UseCase`, `Get<NomeEntidade>ListUseCase`), cada um em seu próprio arquivo.
4. data/models/ — `<NomeEntidade>Model` (@freezed + @JsonSerializable) com `fromJson`/`toJson`/`toEntity()`/`fromEntity()`, mapeando os campos exatos de um documento Firestore.
5. data/datasources/ — `<nome>_remote_data_source.dart` (cloud_firestore) e `<nome>_local_data_source.dart` (drift), sempre em arquivos separados.
6. data/repositories/ — `<NomeEntidade>RepositoryImpl`, decidindo local×remoto (Firestore é a fonte de verdade), traduzindo exceptions em Failure.
7. presentation/providers/ — `<NomeFeature>Providers`, injetando datasources/repository/usecases via `ref`.
8. presentation/notifiers/ + presentation/screens/ + presentation/widgets/ — Notifier (`@riverpod` + `AsyncNotifier`/`State` freezed), Screen(s) e widgets específicos: <descreva as telas principais esperadas, ex. lista, detalhe, formulário>.
9. Rotas em app/routes/app_routes.dart, seguindo `.claude/rules/naming.md`.
10. Testes (unit para usecases/repository/notifiers, widget test por screen) + atualização de `.claude/plans/Features.md`.

Contexto de negócio da feature: <descreva em 2-4 frases o que a feature faz, e regras de negócio relevantes — ex. valor-alvo e prazo de uma meta, GPS não se aplica aqui mas validação de valor monetário positivo sim>.

Regras obrigatórias a seguir (releia antes de codar):
- `.claude/rules/architecture.md` — fluxo de dependência presentation → domain ← data, nunca inverter; Firestore como fonte de verdade.
- `.claude/rules/naming.md` — nomenclatura de arquivos, classes e rotas.
- `.claude/rules/riverpod.md` — injeção via `ref`, único State freezed por Notifier.
- `.claude/rules/material3.md` — tema, tokens, dark mode e Modo Discreto desde o início.
- `.claude/rules/testing.md` — cobertura mínima por tipo de artefato.
- Se a feature envolver entidade sincronizável, siga `.claude/docs/DATABASE.md` e delegue revisão ao Firebase Sync Engineer.
- Se a feature for `ai_assistant` ou tocar dados que ela consome, releia a regra de privacidade da IA.

Use os esqueletos em `.claude/templates/feature/` como base para cada arquivo — não reinvente a estrutura.

Ao final, rode (ou peça para eu rodar) `dart run build_runner build --delete-conflicting-outputs` e liste os arquivos criados por camada.
```

## O que a IA deve entregar
- Estrutura completa `data/domain/presentation` da feature, sem etapas puladas.
- Usecases nomeados por intenção de negócio.
- Notifier `@riverpod` + `State` freezed com union de casos, injeção via `ref`.
- Rotas registradas em `app_routes.dart`.
- Testes unitários e widget tests cobrindo os estados obrigatórios.
- Atualização de `.claude/plans/Features.md`.

## Checklist a seguir
- `.claude/reviews/checklist-feature.md`.
- Checklist obrigatório de `CLAUDE.md` antes de começar a codar.
