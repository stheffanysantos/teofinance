# Prompt: Refatorar sem Mudar Comportamento

## Quando usar
Use para extrair/reorganizar código existente sem alterar comportamento observável (ex.: extrair uma regra de cálculo de progresso de orçamento de dentro de uma Screen para um usecase).

## Prompt

```
Refatore <descreva o código-alvo e o problema estrutural, ex. "lógica de cálculo de progresso de orçamento dentro de OrcamentoScreen"> seguindo `.claude/rules/architecture.md`:

1. Identifique a camada correta de destino (usecase se é regra de negócio; core/ se é cross-cutting; widget de Design System se é puramente visual e reutilizável).
2. Extraia preservando o comportamento atual — nenhuma mudança de resultado visível ao usuário nesta tarefa.
3. Garanta que os testes existentes continuam passando sem alteração de expectativa; adicione teste novo cobrindo o código extraído isoladamente.
4. Se a extração revelar uma violação de dependência entre camadas, corrija e cite a regra específica violada.

Nunca misture refatoração com mudança de comportamento na mesma tarefa — se uma mudança de comportamento for necessária, sinalize antes de prosseguir.
```
