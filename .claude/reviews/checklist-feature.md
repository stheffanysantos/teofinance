# Checklist — Feature Nova

- [ ] `domain/entities/` modelado antes de qualquer linha de UI.
- [ ] `domain/repositories/` contrato abstrato, sem implementação.
- [ ] Um usecase por intenção de negócio, nunca um `CrudUseCase<T>` genérico.
- [ ] `data/models/` com conversão explícita `toEntity()`/`fromEntity()`.
- [ ] `data/datasources/` remoto (Firestore) e local (drift) em classes separadas.
- [ ] `data/repositories/*_repository_impl.dart` é o único lugar que decide local×remoto.
- [ ] `presentation/providers/` só compõe, sem regra de negócio.
- [ ] Notifier com State freezed único, injetado via `ref`.
- [ ] Rotas registradas em `app/routes/app_routes.dart`.
- [ ] Se sincronizável: `SyncStatus` aplicado, falha parcial tratada em `sync/`.
- [ ] Se toca `ai_assistant`: isolamento de Firestore/Storage/rede confirmado.
- [ ] Se toca `import`: parsing local confirmado, perfil incompatível falha explicitamente.
- [ ] Testes cobrindo usecases, repository, notifiers e screens conforme `.claude/rules/testing.md`.
- [ ] `.claude/plans/Features.md` atualizado.
