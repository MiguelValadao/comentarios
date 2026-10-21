import 'package:flutter_test/flutter_test.dart';

import 'package:comentarios/models/comentario.dart';
import 'package:comentarios/models/publicacao.dart';
import 'package:comentarios/utils/formatar_data.dart';

void main() {
  test('Publicacao.fromMap preenche todos os campos', () {
    final publicacao = Publicacao.fromMap({
      'texto': 'Qual o melhor jogo de 2026?',
      'nomeAutor': 'Pedro',
      'uidAutor': 'uid-pedro',
    }, 'pub1');

    expect(publicacao.id, 'pub1');
    expect(publicacao.texto, 'Qual o melhor jogo de 2026?');
    expect(publicacao.nomeAutor, 'Pedro');
    expect(publicacao.uidAutor, 'uid-pedro');
    expect(publicacao.data, isNull);
  });

  test('Comentario.fromMap preenche todos os campos', () {
    final comentario = Comentario.fromMap({
      'texto': 'Eu prefiro jogos de aventura!',
      'nome': 'Maria',
      'uid': 'uid-maria',
      'publicacaoId': 'pub1',
    }, 'com1');

    expect(comentario.id, 'com1');
    expect(comentario.texto, 'Eu prefiro jogos de aventura!');
    expect(comentario.nome, 'Maria');
    expect(comentario.uid, 'uid-maria');
    expect(comentario.publicacaoId, 'pub1');
  });

  test('formatarData retorna vazio quando data é nula', () {
    expect(formatarData(null), '');
    expect(formatarData(DateTime(2026, 10, 19, 14, 30)), '19/10/2026 14:30');
  });
}
