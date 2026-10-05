import 'package:cloud_firestore/cloud_firestore.dart';

class Ideia {
  final String id;
  final String titulo;
  final String descricao;
  final String autor;
  final int votos;

  const Ideia(
      {required this.id,
      required this.titulo,
      required this.descricao,
      required this.autor,
      required this.votos});

  factory Ideia.fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Ideia(
      id: doc.id,
      titulo: data['titulo'] as String,
      descricao: data['descricao'] as String,
      autor: data['autor'] as String,
      votos: (data['votos'] as num).toInt(),
    );
  }
}
