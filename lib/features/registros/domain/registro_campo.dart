// Define as situações possíveis de um registro de campo.
enum SituacaoRegistro {
  // O registro foi criado, mas a atividade ainda não começou.
  pendente,

  // A atividade está sendo realizada.
  emAndamento,

  // A atividade foi finalizada.
  concluida,
}

// Define os estados possíveis da sincronização do registro.
enum StatusSincronizacao {
  // O registro ainda precisa ser enviado ao servidor.
  pendente,

  // O registro foi sincronizado com sucesso.
  sincronizado,

  // Ocorreu um problema durante a sincronização.
  erro,
}

// Representa um registro de atividade realizada em campo.
class RegistroCampo {// Construtor constante da classe.
//
// Os parâmetros marcados como required são obrigatórios.
// Os demais são opcionais e podem receber null.
const RegistroCampo({
required this.id,
required this.titulo,
required this.descricao,
required this.categoriaId,
required this.dataVisita,
required this.situacao,
required this.statusSincronizacao,
required this.criadoEm,
required this.atualizadoEm,
this.categoriaNome,
this.fotoPath,
this.latitude,
this.longitude,
});

// Identificador único do registro, normalmente um UUID.
  final String id;

// Título informado pelo usuário.
  final String titulo;

// Descrição detalhada da atividade.
  final String descricao;

// Chave estrangeira que referencia a categoria no banco.
  final int categoriaId;

// Nome da categoria obtido por meio de um JOIN.
//
// Esse valor ajuda na exibição, mas não precisa ser gravado
// diretamente na tabela de registros.
  final String? categoriaNome;

// Data programada ou realizada da visita.
  final DateTime dataVisita;

// Situação atual da atividade.
  final SituacaoRegistro situacao;

// Caminho local da fotografia associada ao registro.
  final String? fotoPath;

// Coordenada geográfica opcional.
  final double? latitude;

// Coordenada geográfica opcional.
  final double? longitude;

// Estado atual da sincronização do registro.
  final StatusSincronizacao statusSincronizacao;

// Data e hora em que o registro foi criado.
  final DateTime criadoEm;

// Data e hora da última alteração.
  final DateTime atualizadoEm;

// Converte o objeto RegistroCampo para um mapa.
//
// O mapa utiliza os nomes das colunas da tabela SQLite
// e pode ser enviado aos métodos insert ou update.
  Map<String, Object?> toMap() {
    return {
      // Mantém o UUID como identificador do registro.
      'id': id,

      // Remove espaços desnecessários do início e do fim.
      'titulo': titulo.trim(),
      'descricao': descricao.trim(),

      // Armazena somente o identificador da categoria.
      'categoria_id': categoriaId,

      // Converte a data para UTC e depois para texto ISO 8601.
      'data_visita': dataVisita.toUtc().toIso8601String(),

      // Salva o nome interno do valor do enum.
      'situacao': situacao.name,

      // Os valores opcionais podem ser gravados como null.
      'foto_path': fotoPath,
      'latitude': latitude,
      'longitude': longitude,

      // Salva o nome interno do status de sincronização.
      'status_sync': statusSincronizacao.name,

      // As datas são armazenadas em UTC para evitar
      // diferenças causadas pelo fuso horário.
      'criado_em': criadoEm.toUtc().toIso8601String(),
      'atualizado_em': atualizadoEm.toUtc().toIso8601String(),
    };
  }

// Reconstrói um objeto RegistroCampo a partir de um mapa.
//
// Esse mapa pode representar uma linha retornada pelo SQLite.
  factory RegistroCampo.fromMap(Map<String, Object?> map) {
    return RegistroCampo(
      // Recupera os valores obrigatórios com seus respectivos tipos.
      id: map['id'] as String,
      titulo: map['titulo'] as String,

      // Utiliza uma string vazia caso a descrição esteja nula.
      descricao: map['descricao'] as String? ?? '',

      // Recupera a chave estrangeira da categoria.
      categoriaId: map['categoria_id'] as int,

      // Essa coluna pode ser adicionada ao resultado por um JOIN.
      categoriaNome: map['categoria_nome'] as String?,

      // Converte o texto ISO 8601 para DateTime e aplica o horário local.
      dataVisita: DateTime.parse(
        map['data_visita'] as String,
      ).toLocal(),

      // Localiza o valor do enum pelo nome salvo no banco.
      situacao: SituacaoRegistro.values.byName(
        map['situacao'] as String,
      ),

      // Recupera os valores opcionais.
      fotoPath: map['foto_path'] as String?,

      // O SQLite pode devolver números como int ou double.
      // Por isso, o valor é lido como num e convertido para double.
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),

      // Reconstrói o status de sincronização pelo nome.
      statusSincronizacao: StatusSincronizacao.values.byName(
        map['status_sync'] as String,
      ),

      // Reconstrói as datas e converte para o horário local.
      criadoEm: DateTime.parse(
        map['criado_em'] as String,
      ).toLocal(),
      atualizadoEm: DateTime.parse(
        map['atualizado_em'] as String,
      ).toLocal(),
    );
  }

// Cria uma nova instância alterando apenas os valores informados.
//
// Como os atributos são final, o objeto original não é modificado.
  RegistroCampo copyWith({
    String? titulo,
    String? descricao,
    int? categoriaId,
    DateTime? dataVisita,
    SituacaoRegistro? situacao,
    StatusSincronizacao? statusSincronizacao,
    DateTime? atualizadoEm,
  }) {
    return RegistroCampo(
      // O identificador original é preservado.
      id: id,

      // Utiliza o novo valor quando ele for informado.
      // Caso contrário, mantém o valor do objeto atual.
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoriaId: categoriaId ?? this.categoriaId,

      // Mantém os valores que não fazem parte dos parâmetros do copyWith.
      categoriaNome: categoriaNome,
      dataVisita: dataVisita ?? this.dataVisita,
      situacao: situacao ?? this.situacao,
      fotoPath: fotoPath,
      latitude: latitude,
      longitude: longitude,

      // Atualiza o status somente quando um novo valor for recebido.
      statusSincronizacao:
      statusSincronizacao ?? this.statusSincronizacao,

      // A data de criação nunca é alterada.
      criadoEm: criadoEm,

      // A data de atualização pode receber um novo valor.
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}

// Adiciona uma propriedade de apresentação ao enum SituacaoRegistro.
extension SituacaoRegistroLabel on SituacaoRegistro {
  // Retorna um texto amigável para ser mostrado na interface.
  String get label {
    return switch (this) {
      SituacaoRegistro.pendente => 'Pendente',
      SituacaoRegistro.emAndamento => 'Em andamento',
      SituacaoRegistro.concluida => 'Concluída',
    };
  }
}