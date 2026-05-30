// Beatriz Naomi
import 'package:projeto_integrador_3_grupo_17/widgets/token_price_chart.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Centraliza todo contato entre Flutter e Firebase.
/// Nenhum outro arquivo do Flutter acessa Firebase diretamente.
class DashboardServices {
  final _functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  
  // Busca ofertas + compras das últimas 24h, agrupa por hora e retorna
  // um HistoricoPoint por hora — cobre sempre exatamente 24h para trás
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

  // ─── 1S/1M/6M/1A: histórico salvo via Cloud Function ─────────────────────
  Future<List<HistoricoPoint>> fetchHistoricoSalvo(
      String startupId, String periodo) async {
    try {
      final result = await _functions
          .httpsCallable('listHistorico')
          .call({'startupId': startupId, 'periodo': periodo});

      final response = Map<String, dynamic>.from(result.data as Map);
      final List items = response['data'] as List? ?? [];

      return items.map((item) {
        final doc = Map<String, dynamic>.from(item as Map);
        return HistoricoPoint(
          data:       DateTime.parse(doc['data'] as String),
          precoMedio: (doc['precoMedio'] as num).toDouble(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Interno: chama uma function e retorna Map<dataHoraISO, _DadoHora> ────
  Future<Map<String, _DadoHora>> _fetchPorHora(
      String startupId, String functionName) async {
    try {
      final result = await _functions
          .httpsCallable(functionName)
          .call({'startupId': startupId});

      final response = Map<String, dynamic>.from(result.data as Map);
      final List items = response['data'] as List? ?? [];

      final pontos = <String, _DadoHora>{};
      for (final item in items) {
        final doc        = Map<String, dynamic>.from(item as Map);
        final dataHora   = doc['dataHora']   as String;
        final precoMedio = (doc['precoMedio'] as num).toDouble();
        final volume     = (doc['volume']     as num).toDouble();
        pontos[dataHora] = _DadoHora(
          dataHora:   DateTime.parse(dataHora).toLocal(),
          somaValor:  precoMedio * volume,
          somaTokens: volume,
        );
      }
      return pontos;
    } catch (_) {
      return {};
    }
  }
}

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