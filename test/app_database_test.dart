import 'dart:io'; //biblioteca de deixa o dart mexer no so dendo (pc, celular tanto faz)mexendo nos arquivos e pastas criando e apagando
import 'package:flutter_test/flutter_test.dart';//framework pra testes comparando o resultado do teste com o resulatado esperado
import 'package:path/path.dart' as path;//manipula caminhos de arquivo
import 'package:untitled/core/database/app_database.dart';//importa um codigo ja criado
import 'package:sqflite/sqflite.dart';//cria um vocabulario parecido com banco pro dart ter conhecimento dos nomes
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Directory temporaryDirectory;

  late AppDatabase appDatabase;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'registro_campo_database_test_',
    );

    appDatabase = AppDatabase(
      factory: databaseFactoryFfi,

      databasePath: path.join(
        temporaryDirectory.path,
        'test.db',
      ) ,
    );
  });

  tearDown(() async {
    await appDatabase.close();

    if (await temporaryDirectory.exists()){
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test(
    'abre o banco, ativa foreign_keys e reutiliza a conexão', 
    () async{
      final firstConnection = await appDatabase.database;

      final secondConnection = await appDatabase.database;

      final pragmaResult = await firstConnection.rawQuery(
        'PRAGMA foreign_keys',
        );

      expect(firstConnection.isOpen, isTrue,);

      expect(identical(firstConnection, secondConnection), isTrue,);

      expect(pragmaResult.single.values.single, 1,);  
    },
  );

  test('cria as tabelas e os indices esperados', () async {
    final db = await appDatabase.database;

    final tableRows = await db.rawQuery(
      """SELECT name 
         FROM sqlite_master 
         WHERE type = 'table'""",
    );

    final tableNames = tableRows
      .map((row) => row['name'])
      .toSet();

    final indexRows = await db.rawQuery(
      """SELECT name 
         FROM sqlite_master
         WHERE type = 'index'""",
      );

    final indexNames = indexRows
      .map((row) => row ['name'])
      .toSet();

    expect(
      tableNames,
      containsAll(
        <String>{
          'categorias',
          'registros',
        },
      ),
    );

    expect(
      indexNames,
       containsAll(
        <String>{
          """idx_registros_data""",
          """idx_registros_sync""",
          },
        ),
      );  
   });

   test('insere as quatro categorias inicias', () async {
    final db = await appDatabase.database;

    final categories = await db.query(
      'categorias',
      columns: <String>['nome'],
      orderBy: 'id',
    );

    final categoryNames = categories
      .map((row) => row['nome'])
      .toList();

    expect(
      categoryNames,
      <String>[
        'Inspeção',
        'Manutenção preventiva',
        'Manutenção corretiva',
        'Visita técnica',
      ],
    );  
  });

  test('rejeita registro com categoria inexistente',() async {
    final db = await appDatabase.database;

    final now = DateTime.utc(
      2026,
      8,
      15,
    ).toIso8601String();

    final insert = db.insert(
      'registros', 
      <String, Object>{
        'id': 'uuid-categoria-invalida',
        'titulo': 'Teste de integridade',
        'descricao': '',
        'categoria_id': 999,
        'data_visita': now,
        'situacao': 'pendente',
        'status_sync': 'pendente',
        'criado_em': now,
        'atualizado_em': now,
      },
    );

    await expectLater(
      insert,
      throwsA(
        isA<DatabaseException>(),
      ),
    );

  });

  test('close encerra a conexão',() async {
    final db = await appDatabase.database;
    
    await appDatabase.close();

    expect(
      db.isOpen,
      isFalse,
    ); 
  });

}