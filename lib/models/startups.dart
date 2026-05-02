//Sofia de Sousa (uma parte feita pela Beatriz)

//Dados da startup, mapeados do backend
//Os dados sõa em final porque o objeto não deve mudar depois dele ser criado(evitando bugs)
class Startup {
  final String id;
  final String name;
  final String description;
  final String stage;
  final String tokenType;

  //Required garante que nenhum campo venha vazio
  Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.stage,
    required this.tokenType,
  });


  //Transforma o json do back em um objeto (vem do json (fromJson))
  factory Startup.fromJson(Map<String, dynamic> json) {
    return Startup(
      id: json['ID'] ?? '',
      name: json['NomeStartup'] ?? '',
      description: json['DescricaoCurta'] ?? '',
      stage: _mapStage(json['Estagio']),
      tokenType: _mapTokenType(json['tags']),
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
