//Sofia de Sousa (uma parte feita pela Beatriz)


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

//Dados da startup, mapeados do backend
//Os dados sõa em final porque o objeto não deve mudar depois dele ser criado(evitando bugs)
class Startup {
  final String id;
  final String name;
  final String description;
  final String stage;
  final String tokenType;
  final String longDescription;
  final List<Founder> founders;
  final String videoUrl;
  

  //Required garante que nenhum campo venha vazio
  Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.stage,
    required this.tokenType,
    required this.longDescription,
    required this.founders,
    required this.videoUrl
  });


  //Transforma o json do back em um objeto (vem do json (fromJson))
  factory Startup.fromJson(Map<String, dynamic> json) {

    var foundersList = json['Fundadores'] as List? ?? [];
    List<Founder> parsedFounders = foundersList
        .map((f) => Founder.fromJson(Map<String, dynamic>.from(f)))
        .toList();

    return Startup(
      id: json['ID']?.toString() ?? '',
      name: json['NomeStartup']?.toString() ?? '',
      description: json['DescricaoCurta']?.toString() ?? '',
      longDescription: json['DescricaoLonga']?.toString() ?? '',
      videoUrl: json['DemoVideo']?.toString() ?? '',
      stage: _mapStage(json['Estagio']?.toString()),
      tokenType: _mapTokenType(json['tags'] is List ? List<dynamic>.from(json['tags']) : null),
      founders: parsedFounders, // Lista já convertida
    );
  }

  

  //  Converte estágio do backend 
   // Exemplo - vem do backend "Estagio": "operacao"
     // Vai para o UI como "Operação"

  static String _mapStage(String? stage) {

    // Garante que o estágio seja comparado em minúsculas para evitar erros de capitalização
    switch (stage?.toLowerCase()) {
      case 'nova':
        return 'Nova';
      case 'operacao':
        return 'Operação';
      case 'expansao':
        return 'Expansão';
      case 'validacao':
        return 'Validação';
      default:
        return 'Desconhecido';
    }
  }

  //  pega primeira tag como tipo de token
  static String _mapTokenType(List<dynamic>? tags) {
    if (tags == null || tags.isEmpty) return 'N/A';

    // Pega a primeira tag e transforma ou converte para uma string a deixando em maiúscula
    return tags.first.toString().toUpperCase();
  }
}
