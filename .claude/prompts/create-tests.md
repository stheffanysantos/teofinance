# Prompt: Criar Testes Faltantes

## Quando usar
Use para fechar lacunas de cobertura em código já existente, sem alterar o código de produção.

## Prompt

```
Gere os testes faltantes para <arquivo ou feature-alvo>, seguindo `.claude/rules/testing.md`:

1. Liste os cenários obrigatórios para o tipo de artefato (usecase/repository/notifier/screen/datasource/parser).
2. Use mocktail para mocks; fake_cloud_firestore quando o teste exercitar um datasource remoto real.
3. Nunca use Future.delayed para esperar estado assíncrono.
4. Para Notifier: use ProviderContainer com overrides, nunca subindo widget tree inteira.
5. Para componente de Design System: inclua golden test (light/dark, e Modo Discreto se exibe valor monetário).

Não altere o código de produção nesta tarefa, a menos que um teste revele um bug real — nesse caso, pare e reporte antes de corrigir.
```
