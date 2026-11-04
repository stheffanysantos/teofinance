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
    'contas',
  ];

  /// Coleções com valores em R$; os Perfis de Banco ficam de fora.
  static const colecoesFinanceiras = [
    'transacoes',
    'rendas',
    'metas',
    'parcelamentos',
    'orcamentos',
    'contas',
  ];

  static const _tamanhoDoLote = 400;

  Future<void> excluirDadosDoUsuario(String uid) async {
    final raiz = _firestore.collection('users').doc(uid);
    await _esvaziar(raiz, colecoes);
    await raiz.delete();
  }

  /// Apaga só os dados financeiros; a conta e os Perfis de Banco continuam.
  Future<void> excluirDadosFinanceiros(String uid) {
    return _esvaziar(_firestore.collection('users').doc(uid), colecoesFinanceiras);
  }

  Future<void> _esvaziar(DocumentReference<Map<String, dynamic>> raiz, List<String> nomes) async {
    for (final nome in nomes) {
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
  }
}
