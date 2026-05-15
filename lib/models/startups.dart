//Bruno Machado
//Beatriz Naomi e Sofia
class Founder {
  final String name;
  final String role;
  final String shortDescription;

  Founder({
    required this.name,
    required this.role,
    required this.shortDescription,
  });

  factory Founder.fromJson(Map<String, dynamic> json) {
    return Founder(
      name: json['Nome']?.toString() ?? '',
      role: json['Funcao']?.toString() ?? '',
      shortDescription: json['DescricaoCurta']?.toString() ?? '',
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
  final String videoUrl;
  final List<StartupDocument> publicDocuments;

  Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.stage,
    required this.tokenType,
    required this.longDescription,
    required this.founders,
    required this.videoUrl,
    required this.publicDocuments, 
  });

  factory Startup.fromJson(Map<String, dynamic> json) {

    var foundersList = json['Fundadores'] as List? ?? [];
    List<Founder> parsedFounders = foundersList
        .map((f) => Founder.fromJson(Map<String, dynamic>.from(f)))
        .toList();

    var docsList = json['DocumentosPublicos'] as List? ?? [];
    List<StartupDocument> parsedDocs = docsList
        .map((d) => StartupDocument.fromJson(Map<String, dynamic>.from(d)))
        .toList();

    return Startup(
      id: json['ID']?.toString() ?? '',
      name: json['NomeStartup']?.toString() ?? '',
      description: json['DescricaoCurta']?.toString() ?? '',
      longDescription: json['DescricaoLonga']?.toString() ?? '',
      videoUrl: json['DemoVideo']?.toString() ?? '',
      stage: _mapStage(json['Estagio']?.toString()),
      tokenType: _mapTokenType(json['tags'] is List ? List<dynamic>.from(json['tags']) : null),
      founders: parsedFounders,
      publicDocuments: parsedDocs, 
    );
  }

  static String _mapStage(String? stage) {
    switch (stage?.toLowerCase()) {
      case 'nova': return 'Nova';
      case 'operacao': return 'Operação';
      case 'expansao': return 'Expansão';
      case 'validacao': return 'Validação';
      default: return 'Desconhecido';
    }
  }

  static String _mapTokenType(List<dynamic>? tags) {
    if (tags == null || tags.isEmpty) return 'N/A';
    return tags.first.toString().toUpperCase();
  }
}