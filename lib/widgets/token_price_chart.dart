// Beatriz Naomi

// Modelo para cada ponto do gráfico
class HistoricoPoint {
  final DateTime data;
  final double precoMedio;
 
  HistoricoPoint({required this.data, required this.precoMedio});
}

// enum para periodos disponíveis do gráfico
enum PeriodoGrafico { dia, semana, mes, seisMeses, ano }
 
extension PeriodoLabel on PeriodoGrafico {
  String get label {
    switch (this) {
      case PeriodoGrafico.dia:
        return '1D';
      case PeriodoGrafico.semana:
        return '1S';
      case PeriodoGrafico.mes:
        return '1M';
      case PeriodoGrafico.seisMeses:
        return '6M';
      case PeriodoGrafico.ano:
        return '1A';
    }
  }
 
}