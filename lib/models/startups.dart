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

  StartupDocument({required this.title, required this.url, required this.type});

  factory StartupDocument.fromJson(Map<String, dynamic> json) {
    return StartupDocument(
      title: json['Titulo']?.toString() ?? '',
      url: json['URL']?.toString() ?? '',
      type: json['Tipo']?.toString() ?? '',
    );
  }
}

class Startup {
  final String id;
  final String name;
  final String description;
  final String stage;
  final String tokenType;
  final String longDescription;
  final List<Founder> founders;
  final List<ExternalMember> externalMembers;
  final String videoUrl;
  final List<StartupDocument> publicDocuments;
  final List<String> perguntas;
  final List<String> respostas;
  final double precoAtualToken;
  final double capitalCaptadoCent;
  final int totalTokensEmitidos;

  Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.stage,
    required this.tokenType,
    required this.longDescription,
    required this.founders,
    required this.externalMembers,
    required this.videoUrl,
    required this.publicDocuments,
    required this.perguntas,
    required this.respostas,
    required this.precoAtualToken,
    required this.capitalCaptadoCent,
    required this.totalTokensEmitidos,
  });

  factory Startup.fromJson(Map<String, dynamic> json) {
    var foundersJson = json['Fundadores'] as List? ?? [];
    List<Founder> parsedFounders = foundersJson.map((e) => Founder.fromJson(Map<String, dynamic>.from(e))).toList();

    var externalJson = json['MembrosExterno'] as List? ?? [];
    List<ExternalMember> parsedMembros = externalJson.map((e) => ExternalMember.fromJson(Map<String, dynamic>.from(e))).toList();

    var docsJson = json['DocumentosPublicos'] as List? ?? [];
    List<StartupDocument> parsedDocs = docsJson.map((e) => StartupDocument.fromJson(Map<String, dynamic>.from(e))).toList();

    var perguntasJson = json['Perguntas'] as List? ?? [];
    List<String> parsedPerguntas = perguntasJson.map((e) => e.toString()).toList();

    var respostasJson = json['Respostas'] as List? ?? [];
    List<String> parsedRespostas = respostasJson.map((e) => e.toString()).toList();

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
  if (tags == null || tags.isEmpty) return 'Geral';
  String firstTag = tags.first.toString();
  // Capitaliza a primeira letra:
  return "${firstTag[0].toUpperCase()}${firstTag.substring(1)}";
}
}