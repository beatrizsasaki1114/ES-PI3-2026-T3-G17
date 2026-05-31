// Beatriz Naomi
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/token_price_chart.dart';
import 'package:projeto_integrador_3_grupo_17/services/dashboards/dashboard_services.dart';

class InvestmentPerformanceChart extends StatefulWidget {
  final String  startupName;
  final int     tokenQuantity;
  final double  amountSpent;
  final double? precoNaCompra;

  const InvestmentPerformanceChart({
    super.key,
    required this.startupName,
    required this.tokenQuantity,
    required this.amountSpent,
    this.precoNaCompra,
  });

  @override
  State<InvestmentPerformanceChart> createState() =>
      _InvestmentPerformanceChartState();
}

class _InvestmentPerformanceChartState
    extends State<InvestmentPerformanceChart> {

  // Período padrão ao abrir o gráfico
  PeriodoGrafico _periodo = PeriodoGrafico.semana;
  double _precoAtualToken    = 0;
  double _precoAnteriorToken = 0;
  bool   _carregando         = true;

  final _service = DashboardServices();
  final Color _corLinha  = const Color(0xFF4D338E);
  final Color _corSombra = const Color(0xFF4D338E);

  // Variação diária do token baseada nos preços atual e anterior
  // Limitada a ±5% para evitar distorções quando PrecoAnteriorToken
  double get _variacaoDiaria {
    if (_precoAnteriorToken <= 0) return 0;
    final variacao = (_precoAtualToken - _precoAnteriorToken) / _precoAnteriorToken;
    return variacao.clamp(-0.05, 0.05);
  }

  

  // Calcula o valor atual do investimento distribuindo a variação pro rata pelo pregão
  // Valor_{hora} = inicial × (1 + taxaDiaria)^(fracao_do_dia)
  double get _valorAtualHoje {
    final agora         = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    final agoraMinutos  = agora.hour * 60 + agora.minute;
    final aberturaMin   = 8 * 60;
    final fechamentoMin = 18 * 60;
    // Fração do dia de pregão que já passou (0.0 = abertura, 1.0 = fechamento)
    double fracaoDia = 0;
    if (agoraMinutos >= aberturaMin && agoraMinutos <= fechamentoMin) {
      fracaoDia = (agoraMinutos - aberturaMin) / (fechamentoMin - aberturaMin).toDouble();
    } else if (agoraMinutos > fechamentoMin) {
      fracaoDia = 1.0;
    }
 
    return widget.amountSpent * pow(1 + _variacaoDiaria, fracaoDia);
  }

  @override
  void initState() {
    super.initState();
    _buscarPrecosDaStartup();
  }

  // Busca PrecoAtualToken e PrecoAnteriorToken 
  Future<void> _buscarPrecosDaStartup() async {
    setState(() => _carregando = true);
    try {
      final precos = await _service.buscarPrecosDaStartup(widget.startupName);
      setState(() {
        _precoAtualToken    = precos.precoAtual;
        _precoAnteriorToken = precos.precoAnterior;
        _carregando         = false;
      });
    } catch (_) {
      setState(() => _carregando = false);
    }
  }

// Gera pontos futuros a partir do valor atual
  // valorNoDia = valorHoje × (1 + variacaoDiaria)^dia
  List<FlSpot> _gerarPontos() {
 final variacaoPorHora = _variacaoDiaria * 0.02;
    final variacaoEfetiva = variacaoPorHora * 10;
 
    if (_periodo == PeriodoGrafico.dia) {
      return List.generate(11, (i) {
        final valor = _valorAtualHoje * pow(1 + variacaoPorHora, i.toDouble());
        return FlSpot(i.toDouble(), valor);
      });
    }
    if (_periodo == PeriodoGrafico.semana) {
      return List.generate(8, (i) {
        final valor = _valorAtualHoje * pow(1 + variacaoEfetiva, i.toDouble());
        return FlSpot(i.toDouble(), valor);
      });
    }
    final dias = _diasDoPeriodo();
    return List.generate(dias + 1, (i) {
      final variacaoTotal = (variacaoEfetiva * i).clamp(-0.30, 0.30);
      final valor = _valorAtualHoje * (1 + variacaoTotal);
      return FlSpot(i.toDouble(), valor);
    });
  }
 
  List<DateTime> _gerarDatas() {
  if (_periodo == PeriodoGrafico.dia) {
      final hoje = DateTime.now().toUtc().subtract(const Duration(hours: 3));
      final abertura = DateTime(hoje.year, hoje.month, hoje.day, 8, 0);
      return List.generate(11, (i) => abertura.add(Duration(hours: i)));
    }
    if (_periodo == PeriodoGrafico.semana) {
      final hoje = DateTime.now();
      return List.generate(8, (i) => hoje.add(Duration(days: i)));
    }
    final dias = _diasDoPeriodo();
    final hoje = DateTime.now();
    return List.generate(dias + 1, (i) => hoje.add(Duration(days: i)));
  }

  int _diasDoPeriodo() {
    switch (_periodo) {
      case PeriodoGrafico.dia:       return 1;
      case PeriodoGrafico.semana:    return 7;
      case PeriodoGrafico.mes:       return 30;
      case PeriodoGrafico.seisMeses: return 180;
      case PeriodoGrafico.ano:       return 365;
    }
  }

    // Último valor projetado do período selecionado
  // Usado no header e no badge — muda conforme o período escolhido
  double get _valorUltimoPonto {
    final spots = _gerarPontos();
    if (spots.isEmpty) return widget.amountSpent;
    return spots.last.y;
  }


   // Variação total no período: do primeiro ao último ponto gerado
  double? get _variacaoPercent {
    if (_precoAnteriorToken <= 0) return null;
    final spots = _gerarPontos();
    if (spots.isEmpty) return null;
    final inicio = spots.first.y;
    final fim    = spots.last.y;
    if (inicio == 0) return null;
    return ((fim - inicio) / inicio) * 100;
  }
 

  LineChartData _mainData() {
    final spots  = _gerarPontos();
    final datas  = _gerarDatas();
    final valores = spots.map((s) => s.y).toList();
    final minY   = valores.reduce((a, b) => a < b ? a : b);
    final maxY   = valores.reduce((a, b) => a > b ? a : b);
    final diff   = maxY - minY;
    final margem = diff == 0 ? widget.amountSpent * 0.05 : diff * 0.15;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: diff == 0 ? 1 : diff / 4,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.grey.shade100, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval:  1,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= datas.length) return const SizedBox.shrink();
              final label = _labelParaIndice(i, datas);
              if (label.isEmpty) return const SizedBox.shrink();
              return SideTitleWidget(
                meta: meta,
                child: Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: Colors.black38)),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: spots.length - 1.0,
      minY: minY - margem,
      maxY: maxY + margem,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF4D338E),
          tooltipBorderRadius: BorderRadius.circular(8),
          getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
            final i    = spot.x.toInt().clamp(0, datas.length - 1);
            final valor = spot.y;
            final var2  = ((valor - _valorAtualHoje) / _valorAtualHoje) * 100;
            final data  = datas[i];
            final label = _periodo == PeriodoGrafico.dia
                ? '${data.hour.toString().padLeft(2, '0')}:00'
                : '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
            return LineTooltipItem(
              'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}\n'
              '${var2 >= 0 ? '+' : ''}${var2.toStringAsFixed(2)}%\n'
              '$label',
              GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: _corLinha,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, bar) =>
                spot.x == 0 || spot.x == bar.spots.last.x,
            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
              radius: spot.x == 0 ? 4 : 5,
              color: spot.x == 0 ? Colors.grey.shade400 : _corLinha,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                _corSombra.withOpacity(0.15),
                _corSombra.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  String _labelParaIndice(int i, List<DateTime> datas) {
    final data  = datas[i];
    final total = datas.length;
    switch (_periodo) {
      case PeriodoGrafico.dia:
        if (i % 2 == 0) {
          final hora = 8 + i;
          return hora <= 18 ? '${hora.toString().padLeft(2, '0')}h' : '';
        }
        return '';

      case PeriodoGrafico.semana:
        return _diaSemana(data.weekday);

      case PeriodoGrafico.mes:
        const marcas = {1, 5, 10, 15, 20, 25, 30};
        if (i == 0 || marcas.contains(data.day) || i == total - 1) {
            return data.day.toString().padLeft(2, '0');
        }
        return '';
        
      case PeriodoGrafico.seisMeses:
         if (data.day == 1) return _mesAbrev(data.month);

        return '';

      case PeriodoGrafico.ano:
          if (data.day == 1) return _mesAbrev(data.month);

        return '';
    }

  }

  static const _meses   = ['Jan','Fev','Mar','Abr','Mai','Jun',
                            'Jul','Ago','Set','Out','Nov','Dez'];
  static const _diasSem = ['Seg','Ter','Qua','Qui','Sex','Sáb','Dom'];
  String _mesAbrev(int m)  => _meses[m - 1];
  String _diaSemana(int d) => _diasSem[d - 1];

  @override
  Widget build(BuildContext context) {
    final variacao   = _variacaoPercent;
    final valorAtual =  _valorUltimoPonto;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Valor Atual Estimado',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.black54)),
                  Text(
                    'R\$ ${valorAtual.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4D338E)),
                  ),
                ],
              ),
              if (variacao != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: variacao >= 0
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${variacao >= 0 ? '+' : ''}${variacao.toStringAsFixed(2)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: variacao >= 0
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Projeção baseada na variação atual do token',
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.black38),
          ),
          const SizedBox(height: 12),

          // Botões de período
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                PeriodoGrafico.dia,
                PeriodoGrafico.semana,
                PeriodoGrafico.mes,
                PeriodoGrafico.seisMeses,
                PeriodoGrafico.ano,
              ].map((periodo) {
                final sel = periodo == _periodo;
                return GestureDetector(
                  onTap: () => setState(() => _periodo = periodo),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFF4D338E)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel
                            ? const Color(0xFF4D338E)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      periodo.label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Gráfico
          if (_carregando)
            const SizedBox(
              height: 160,
              child: Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF4D338E), strokeWidth: 2),
              ),
            )
          else if (_precoAtualToken == 0)
            SizedBox(
              height: 160,
              child: Center(
                child: Text('Não foi possível carregar os dados.',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.black38)),
              ),
            )
          else
            AspectRatio(
              aspectRatio: 1.8,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: LineChart(_mainData()),
              ),
            ),

          // Legenda
          if (!_carregando && _precoAtualToken > 0) ...[
            const SizedBox(height: 8),
            Row(children: [
              Container(
                  width: 16,
                  height: 2,
                  color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                'Valor investido: R\$ ${widget.amountSpent.toStringAsFixed(2).replaceAll('.', ',')}',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.black45),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}