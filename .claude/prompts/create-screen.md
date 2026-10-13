# Prompt: Criar Screen Nova (dentro de feature existente)

## Quando usar
Use quando uma tela nova precisa ser adicionada a uma feature que já existe (ex.: tela de "Editar Perfil de Banco" dentro de `features/import/` já existente).

## Prompt

```
Crie a screen "<NomeScreen>" dentro da feature já existente `features/<nome_da_feature>/`:

1. Reaproveite entities/usecases/repository já existentes — só crie um usecase novo se a intenção de negócio realmente não existir ainda.
2. presentation/notifiers/<nome>_notifier.dart — Notifier específico desta tela (nunca generalizar sobre o Notifier de outra tela da mesma feature).
3. presentation/notifiers/<nome>_state.dart — State freezed cobrindo os casos: inicial, loading, dados, erro<, vazio, se aplicável>.
4. presentation/screens/<nome>_screen.dart — `ConsumerWidget`, trata todos os casos do AsyncValue/State explicitamente.
5. Widgets específicos da tela em presentation/widgets/, reaproveitando componentes de `core/widgets/` sempre que existir um equivalente.
6. Rota nova em app/routes/app_routes.dart.
7. Widget test cobrindo loading/data/error<, empty>.

Contexto da tela: <descreva o que a tela mostra/faz, e de onde vem o dado>.

Regras: `.claude/rules/material3.md` (zero hardcode de tema, Modo Discreto em valor monetário), `.claude/rules/riverpod.md`, `.claude/rules/naming.md`.
```
