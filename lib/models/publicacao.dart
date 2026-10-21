import 'package:cloud_firestore/cloud_firestore.dart';

class Publicacao {
  final String id;
  final String texto;
  final String nomeAutor;
  final String uidAutor;
  final DateTime? data;

  Publicacao({
    required this.id,
    required this.texto,
    required this.nomeAutor,
    required this.uidAutor,
    this.data,
  });

  factory Publicacao.fromMap(Map<String, dynamic> map, String id) {
    return Publicacao(
      id: id,
      texto: map['texto'] ?? '',
      nomeAutor: map['nomeAutor'] ?? '',
      uidAutor: map['uidAutor'] ?? '',
      data: map['data'] is Timestamp
          ? (map['data'] as Timestamp).toDate()
          : null,
    );
  }

  factory Publicacao.fromDoc(DocumentSnapshot doc) {
    return Publicacao.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }
}
