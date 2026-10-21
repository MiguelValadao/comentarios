import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/publicacao.dart';

class PublicacaoService {
  final CollectionReference _colecao =
      FirebaseFirestore.instance.collection('publicacoes');

  Stream<List<Publicacao>> listar() {
    return _colecao
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(Publicacao.fromDoc).toList());
  }

  Future<void> criar({
    required String texto,
    required String nomeAutor,
    required String uidAutor,
  }) {
    return _colecao.add({
      'texto': texto,
      'nomeAutor': nomeAutor,
      'uidAutor': uidAutor,
      'data': FieldValue.serverTimestamp(),
    });
  }

  Future<void> excluir(String id) {
    return _colecao.doc(id).delete();
  }
}
