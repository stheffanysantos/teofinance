# Estrutura Padrão de uma Feature

Usar como base ao criar `lib/features/<nome>/`. Substituir `Nome`/`nome` pelo nome real da entidade/feature.

```
features/<nome>/
├── domain/
│   ├── entities/
│   │   └── <nome>.dart
│   ├── repositories/
│   │   └── <nome>_repository.dart
│   └── usecases/
│       ├── get_<nome>_list_usecase.dart
│       ├── salvar_<nome>_usecase.dart
│       └── excluir_<nome>_usecase.dart
├── data/
│   ├── models/
│   │   └── <nome>_model.dart
│   ├── datasources/
│   │   ├── <nome>_remote_data_source.dart
│   │   └── <nome>_local_data_source.dart
│   └── repositories/
│       └── <nome>_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── <nome>_providers.dart
    ├── notifiers/
    │   ├── <nome>_list_notifier.dart
    │   └── <nome>_list_state.dart
    ├── screens/
    │   ├── <nome>_list_screen.dart
    │   └── <nome>_form_screen.dart
    └── widgets/
        └── <nome>_card.dart

test/features/<nome>/
├── domain/usecases/...
├── data/repositories/...
└── presentation/notifiers/...
```

Ordem de criação recomendada: `domain/entities` → `domain/repositories` → `domain/usecases` → `data/models` → `data/datasources` → `data/repositories` → `presentation/providers` → `presentation/notifiers` → `presentation/screens`/`widgets` → rotas → testes (em paralelo com cada camada, não só no final).
