import 'package:flutter/material.dart';//importa componentes visuais principais do flutter
import 'package:untitled/features/registros/domain/registro_campo.dart';

import 'core/database/app_database.dart';//importa a classe responsavel por abir e configurar a conecçao com o banco sqllite

import 'features/registros/data/registro_dao.dart';//importa a dao q executa os comamndos aql relacionados a registros

import 'features/registros/data/sqlite_registro_repository.dart';//importa a implementaçao do repositorio q utiliza a registroDao e o sqlite

import 'features/registros/domain/registro_repository.dart';//importa  o contrrato q defi ne as operaçoes disponiveis para regisro

import 'features/registros/presentation/registro_list_page.dart';//importa a primeira pagina exibida pelo app

void main(){

  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();

  final dao = RegistroDao(database);

  final repository = SqliteRegistroRepository(dao);

  runApp(
    RegistroCampoApp(repository: repository),
  );
}

class  RegistroCampoApp extends StatelessWidget{

  const  RegistroCampoApp({
    super.key,
    required this.repository,
});

  final RegistroRepository repository;

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Registro de Campo',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'RobotoUC13',

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1565c0),),

        useMaterial3: true,

        inputDecorationTheme: const InputDecorationTheme(

          border: OutlineInputBorder(),
        ),
      ),

      home: RegistroListPage(
        repository: repository,
      ),
    );
  }
}
