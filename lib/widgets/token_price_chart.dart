// Beatriz Naomi
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'token_chart_periods_buttons.dart';
import 'token_chart_axis_labels.dart';
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
 
   int get dias {
    switch (this) {
      case PeriodoGrafico.dia:       return 1;
      case PeriodoGrafico.semana:    return 7;
      case PeriodoGrafico.mes:       return 30;
      case PeriodoGrafico.seisMeses: return 180;
      case PeriodoGrafico.ano:       return 365;
    }
  }
}

