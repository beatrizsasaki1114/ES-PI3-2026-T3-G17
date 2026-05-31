// Beatriz Naomi
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/token_price_chart.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Centraliza todo contato entre Flutter e Firebase.
/// Nenhum outro arquivo do Flutter acessa Firebase diretamente.
class DashboardServices {

  // Busca ofertas + compras das últimas 24h, agrupa por hora e retorna
  // um HistoricoPoint por hora 
  Future<List<HistoricoPoint>> fetchHistoricoDiario(String startupId) async {
    final resultados = await Future.wait([
      _fetchPorHora(startupId, 'listOfertas'),
      _fetchPorHora(startupId, 'listComprasDiretas'),
    ]);

    final ofertas = resultados[0]; 
    final compras = resultados[1];

    if (ofertas.isEmpty && compras.isEmpty) return [];

    // Funde as duas fontes na mesma hora com média ponderada
    final fundido = <String, _DadoHora>{};
    for (final entry in [...ofertas.entries, ...compras.entries]) {
      final chave = entry.key;
      final dado  = entry.value;
      if (fundido.containsKey(chave)) {
        fundido[chave] = _DadoHora(
          dataHora:   fundido[chave]!.dataHora,
          somaValor:  fundido[chave]!.somaValor  + dado.somaValor,
          somaTokens: fundido[chave]!.somaTokens + dado.somaTokens,
        );
      } else {
        fundido[chave] = dado;
      }
    }

    // Ordena cronologicamente e converte em HistoricoPoint
    final pontos = fundido.entries
        .map((e) => HistoricoPoint(
              data:       e.value.dataHora,
              precoMedio: e.value.somaValor / e.value.somaTokens,
            ))
        .toList()
      ..sort((a, b) => a.data.compareTo(b.data));

    return pontos;
  }

  //Busca PrecoAtualToken e PrecoAnteriorToken de uma startup
  Future<({double precoAtual, double precoAnterior})> buscarPrecosDaStartup(
      String startupName) async {
    try {
      final result = await FirebaseFunctions
          .instanceFor(region: 'southamerica-east1',)
          .httpsCallable('getStartupPrices')
          .call({'startupName': startupName});
 
      final data = Map<String, dynamic>.from(result.data as Map);
      return (
        precoAtual:    (data['precoAtual']    as num? ?? 0).toDouble(),
        precoAnterior: (data['precoAnterior'] as num? ?? 0).toDouble(),
      );
    } catch (_) {
      // Em caso de erro retorna zeros — widget mostra "sem dados"
      return (precoAtual: 0.0, precoAnterior: 0.0);
    }
  }

 // Usada para dashboards 1S/1M/6M/1A
  // Retorna um HistoricoPoint por dia com o preço médio salvo no HistoricoDiario
  Future<List<HistoricoPoint>> fetchHistoricoSalvo(
      String startupId, String periodo) async {
    try {
      final result = await FirebaseFunctions
      .instanceFor(region: 'southamerica-east1',)
          .httpsCallable('listHistorico')
          .call({'startupId': startupId, 'periodo': periodo});

       // Converte o resultado para Map tipado
      final response = Map<String, dynamic>.from(result.data as Map);
      // Extrai o array de dados, retorna uma lista vazia se não houver
      final List items = response['data'] as List? ?? [];

      return items.map((item) {
        final doc = Map<String, dynamic>.from(item as Map);
         // Converte cada item do array em um HistoricoPoint
        return HistoricoPoint(
            // Converte a string "YYYY-MM-DD" para DateTime
          data:       DateTime.parse(doc['data'] as String),
          precoMedio: (doc['precoMedio'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      // Em caso de erro, retorna lista vazia para não quebrar o gráfico
      return [];
    }
  }

// Usado pelo fetchHistoricoDiario para chamar listOfertas e listComprasDiret
  Future<Map<String, _DadoHora>> _fetchPorHora(
      String startupId, String functionName) async {
    try {
      final result = await FirebaseFunctions
      .instanceFor(region: 'southamerica-east1',)
          .httpsCallable(functionName)
          .call({'startupId': startupId});

      // Converte o resultado para Map tipado
      final response = Map<String, dynamic>.from(result.data as Map);
      // Extrai o array de dados agrupados por hora
      final List items = response['data'] as List? ?? [];

      // Mapa de retorno: chave = dataHora ISO, valor = dados da hora
      final pontos = <String, _DadoHora>{};
       // Itera sobre cada hora retornada pela function
      for (final item in items) {
        // Converte o item para Map tipado
        final doc        = Map<String, dynamic>.from(item as Map);
        final dataHora   = doc['dataHora']   as String;
        final precoMedio = (doc['precoMedio'] as num).toDouble();
        final volume     = (doc['volume']     as num).toDouble();
         // Cria o objeto _DadoHora com os dados da hora
        pontos[dataHora] = _DadoHora(
          dataHora:   DateTime.parse(dataHora).toLocal(),
          somaValor:  precoMedio * volume,
          somaTokens: volume,
        );
      }
      return pontos;
    } catch (e) {
     // Retorna mapa vazio para não quebrar o gráfico
      return {};
    }
  }
}

// Classe para armazenar dados agrupados por hora
// Guarda soma de valor e tokens para calcular média ponderada depois
class _DadoHora {
  final DateTime dataHora;
  final double somaValor;
  final double somaTokens;
  _DadoHora({
    required this.dataHora,
    required this.somaValor,
    required this.somaTokens,
  });
}