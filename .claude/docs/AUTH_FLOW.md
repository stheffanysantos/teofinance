# Fluxo de Autenticação

## Visão geral
1. Usuário abre o app → `SplashScreen` verifica sessão Firebase existente (`FirebaseAuth.instance.currentUser`).
2. Sem sessão → `LoginScreen` (e-mail/senha via `FirebaseAuth.signInWithEmailAndPassword`; cadastro via `createUserWithEmailAndPassword`).
3. Com sessão válida → checa se biometria (`local_auth`) está habilitada; se sim, exige confirmação biométrica antes de liberar o dashboard.
4. Biometria também é exigida antes de confirmar ações sensíveis específicas (ex.: exportar/excluir todos os dados — LGPD).

## Onde cada responsabilidade mora
- `features/auth/domain/` — `AuthRepository` (contrato), usecases (`LoginUseCase`, `CadastrarUseCase`, `LogoutUseCase`, `VerificarBiometriaUseCase`).
- `features/auth/data/` — `AuthRemoteDataSource` (Firebase Authentication), `BiometriaLocalDataSource` (`local_auth` + `flutter_secure_storage` para a preferência "biometria habilitada").
- `features/auth/presentation/` — `AuthNotifier` (estado de sessão), `LoginScreen`, `BiometriaGateScreen`.

## Sessão e token
- O SDK do Firebase Authentication gerencia o token de sessão internamente (refresh automático) — este app não implementa gestão de token manual.
- Nenhum dado de sessão é persistido fora do mecanismo do próprio SDK + `flutter_secure_storage` (só a preferência de biometria, nunca a senha).

## Regras de segurança associadas
Ver `.claude/rules/security.md`. O UID do Firebase Authentication (`request.auth.uid`) é a base de toda regra do Firestore — nenhuma coleção de dado financeiro é legível/gravável sem essa checagem.
