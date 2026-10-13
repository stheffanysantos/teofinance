import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teofinance/features/nome_feature/data/models/nome_entidade_model.dart';

/// Único ponto de acesso ao Firestore para esta entidade.
class NomeEntidadeRemoteDataSource {
  NomeEntidadeRemoteDataSource({required this.firestore, required this.uid});

  final FirebaseFirestore firestore;
  final String uid;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      firestore.collection('users').doc(uid).collection('nome_entidades');

  Future<List<NomeEntidadeModel>> obterTodas() async {
    final snapshot = await _colecao.get();
    return snapshot.docs.map(NomeEntidadeModel.fromFirestore).toList();
  }

  Future<NomeEntidadeModel> obterPorId(String idRemoto) async {
    final doc = await _colecao.doc(idRemoto).get();
    if (!doc.exists) {
      throw StateError('Documento $idRemoto não encontrado em nome_entidades.');
    }
    return NomeEntidadeModel.fromFirestore(doc);
  }

  /// Retorna o idRemoto (gerado pelo Firestore se for criação).
  Future<String> salvar(NomeEntidadeModel model) async {
    if (model.idRemoto != null) {
      await _colecao.doc(model.idRemoto).set(model.toFirestore());
      return model.idRemoto!;
    }
    final ref = await _colecao.add(model.toFirestore());
    return ref.id;
  }

  Future<void> excluir(String idRemoto) => _colecao.doc(idRemoto).delete();
}
