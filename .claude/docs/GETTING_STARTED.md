# Getting Started

## Pré-requisitos
- Flutter SDK (canal stable) com suporte a Dart 3.x.
- Projeto Firebase criado (Firestore, Authentication, Storage, Cloud Messaging habilitados) com flavors `dev` e `prod` (FlutterFire CLI: `flutterfire configure`).
- Python 3 no PATH (para os hooks de `.claude/hooks/scripts/`).

## Primeira configuração
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutterfire configure   # gera firebase_options.dart por flavor
git config core.hooksPath .githooks
```

## Rodando o app
```bash
flutter run --flavor dev --dart-define=API_ENV=dev
```

## Rodando testes
```bash
flutter test
firebase emulators:exec --only firestore "flutter test test/firestore_rules_test.dart"
```

## Analisando o código
```bash
dart analyze --fatal-infos
```

## Antes de abrir uma feature nova
1. Leia `CLAUDE.md` (raiz) e `.claude/rules/*`.
2. Use `/create-feature <nome>` ou `.claude/prompts/create-feature.md` como ponto de partida.
3. Confirme em `.claude/plans/Features.md` a qual fase a feature pertence antes de começar.

## IA local (Gemma) — nota de desenvolvimento
O modelo Gemma quantizado não é versionado neste repositório (baixado sob demanda em runtime). Para desenvolver `features/ai_assistant/` localmente, siga as instruções específicas de setup do MediaPipe LLM Inference API documentadas no momento em que essa feature for iniciada (Fase 4) — ainda não implementadas neste bootstrap.
