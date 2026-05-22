//Beatriz Naomi, Sofia de Sousa e Bruno Machado

class Founder {
  final String name;
  final String role;
  final String shortDescription;
  final double porcentagem;

  Founder({
    required this.name,
    required this.role,
    required this.shortDescription,
    required this.porcentagem,
  });

  factory Founder.fromJson(Map<String, dynamic> json) {
    return Founder(
      name: json['Nome']?.toString() ?? '',
      role: json['Funcao']?.toString() ?? '',
      shortDescription: json['DescricaoCurta']?.toString() ?? '',
      porcentagem: (json['Porcentagem'] ?? 0).toDouble(),
    );
  }
}

class ExternalMember {
  final String name;
  final String role;
  final double porcentagem;

  ExternalMember({
    required this.name,
    required this.role,
    required this.porcentagem,
  });

  factory ExternalMember.fromJson(Map<String, dynamic> json) {
    return ExternalMember(
      name: json['Nome']?.toString() ?? '',
      role: json['Funcao']?.toString() ?? '',
      porcentagem: (json['Porcentagem'] ?? 0).toDouble(),
    );
  }
}

class StartupDocument {
  final String title;
  final String url;
  final String type;

  StartupDocument({
    required this.title,
    required this.url,
    required this.type,
  });

  factory StartupDocument.fromJson(Map<String, dynamic> json) {
    return StartupDocument(
      title: json['Titulo']?.toString() ?? '',
      url: json['URL']?.toString() ?? '',
      type: json['Tipo']?.toString() ?? '',
    );
  }
}

// Nova classe para mapear cada Evento vindo da lista [Título, Descrição, Data, Local]
class StartupEvent {
  final String titulo;
  final String descricao;
  final String data;
  final String local;

  StartupEvent({
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.local,
  });

  factory StartupEvent.fromList(List<dynamic> list) {
  String dataFormatada = '';

  if (list.length > 2) {
    var dataRaw = list[2];
    
    // Verifica se veio como o Map de Timestamp do Firebase Functions {_seconds: ..., _nanoseconds: ...}
    if (dataRaw is Map && dataRaw.containsKey('_seconds')) {
      int segundos = dataRaw['_seconds'] ?? 0;
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(segundos * 1000).toLocal();
      
      // Formata manualmente para o padrão brasileiro (DD/MM/AAAA às HH:MM)
      String dia = dateTime.day.toString().padLeft(2, '0');
      String mes = dateTime.month.toString().padLeft(2, '0');
      String ano = dateTime.year.toString();
      String hora = dateTime.hour.toString().padLeft(2, '0');
      String minuto = dateTime.minute.toString().padLeft(2, '0');
      
      dataFormatada = "$dia/$mes/$ano às $hora:$minuto";
    } else {
      // Caso já seja uma String comum (como na segunda imagem)
      dataFormatada = dataRaw.toString();
    }
  }

  return StartupEvent(
    titulo: list.isNotEmpty ? list[0].toString() : '',
    descricao: list.length > 1 ? list[1].toString() : '',
    data: dataFormatada,
    local: list.length > 3 ? list[3].toString() : '',
  );
}
}

class Startup {
  final String id;
  final String name;
  final String description;
  final String longDescription;
  final String videoUrl;
  final String stage;
  final String tokenType;
  final double precoAtualToken;
  final double capitalCaptadoCent;
  final int totalTokensEmitidos;
  final List<Founder> founders;
  final List<ExternalMember> externalMembers;
  final List<StartupDocument> publicDocuments;
  final List<String> perguntas;
  final List<String> respostas;
  final List<StartupEvent> eventos; // Novo atributo inserido

  Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.longDescription,
    required this.videoUrl,
    required this.stage,
    required this.tokenType,
    required this.precoAtualToken,
    required this.capitalCaptadoCent,
    required this.totalTokensEmitidos,
    required this.founders,
    required this.externalMembers,
    required this.publicDocuments,
    required this.perguntas,
    required this.respostas,
    required this.eventos, // Requerido no construtor
  });

  factory Startup.fromJson(Map<String, dynamic> json) {
    var foundersJson = json['Fundadores'] as List? ?? [];
    List<Founder> parsedFounders = foundersJson
        .map((e) => Founder.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    var membrosJson = json['MembrosExterno'] as List? ?? [];
    List<ExternalMember> parsedMembros = membrosJson
        .map((e) => ExternalMember.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    var docsJson = json['DocumentosPublicos'] as List? ?? [];
    List<StartupDocument> parsedDocs = docsJson
        .map((e) => StartupDocument.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    var perguntasJson = json['Perguntas'] as List? ?? [];
    List<String> parsedPerguntas = perguntasJson.map((e) => e.toString()).toList();

    var respostasJson = json['Respostas'] as List? ?? [];
    List<String> parsedRespostas = respostasJson.map((e) => e.toString()).toList();

    // Mapeamento correto do seu Map de Eventos (Chave -> Array de 4 posições)
    List<StartupEvent> parsedEventos = [];
    var eventosMap = json['Eventos'];
    if (eventosMap is Map) {
      eventosMap.forEach((key, value) {
        if (value is List) {
          parsedEventos.add(StartupEvent.fromList(value));
        }
      });
    }

    return Startup(
      id: json['ID']?.toString() ?? json['id']?.toString() ?? '',
      name: json['NomeStartup']?.toString() ?? '',
      description: json['DescricaoCurta']?.toString() ?? '',
      longDescription: json['DescricaoLonga'] ?? '',
      videoUrl: json['DemoVideo']?.toString() ?? '',
      stage: _mapStage(json['Estagio']?.toString()),
      tokenType: _mapTokenType(json['tags'] is List ? List<dynamic>.from(json['tags']) : null),
      founders: parsedFounders,
      externalMembers: parsedMembros,
      publicDocuments: parsedDocs,
      perguntas: parsedPerguntas,
      respostas: parsedRespostas,
      eventos: parsedEventos, // Passando a lista processada para a instância
      precoAtualToken: (json['PrecoAtualToken'] ?? 0).toDouble(),
      capitalCaptadoCent: (json['CapitalCaptadoCent'] ?? 0).toDouble(),
      totalTokensEmitidos: (json['TotalTokensEmitidos'] ?? 0).toInt(),
    );
  }

  static String _mapStage(String? stage) {
    switch (stage?.toLowerCase()) {
      case 'nova': return 'Nova';
      case 'operacao': return 'Operação';
      case 'expansao': return 'Expansão';
      default: return 'Desconhecido';
    }
  }

  static String _mapTokenType(List<dynamic>? tags) {
    if (tags != null && tags.isNotEmpty) {
      return tags.first.toString();
    }
    return 'Geral';
  }
}