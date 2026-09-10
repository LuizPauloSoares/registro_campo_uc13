import 'package:sqflite/sqflite.dart';//importa para executar operaçoes no banco sql lite

import '../../../core/database/app_database.dart';// importa a classe q e responsavel por abrir a conecçao com o banco

import '../domain/categoria.dart';
import '../domain/registro_campo.dart';

//responsavel pelas operaçoes reacionadas ao banco
//DATA ACCESS OBJECT contem comandos enviados ao sql lite dessa forma somente ele no projeto conhece os detalhes da tabela e operaçoes do sql
class RegistroDao{

  //recebe o gerenciador do bd por meio do construtor
  const RegistroDao(this._appDatabase);

  //refere ao objeto que fornece a conexao com o banco  o _ informa que e um atributo privado
  final AppDatabase _appDatabase;

  //consulta as categorias cadastradas retorna um valor List
  Future<List<Categoria>> listarCategorias() async{
    //solicita a conecçao aberta com o banco
    final db =await _appDatabase.database;

    //query e qualquer tipo de select
    // sintaxe vc cria uma variavel result q vai fazer a operaçao vai conecta com o banco e vai fazer a query primeiro e a tabela depois oq vc quer obter
    final result = await db.query('categorias',
    orderBy: 'nome ASC',
    );

    //retorna um resultado
    //transforma cada map em um objeto categoria
    //growable false cria uma lista tamanho fixo
    return result
        .map(Categoria.fromMap)
        .toList(growable: false);
  }

  //consulta todos os registros cadastrados
  Future<List<RegistroCampo>> listar() async{

    //solicita a conecçao aberta com o banco
    final db =await _appDatabase.database;

    //rawquery permite nos escrever o proprio select ao inves da consulta propria do dart
    final result = await db.rawQuery('''
    SELECT r.*, 
    c.nome AS categoria_nome
    FROM registros r
    INNER JOIN categorias c ON c.id = r.categoria_id
    ORDER BY r.data_visita DESC, r.criado_em DESC 
    ''');

    //transforma em um objeto registro campo
    return result
        .map(RegistroCampo.fromMap)
        .toList(growable: false);

  }

  Future<RegistroCampo?> buscarPorID (String id) async{
    //solicita a conecçao aberta com o banco
    final db =await _appDatabase.database;

    final result = await db.rawQuery(
      '''
      SELECT r.*, c.nome AS categoria_nome
      FROM registros r
      INNER JOIN categorias c ON c.id = r.categoria_id
      WHERE r.id = ?
      LIMIT 1
      ''',
      [id],
    );

    if(result.isEmpty) {
      return null;
    }
    return RegistroCampo.fromMap(result.first);
  }

  Future<void> inserir(RegistroCampo registro) async{

    final db =await _appDatabase.database;

    await db.insert('registros',
        registro.toMap(),

        conflictAlgorithm: ConflictAlgorithm.abort,
    );

  }
//atualiza um registro
  Future<void> atualizar( RegistroCampo registro) async{

    final db =await _appDatabase.database;

    final affectedRows =await db.update('registros',
        registro.toMap(),

        where: 'id = ?',
        whereArgs: [registro.id],
    );

    if(affectedRows !=1){
      throw StateError('registro não encontrado para realizar atualização',);
    }
  }

  Future<void> remover(String id) async{

    final db =await _appDatabase.database;

    //executa o delete do id informado e guarda a qnt de linhas afetadas
    final affectedRows =await db.delete(
      'registros',
      where:  'id = ?',//remove somente a linha correspondente ao UUID
      whereArgs: [id],//troca o ponto de interrogaçao pelo parametro
    );

    if(affectedRows !=1){//caso nenhum registro possuir identificador  uma falha sera lançada
      throw StateError('registro não encontrado para realizar a exclusao ',);
      }
    }
  }


