import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teofinance/features/parcelamento/data/models/parcelamento_model.dart';

abstract class ParcelamentoRemoteDataSource {
  Future<void> salvarParcelamento(ParcelamentoModel parcelamento);
  Future<ParcelamentoModel> obterPorId(String parcelamentoId);
  Future<List<ParcelamentoModel>> listarPorUsuario(String userId);
  Future<void> deletarParcelamento(String parcelamentoId);
}

class ParcelamentoRemoteDataSourceImpl implements ParcelamentoRemoteDataSource {
  final FirebaseFirestore firestore;

  ParcelamentoRemoteDataSourceImpl(this.firestore);

  static const _collectionPath = 'parcelamentos';

  @override
  Future<void> salvarParcelamento(ParcelamentoModel parcelamento) async {
    await firestore.collection(_collectionPath).doc(parcelamento.id).set(
          parcelamento.toJson(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<ParcelamentoModel> obterPorId(String parcelamentoId) async {
    final doc = await firestore
        .collection(_collectionPath)
        .doc(parcelamentoId)
        .get();

    if (!doc.exists) {
      throw Exception('Parcelamento não encontrado');
    }

    return ParcelamentoModel.fromJson(doc.data()!);
  }

  @override
  Future<List<ParcelamentoModel>> listarPorUsuario(String userId) async {
    final snapshot = await firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => ParcelamentoModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> deletarParcelamento(String parcelamentoId) async {
    await firestore.collection(_collectionPath).doc(parcelamentoId).delete();
  }
}
