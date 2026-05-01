enum Filtro { nova, Operacao, Expansao }
//card de uma startup do catalogo
class StartupCardCatalog {
  final String nome;
  final String descricaoCurta;
  final String tokenNome;
  final Filtro filtro;

  StartupCardCatalog({
    required this.nome,
    required this.descricaoCurta,
    required this.tokenNome,
    required this.filtro,
  });
}

class StartupList {
  final int count;
  final List<StartupCardCatalog> data;
  // talvez criar lista de filtros?
  StartupList({
    required this.count,
    required this.data,
  });

}
