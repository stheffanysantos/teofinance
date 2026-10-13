# Estrutura de Pastas

```
lib/
├── app/
│   ├── theme/              # AppColors, AppSpacing, AppRadius, AppTextStyles, AppTheme, app_chart_colors
│   └── routes/              # app_routes.dart (constantes), app_router.dart (go_router ou equivalente)
├── core/
│   ├── providers/            # core_providers.dart — Firebase app, Firestore, drift db, secure storage, MediaPipe runtime
│   ├── database/              # app_database.dart (drift), tables/
│   ├── storage/                # secure_storage_service.dart
│   ├── biometria/               # biometria_service.dart (local_auth)
│   ├── status/                   # sync_status.dart (enum compartilhado)
│   ├── widgets/                    # Design System: AppButton, AppCurrencyField, AppAmountText, ...
│   └── errors/                      # failure.dart (hierarquia de Failure)
└── features/
    ├── auth/
    ├── import/
    ├── transacao/
    ├── renda/
    ├── meta/
    ├── orcamento/
    ├── dashboard/
    ├── sync/
    ├── notificacoes/
    ├── educacao/            (Fase 3)
    ├── carteira_simulada/   (Fase 3)
    ├── gamificacao/         (Fase 3)
    └── ai_assistant/        (Fase 4)

# Cada feature segue:
features/<nome>/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── datasources/        # <nome>_remote_data_source.dart, <nome>_local_data_source.dart
│   └── repositories/        # <nome>_repository_impl.dart
└── presentation/
    ├── providers/            # <nome>_providers.dart
    ├── notifiers/              # <nome>_notifier.dart, <nome>_state.dart
    ├── screens/
    └── widgets/

test/
└── features/<nome>/...        # espelha lib/features/<nome>/ 1:1
```

Ver `.claude/templates/feature/FEATURE_STRUCTURE.md` para o detalhamento usado ao criar uma feature nova.
