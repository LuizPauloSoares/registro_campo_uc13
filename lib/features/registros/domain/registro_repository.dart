import 'categoria.dart';//importea a classe categoria

import 'registro_campo.dart';// importa o modelo pra ser utilizado nas operaçoes de repo

//abstraçao contrato q deve ser seguido em q classe tiver contrato com ela deve seguir os metodos mas na abstraçao nao determina como sera executado
//impleemtaçao podera utilizar o sqlite uma api rmota dados em memoria ou qualquer outra fonte sem alterar qume utiliza o repo
abstract interface class RegistroRepository {

  //resultado assincrono porque a consulta pode depender do banco local e do banco em nuvem  arquivo etc
  //quando nao Houver registros devera retornar uma lista vazia
  Future<List<RegistroCampo>> listar();

  //procura um registro pelo id retorna ele caso nao encontrar retorna null
  Future<RegistroCampo?> buscarPorID(String id);

  //devolve categorias dispo no formulario  cada linha encontrada sera representada por um objeto categoria
  Future<List<Categoria>> listarCategorias();

  //novo registro dadps persistidos assincrona
  Future<void> inserir(RegistroCampo registro);

  //atualiza ja existente deve utilizar id presente no objeto para localizar e modificar
  Future<void> atualizar (RegistroCampo registro);

  //solicita a exclusao do registro com id informado
  //caso noa existir deve ter uma exeçao para falha na operaçao
  Future<void> remover(String id);
}