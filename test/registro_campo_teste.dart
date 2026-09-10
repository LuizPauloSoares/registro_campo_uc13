import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/features/registros/domain/registro_campo.dart';
import 'package:untitled/features/registros/domain/registro_campo.dart';

void main() {
    test('converter RegistroCampo em Map e reconstrói o objeto', () {
      final criadoEm = DateTime.utc(2026, 8, 11, 12);

      final registro = RegistroCampo(
        id: 'uuid-teste',
        titulo: 'Inspeção eletrica',
        descricao: 'Verificar o quadro do laboratório.',
        categoriaId: 1,
        dataVisita: DateTime.utc(2026, 8, 12),
        situacao: SituacaoRegistro.pendente,
        statusSincronizacao: StatusSincronizacao.pendente,
        criadoEm: criadoEm,
        atualizadoEm: criadoEm,
      );

      final reconstruido = RegistroCampo.fromMap(registro.toMap());

      expect(reconstruido.id, registro.id);
      expect(reconstruido.titulo, registro.titulo);
      expect(reconstruido.categoriaId, 1);
      expect(reconstruido.situacao, SituacaoRegistro.pendente);
      expect(reconstruido.dataVisita.toUtc(), registro.dataVisita);
    });
}