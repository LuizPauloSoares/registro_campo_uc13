import 'package:cloud_firestore/cloud_firestore.dart';//// importa os tipos do Cloud Firestore, permitindo ler e escrever dados no banco do Firebase abre uma porta pra falar com a nuvem

import '../../../core/auth/auth_service.dart';//importa o serviço que fornece a identidade do usuario

import '../domain/registro_campo.dart';//importa o modelo de dominio no registro

import 'registro_remote_mapper.dart';//importa o mapper responsavel pela conversao entre registro campo e os formatos aceitos pelo firestore

/// Classe responsável por fazer a comunicação direta com o Firestore,
/// realizando as operações de enviar, remover e consultar documentos
/// da coleção de registros na nuvem.
///
/// Utiliza a instância já conectada do Firebase (FirebaseFirestore.instance)
/// e o [RegistroRemoteMapper] para converter os dados entre o modelo
/// [RegistroCampo] e o formato aceito pelo Firestore.
class FirestoreRegistroDataSource{

  FirestoreRegistroDataSource(

      this._firestore, //conversa com o banco firestore
      this._authService,//sabe quem e o usuario logado atualmente
      );

  final FirebaseFirestore _firestore;// guarda a conexão com o banco

  final AuthService _authService; // guarda o serviço de autenticação



  CollectionReference<Map<String, dynamic>> get _registros {
    final uid = _authService.uid;

    //Pega o uid do usuário logado. Se for nulo, lança erro. Se não for nulo,
    // retorna a referência da coleção registros daquele usuário (mas ainda não
    // guarda nada — só aponta pra onde os dados vão ser guardados/lidos).

    if(uid == null){
      throw StateError("usuario não autenticado.");
    }
    return _firestore
        .collection('usuarios')
        .doc(uid)
        .collection('registros');
  }

  Future<void> enviar(RegistroCampo registro) async{
    await _registros.doc(registro.id).set(
      RegistroRemoteMapper.tofirestore(registro),

      SetOptions(merge: true),//"Ele atualiza apenas os campos que você mandou, e mantém os outros campos que já existiam no documento, sem apagar nada.
    );
  }

  Future<void> remover(String id){

    return _registros.doc(id).delete();
  }

  Future<List<RegistroCampo>> listar() async{

    final snaoshot = await _registros.orderBy('atualizadoEm').get();

    return snaoshot.docs
        .map(
        (doc) => RegistroRemoteMapper.fromFirestore(
          doc.data(),
        ),
    )
        .toList();
  }
}