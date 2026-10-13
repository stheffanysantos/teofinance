# Prompt: Criar Widget de Feature

## Quando usar
Use para um widget específico de uma feature (não reutilizável entre features — para isso, use `.claude/prompts/create-component.md`).

## Prompt

```
Crie o widget "<Nome>" dentro de features/<nome_da_feature>/presentation/widgets/:

1. Reaproveite componentes de core/widgets/ sempre que existir um equivalente (ex.: AppAmountText para qualquer valor monetário, AppCategoryChip para categoria).
2. Zero hardcode de tema — tudo via app/theme/.
3. Se o widget representa um item de lista (ex.: card de transação/meta), inclua um preview com dados de amostra via um construtor factory `<Nome>.preview()` usado só em testes/storybook, nunca em produção.
4. Widget test cobrindo os estados visuais relevantes.

Contexto: <descreva o que o widget mostra e de onde vem o dado (prop vs. ref.watch direto)>.
```
