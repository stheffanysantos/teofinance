import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/usuario.dart';

/// Única classe da feature que chama o SDK do Firebase Authentication
/// diretamente (ver `.claude/rules/architecture.md`).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._auth);

  final fb.FirebaseAuth _auth;

  Usuario? get usuarioAtual => _toUsuario(_auth.currentUser);

  Stream<Usuario?> watchUsuarioAtual() => _auth.authStateChanges().map(_toUsuario);

  Future<Usuario> login({required String email, required String senha}) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: senha);
    return _toUsuario(credential.user)!;
  }

  Future<Usuario> cadastrar({required String email, required String senha}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: senha);
    return _toUsuario(credential.user)!;
  }

  Future<void> logout() => _auth.signOut();

  Usuario? _toUsuario(fb.User? user) {
    if (user == null) return null;
    return Usuario(uid: user.uid, email: user.email);
  }
}
