# Prompt: Criar Componente de Design System

## Quando usar
Use para criar um widget novo em `core/widgets/`, reutilizável por múltiplas features.

## Prompt

```
Crie o componente "App<Nome>" em core/widgets/:

1. Confirme antes, em `.claude/memory/design-system.md`, que um componente equivalente ainda não existe.
2. Todo token (cor/espaçamento/tipografia/raio) vem de app/theme/ — este é o único lugar onde literais de tema são aceitáveis como fonte, nunca reintroduzidos como literal solto no componente.
3. Se o componente exibe valor monetário, implemente o suporte ao Modo Discreto (máscara `•••••` quando o estado global estiver ativo) dentro do próprio componente.
4. Golden test cobrindo light e dark<, e Modo Discreto ativo/inativo, se aplicável>.
5. Adicione o componente à tabela de inventário em `.claude/memory/design-system.md` na mesma tarefa.

Contexto visual: <descreva o papel do componente e, se houver, a referência de mockup/tela que o motivou>.

Regras: `.claude/rules/material3.md`.
```
