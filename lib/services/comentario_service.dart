import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comentario.dart';

class ComentarioService {
  final CollectionReference _colecao =
      FirebaseFirestore.instance.collection('comentarios');

  Stream<List<Comentario>> listarPorPublicacao(String publicacaoId) {
    return _colecao
        .where('publicacaoId', isEqualTo: publicacaoId)
        .snapshots()
        .map((snapshot) {
      final comentarios = snapshot.docs
          .map(Comentario.fromDoc)
          .toList();
      comentarios.sort((a, b) {
        if (a.data == null && b.data == null) return 0;
        if (a.data == null) return 1;
        if (b.data == null) return -1;
        return a.data!.compareTo(b.data!);
      });
      return comentarios;
    });
  }

  Future<void> enviar({
    required String texto,
    required String nome,
    required String uid,
    required String publicacaoId,
  }) {
    return _colecao.add({
      'texto': texto,
      'nome': nome,
      'uid': uid,
      'publicacaoId': publicacaoId,
      'data': FieldValue.serverTimestamp(),
    });
  }

  Future<void> excluir(String id) {
    return _colecao.doc(id).delete();
  }
}
