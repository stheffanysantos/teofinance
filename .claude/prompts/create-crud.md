# Prompt: Criar CRUD Completo de uma Entidade

## Quando usar
Use quando uma entidade precisa de criação/leitura/edição/exclusão completa pela UI (ex.: Metas de Investimento, Perfis de Banco).

## Prompt

```
Crie o CRUD completo de "<NomeEntidade>" na feature `features/<nome>/`:

1. Repository (ver `.claude/prompts/create-repository.md`) com os 4 métodos: obterTodas/obterPorId, salvar (cria ou atualiza), excluir.
2. Usecases: `Get<NomeEntidade>ListUseCase`, `Salvar<NomeEntidade>UseCase` (valida antes de persistir), `Excluir<NomeEntidade>UseCase`.
3. Telas: `<NomeEntidade>ListScreen` (lista + estado vazio), `<NomeEntidade>FormScreen` (criar/editar, mesmo formulário para os dois casos), confirmação de exclusão via `AppConfirmDialog`.
4. Validação de formulário: tanto na UI (feedback imediato) quanto no usecase `Salvar<NomeEntidade>UseCase` (regra de negócio real, ex. valor-alvo de meta > 0).
5. Testes para os 3 usecases + widget tests das 2 telas.

Regras de validação específicas desta entidade: <descreva os campos obrigatórios e invariantes de negócio>.
```
