import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Conta do usuário no Firebase Authentication, só no que a LGPD precisa.
abstract class LgpdContaDataSource {
  String? get uid;
  String? get email;

  /// Confirma a senha atual; o Firebase exige login recente para apagar a conta.
  Future<void> reautenticar(String senha);

  Future<void> excluirConta();
}

class LgpdContaFirebaseDataSource implements LgpdContaDataSource {
  LgpdContaFirebaseDataSource(this._auth);

  final fb.FirebaseAuth _auth;

  @override
  String? get uid => _auth.currentUser?.uid;

  @override
  String? get email => _auth.currentUser?.email;

  @override
  Future<void> reautenticar(String senha) async {
    final usuario = _auth.currentUser;
    if (usuario == null || usuario.email == null) {
      throw fb.FirebaseAuthException(code: 'no-current-user');
    }
    await usuario.reauthenticateWithCredential(
      fb.EmailAuthProvider.credential(email: usuario.email!, password: senha),
    );
  }

  @override
  Future<void> excluirConta() async {
    final usuario = _auth.currentUser;
    if (usuario == null) throw fb.FirebaseAuthException(code: 'no-current-user');
    await usuario.delete();
  }
}
