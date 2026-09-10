import '../domain/categoria.dart';//importa a classecategoria com categorias dispo

import '../domain/registro_campo.dart';//importa o modelo principal qu sera manipulado pelo repositorio

import '../domain/registro_repository.dart';//importa oq a classe deve emplementar

import 'registro_dao.dart';//importa a dao responsavel para enviar comandos ao sqlLite

class SqliteRegistroRepository implements RegistroRepository {

  const SqliteRegistroRepository(this._dao);

  final RegistroDao _dao;

  @override
  Future<List<RegistroCampo>> listar() {
    return _dao.listar();

  }

  @override
  Future<RegistroCampo?> buscarPorID(String id) {
    return _dao.buscarPorID(id);
  }

  @override
  Future<List<Categoria>> listarCategorias() {
    return _dao.listarCategorias();
  }

  @override
  Future<void> inserir(RegistroCampo registro) {
    return _dao.inserir(registro);
  }

  @override
  Future<void> atualizar(RegistroCampo registro) {
    return _dao.atualizar(registro);
  }

  @override
  Future<void> remover(String id) {
    return _dao.remover(id);
  }
}