import 'package:cloud_firestore/cloud_firestore.dart';

class Comentario {
  final String id;
  final String texto;
  final String nome;
  final String uid;
  final String publicacaoId;
  final DateTime? data;

  Comentario({
    required this.id,
    required this.texto,
    required this.nome,
    required this.uid,
    required this.publicacaoId,
    this.data,
  });

  factory Comentario.fromMap(Map<String, dynamic> map, String id) {
    return Comentario(
      id: id,
      texto: map['texto'] ?? '',
      nome: map['nome'] ?? '',
      uid: map['uid'] ?? '',
      publicacaoId: map['publicacaoId'] ?? '',
      data: map['data'] is Timestamp
          ? (map['data'] as Timestamp).toDate()
          : null,
    );
  }

  factory Comentario.fromDoc(DocumentSnapshot doc) {
    return Comentario.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }
}
