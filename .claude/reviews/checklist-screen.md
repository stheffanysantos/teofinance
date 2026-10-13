# Checklist — Nova Screen

- [ ] `ConsumerWidget`/`ConsumerStatefulWidget`, lê o Notifier via `ref.watch`.
- [ ] Todos os estados do `AsyncValue`/`State` tratados explicitamente (loading/data/error/empty quando aplicável).
- [ ] Zero hardcode de cor/espaçamento/tipografia — tudo via `app/theme/`.
- [ ] Valor monetário exibido via `AppAmountText` (respeita Modo Discreto).
- [ ] Ação destrutiva usa `AppConfirmDialog`.
- [ ] Rota registrada em `app/routes/app_routes.dart`.
- [ ] Revisão visual em light e dark.
- [ ] Widget test cobrindo loading/data/error/empty.
