import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ideia.dart';

class IdeiasService {
  final _collection = FirebaseFirestore.instance.collection('ideias');

  Stream<List<Ideia>> acompanhar() => _collection.snapshots().map((snapshot) {
        final ideias = snapshot.docs.map(Ideia.fromDocument).toList();
        ideias.sort((a, b) {
          final votos = b.votos.compareTo(a.votos);
          return votos != 0 ? votos : a.id.compareTo(b.id);
        });
        return ideias;
      });

  Future<void> cadastrar(String titulo, String descricao, String autor) async {
    await _collection.add({
      'titulo': titulo.trim(),
      'descricao': descricao.trim(),
      'autor': autor.trim(),
      'votos': 0,
    });
  }

  // Incremento atômico: votos simultâneos não sobrescrevem uns aos outros.
  Future<void> votar(String id) =>
      _collection.doc(id).update({'votos': FieldValue.increment(1)});

  Future<void> excluir(String id) => _collection.doc(id).delete();
}
