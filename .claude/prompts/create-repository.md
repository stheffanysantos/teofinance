# Prompt: Criar Repository

## Quando usar
Use para criar o contrato e a implementação de um Repository para uma entidade já modelada em `domain/entities/`.

## Prompt

```
Crie o Repository de "<NomeEntidade>" na feature `features/<nome>/`:

1. domain/repositories/<nome>_repository.dart — contrato abstrato com os métodos: <liste os métodos esperados e suas assinaturas, ex. obterTodas(), obterPorId(id), salvar(entidade), excluir(id)>.
2. data/datasources/<nome>_remote_data_source.dart — único ponto de acesso ao Firestore/Storage para esta entidade.
3. data/datasources/<nome>_local_data_source.dart — único ponto de acesso às tabelas drift para esta entidade.
4. data/repositories/<nome>_repository_impl.dart — decide local×remoto (Firestore é fonte de verdade — ver `.claude/memory/decisions.md` decisão 0001), traduz toda exception em Failure tipado, nunca vaza exception crua.
5. Se sincronizável: implemente sincronizarPendentes() com falha parcial tratada por item.
6. Teste cobrindo: sucesso remoto, fallback local sem conexão, exception→Failure<, e se sincronizável: sem-conexão/conflito/falha-parcial>.

Regras: `.claude/rules/architecture.md`, `.claude/reviews/checklist-repository.md`.
```
