/// Usuário autenticado — projeção mínima de `firebase_auth.User` para o
/// domínio não depender do SDK do Firebase (ver `.claude/rules/architecture.md`).
class Usuario {
  const Usuario({required this.uid, required this.email});

  final String uid;
  final String? email;
}
