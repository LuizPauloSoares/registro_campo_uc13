import 'package:path/path.dart' as path;// o path é uma biblioteca para MANIPULAR strings de caminho
// (montar, quebrar, extrair partes) — mas NÃO cria pastas nem localiza arquivos de verdade

import 'package:sqflite/sqflite.dart';
import 'package:untitled/features/registros/domain/categoria.dart'; //biblioteca que permite usar o SGBD SQLite (que é embutido/local, sem servidor) dentro do Flutter/Dart.

//classe do banco que vai concentrar toda a configuraçao e acesso ao banco
class AppDatabase {

  //metodo construtor
  AppDatabase({//dentro das chaves sao os parametros
    DatabaseFactory?//um objeto da clase sqflite q serve como tipo de dados para abrir fechar e gerenciar banco de dados p ? eele pode ser nulo quem vai receber esse tipo de dado
    factory, // pode receber uma DatabaseFactory ou null.
    this.databasePath,
}): _factory = factory ?? databaseFactory;//"O campo _factory vai receber o valor de factory. Mas se factory for null (a pessoa não passou nada), então usa databaseFactory no lugar."

  //nome do arquivo que sera criado
  static const _databaseName = 'registro_campo.bd';

 //versao atual do banco se atualizar com 1 tabela a mais vc altera a versao pra 2
  static const _databaseVersion =1;

  final DatabaseFactory _factory;

  final String? databasePath;//caminho do banco local

  Database? _database;//vem da importaaçao e o banco ja aberto e pronto pra uso

  Future<Database> get database async{//"Eu prometo (Future) que vou te entregar um banco de dados (Database). Você acessa isso como uma propriedade (get database), sem parênteses. E por dentro, essa entrega pode demorar um pouco, então uso operações assíncronas (async)."

    final openedDatabase = _database;//database e o acesso ao banco local do celular

    if(openedDatabase != null && openedDatabase.isOpen){//is open e um metodo do sqflite
      return openedDatabase;//verifica se o valor do acesso nao e nulo e se esta aberto caso seja true ele retorna o banco antigo
    }

    final resolvedPath =//cria uma variavel para o caminho
        databasePath ?? //pega o caminho se for nulo
          path.join(//junta tudo em um so pergunta qual e a pasta padrao de banco pro celular
            await getDatabasesPath(),
            _databaseName,//recebe nome do arquivo

          );

    //caso for nulo ele deixa de ser agora pq vai receber um valor que e .Factory so ele sabe abrir o banco com a funçao dele, e pega o caminho quemontamos e abre o banco
    _database = await _factory.openDatabase(
      resolvedPath,

      //options e uma classe do sqflite que guarda configuraçoes de como o banco deve se comportar
      options: OpenDatabaseOptions(

        //compara com a versao se ja foi salva pra saber se precisa de atualizaçao
        version: _databaseVersion,

        //roda quando o banco e aberto
        onConfigure: (db) async{
          //comando q garante as relaçoes entre as tabelas
          await db.execute('PRAGMA foreign_keys = ON');
        },

        onCreate: _onCreate,//roda uma unica vez quando e criado para criar as tabelas
      ),
    );

    return _database!; //retorna o banco  criado
  }
  Future<void> _onCreate(Database db, int version) async{
    
    final batch = db.batch();//batch agrupa varios comandos do sql pra executar tudo de uma vez

batch.execute('''
  CREATE TABLE categorias (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE
  )
''');

batch.execute('''
  CREATE TABLE registros (
    id TEXT PRIMARY KEY,
    titulo TEXT NOT NULL,
    descricao TEXT NOT NULL DEFAULT '',
    categoria_id INTEGER NOT NULL,
    data_visita TEXT NOT NULL,
    situacao TEXT NOT NULL,
    foto_path TEXT,
    latitude REAL,
    longitude REAL,
    status_sync TEXT NOT NULL DEFAULT 'pendente',
    criado_em TEXT NOT NULL,
    atualizado_em TEXT NOT NULL,
    FOREIGN KEY (categoria_id)
      REFERENCES categorias (id)
      ON UPDATE CASCADE
      ON DELETE RESTRICT
  )
''');

batch.execute(
'CREATE INDEX idx_registros_data '
'ON registros (data_visita)',
);

batch.execute(
'CREATE INDEX idx_registros_sync '
'ON registros (status_sync)',
);

for (final nome in const [
'Inspeção',
'Manutenção preventiva',
'Manutenção corretiva',
'Visita técnica',
]) {
  batch.insert('categorias', {'nome':nome});
}
  await batch.commit(noResult: true);

  }
Future<void> close() async{
  final openedDatabase = _database;

  if(openedDatabase != null && openedDatabase.isOpen){
    await openedDatabase.close();
  }
  _database =null;
}

}