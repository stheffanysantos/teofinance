import 'package:cloud_firestore/cloud_firestore.dart';

/// Única classe da feature que fala com o Firestore.
class LgpdRemoteDataSource {
  LgpdRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Coleções sob `users/{uid}`. Deve acompanhar o `SyncEngine`: o teste
  /// `lgpd_repository_impl_test.dart` envia todas as entidades pelo engine e
  /// confere que nada sobra depois da exclusão.
  static const colecoes = [
    'transacoes',
    'perfis_banco',
    'rendas',
    'metas',
    'parcelamentos',
    'orcamentos',
  ];

  static const _tamanhoDoLote = 400;

  Future<void> excluirDadosDoUsuario(String uid) async {
    final raiz = _firestore.collection('users').doc(uid);

    for (final nome in colecoes) {
      while (true) {
        final pagina = await raiz.collection(nome).limit(_tamanhoDoLote).get();
        if (pagina.docs.isEmpty) break;

        final lote = _firestore.batch();
        for (final doc in pagina.docs) {
          lote.delete(doc.reference);
        }
        await lote.commit();
      }
    }
    await raiz.delete();
  }
}
