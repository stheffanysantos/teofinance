# Sprint 01 — Bootstrap + Primeira Fatia Vertical

> Objetivo: ter o pipeline completo (`domain → data → presentation`, Firestore + drift + Riverpod) funcionando ponta a ponta numa fatia pequena e real, antes de paralelizar o resto do MVP.

## Itens
1. **Setup do projeto**: `flutter create`, dependências (`flutter_riverpod`, `riverpod_generator`, `freezed`, `cloud_firestore`, `firebase_auth`, `firebase_storage`, `firebase_messaging`, `drift`, `flutter_secure_storage`, `local_auth`, `fl_chart`, `fpdart`, `mocktail`), `analysis_options.yaml` (`page_width: 100`, `always_use_package_imports`).
2. **`core/`**: tema base (`AppColors`/`AppSpacing`/`AppRadius`/`AppTextStyles`), `core/providers/core_providers.dart` com Firebase app + Firestore + drift database + secure storage expostos, `app_database.dart` (drift) com schema v1 vazio.
3. **`auth`**: tela de login (e-mail/senha), `AuthRepository` (Firebase Authentication), biometria opcional desde já se o esforço for baixo.
4. **`transacao`** (fatia vertical completa, cadastro manual apenas — sem importação ainda): entity, model, repository (Firestore + drift), usecase de salvar/listar, Notifier, `TransacaoListScreen` + `TransacaoFormScreen`, testes em todas as camadas.
5. **`sync`** mínimo: push de uma transação `pendingCreate` para o Firestore ao reconectar.
6. Validar que o pipeline inteiro funciona offline (cria local, aparece na lista) e online (sincroniza, aparece no console do Firestore).

## Fora desta sprint
Importação de CSV (`features/import/`), dashboard, metas — entram nas sprints seguintes do MVP, reaproveitando o padrão validado aqui.
