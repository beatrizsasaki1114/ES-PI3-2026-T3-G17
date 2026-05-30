// Beatriz Naomi
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'token_chart_periods_buttons.dart';
import 'package:projeto_integrador_3_grupo_17/services/dashboards/dashboard_services.dart';

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

  String get periodoString {
    switch (this) {
      case PeriodoGrafico.semana:
        return 'semana';
      case PeriodoGrafico.mes:
        return 'mes';
      case PeriodoGrafico.seisMeses:
        return 'seisMeses';
      case PeriodoGrafico.ano:
        return 'ano';
      default:
        return 'ano';
    }
  }

  int get janelaMediaMovel {
    switch (this) {
      case PeriodoGrafico.dia:
        return 1;
      case PeriodoGrafico.semana:
        return 2;
      case PeriodoGrafico.mes:
        return 3;
      case PeriodoGrafico.seisMeses:
        return 7;
      case PeriodoGrafico.ano:
        return 14;
    }
  }
}

class TokenPriceChart extends StatefulWidget {
  final String startupId;
  const TokenPriceChart({super.key, required this.startupId});
 
  @override
  State<TokenPriceChart> createState() => _TokenPriceChartState();
}
 
class _TokenPriceChartState extends State<TokenPriceChart> {
  PeriodoGrafico _periodo = PeriodoGrafico.ano;
 
  // 1D  → pontos por hora vindos das Cloud Functions (tempo real)
  List<HistoricoPoint> _dadoDiario = [];
  // 1S/1M/6M/1A → histórico salvo no Firestore via listHistorico
  List<HistoricoPoint> _historicoSalvo = [];
 
  bool _carregando = true;
  String? _erro;
 
  // Único ponto de contato com Firebase
  final _service = DashboardServices();
 
  final Color _corLinha  = const Color(0xFFE91E63);
  final Color _corSombra = const Color(0xFFE91E63);
 
  // Horário de funcionamento: seg-sex 09:00 às 18:00 (horário de Brasília)
  bool get _mercadoAberto {
    final agora    = DateTime.now();
    final diaSemana = agora.weekday; // 1=seg, 7=dom
    if (diaSemana == DateTime.saturday || diaSemana == DateTime.sunday) return false;
    final hora = agora.hour * 60 + agora.minute;
    return hora >= 9 * 60 && hora < 18 * 60; // 09:00 a 18:00
  }
 
  String get _statusMercado {
    final agora     = DateTime.now();
    final diaSemana = agora.weekday;
    final hora      = agora.hour * 60 + agora.minute;
    final fimDeSemana = diaSemana == DateTime.saturday || diaSemana == DateTime.sunday;
    final aberturaHoje = fimDeSemana ? 8 * 60 : 9 * 60;
    if (hora < aberturaHoje) {
      return 'Mercado fechado. Abre às ${fimDeSemana ? '08' : '09'}:00';
    }
    if (hora >= 18 * 60) return 'Mercado encerrado. Reabre amanhã às ${diaSemana == DateTime.friday ? '08' : diaSemana == DateTime.saturday ? '08' : '09'}:00';
    return '';
  }
 
  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }
 
 
  Future<void> _carregarTudo() async {
    setState(() { _carregando = true; _erro = null; });
    try {
      // Para o 1D só busca dados em tempo real se o mercado estiver aberto
      final diario = (_periodo == PeriodoGrafico.dia && _mercadoAberto)
          ? await _service.fetchHistoricoDiario(widget.startupId)
          : <HistoricoPoint>[];
 
      final historico = await _service.fetchHistoricoSalvo(
          widget.startupId, _periodo.periodoString);
 
      setState(() {
        _dadoDiario     = diario;
        _historicoSalvo = historico;
        _carregando     = false;
      });
    } catch (_) {
      setState(() {
        _erro       = 'Não foi possível carregar o histórico.';
        _carregando = false;
      });
    }
  }
 
  
  List<HistoricoPoint> get _dadosDoPeriodo {
    switch (_periodo) {
 
      // 1D: janela deslizante de 24h vindas das Cloud Functions
      // Sempre tem dados (últimas 24h), então não precisa de fallback complexo
      case PeriodoGrafico.dia:
        return _dadoDiario;
 
            // 1S/1M/6M/1A: histórico já filtrado pelo servidor
      default:
        return _historicoSalvo;
    }
  }
 
  bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
 
  // Aviso de dados insuficientes (só para 1M/6M/1A)
  bool get _dadosInsuficientes {
    if (_periodo == PeriodoGrafico.dia || _periodo == PeriodoGrafico.semana) return false;
    final esperado = {
      PeriodoGrafico.mes:       30,
      PeriodoGrafico.seisMeses: 180,
      PeriodoGrafico.ano:       365,
    }[_periodo]!;
    return _dadosDoPeriodo.length < (esperado * 0.7).round();
  }
 
    bool get _semDados =>
      _periodo == PeriodoGrafico.dia ? _dadoDiario.isEmpty : _historicoSalvo.isEmpty;
 
  // ─── Média móvel ───────────────────────────────────────────────────────────
  List<HistoricoPoint> _mediaMovel(List<HistoricoPoint> dados) {
    final janela = _periodo.janelaMediaMovel;
    if (janela <= 1 || dados.length < janela) return dados;
    return List.generate(dados.length, (i) {
      final inicio = (i - janela + 1).clamp(0, dados.length - 1).toInt();
      final slice  = dados.sublist(inicio, i + 1);
      final media  = slice.map((p) => p.precoMedio).reduce((a, b) => a + b) / slice.length;
      return HistoricoPoint(data: dados[i].data, precoMedio: media);
    });
  }
 
  // Agrupa os pontos por mês calculando a média ponderada de cada mês
  // Usado para 6M e 1A: cada ponto no gráfico representa um mês inteiro
  List<HistoricoPoint> _agruparPorMes(List<HistoricoPoint> dados) {
    if (dados.isEmpty) return [];
 
    final porMes = <String, List<double>>{};
    final dataPorMes = <String, DateTime>{};
 
    for (final p in dados) {
      final chave = '${p.data.year}-${p.data.month.toString().padLeft(2, '0')}';
      porMes.putIfAbsent(chave, () => []);
      porMes[chave]!.add(p.precoMedio);
      // Guarda o dia 15 do mês como data representativa do ponto
      dataPorMes[chave] = DateTime(p.data.year, p.data.month, 15);
    }
 
    return porMes.entries.map((e) {
      final media = e.value.reduce((a, b) => a + b) / e.value.length;
      return HistoricoPoint(data: dataPorMes[e.key]!, precoMedio: media);
    }).toList()
      ..sort((a, b) => a.data.compareTo(b.data));
  }
 
  double? get _variacao {
    final d = _dadosDoPeriodo;
    if (d.length < 2 || d.first.precoMedio == 0) return null;
    return ((d.last.precoMedio - d.first.precoMedio) / d.first.precoMedio) * 100;
  }
 
 
  List<FlSpot> _gerarSpots(List<HistoricoPoint> dados) =>
      List.generate(dados.length, (i) => FlSpot(i.toDouble(), dados[i].precoMedio));
 
  Widget _bottomTitleWidget(double value, TitleMeta meta, List<HistoricoPoint> dados) {
    final i = value.toInt();
    if (i < 0 || i >= dados.length) return const SizedBox.shrink();
    final label = _labelParaIndice(i, dados);
    if (label.isEmpty) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black38)),
    );
  }
 
  String _labelParaIndice(int i, List<HistoricoPoint> dados) {
    final data  = dados[i].data;
    final total = dados.length;
    switch (_periodo) {
      // 1D: HH:00 a cada 4 horas
      case PeriodoGrafico.dia:
        // Mostra HH:00 a cada 4 horas
        if (data.hour % 4 == 0) return '${data.hour.toString().padLeft(2, '0')}:00';
        return '';
      // 1S: nome do dia da semana
      case PeriodoGrafico.semana:
        return _diaSemana(data.weekday);
      // 1M: dias marcantes
      case PeriodoGrafico.mes:
        const marcas = {1, 5, 10, 15, 20, 25};
        return (marcas.contains(data.day) || i == total - 1)
            ? data.day.toString().padLeft(2, '0')
            : '';
      // 6M e 1A: primeira ocorrência de cada mês
      case PeriodoGrafico.seisMeses:
      case PeriodoGrafico.ano:
        if (i == 0) return _mesAbrev(data.month);
        return dados[i - 1].data.month != data.month ? _mesAbrev(data.month) : '';
    }
  }
 
  static const _meses   = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
  static const _diasSem = ['Seg','Ter','Qua','Qui','Sex','Sáb','Dom'];
  String _mesAbrev(int m)  => _meses[m - 1];
  String _diaSemana(int d) => _diasSem[d - 1];
 
  LineChartData _mainData(List<HistoricoPoint> dados) {
    final spots  = _gerarSpots(dados);
    final precos = dados.map((p) => p.precoMedio).toList();
    final minY   = precos.reduce((a, b) => a < b ? a : b);
    final maxY   = precos.reduce((a, b) => a > b ? a : b);
    final diff   = maxY - minY;
    final margem = diff == 0 ? 0.1 : diff * 0.15;
 
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: diff == 0 ? 0.1 : diff / 4,
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
            interval: 1,
            getTitlesWidget: (value, meta) =>
                _bottomTitleWidget(value, meta, dados),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (dados.length - 1).toDouble(),
      minY: minY - margem,
      maxY: maxY + margem,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF4D338E),
          tooltipBorderRadius: BorderRadius.circular(8),
          getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
            final idx   = spot.x.toInt().clamp(0, dados.length - 1);
            final ponto = dados[idx];
            // Tooltip: 1D → hora, 6M/1A → Mês/Ano, demais → data completa
            final String label;
            if (_periodo == PeriodoGrafico.dia) {
              label = '${ponto.data.hour.toString().padLeft(2, '0')}:00';
            } else if (_periodo == PeriodoGrafico.seisMeses || _periodo == PeriodoGrafico.ano) {
              label = '${_mesAbrev(ponto.data.month)}/${ponto.data.year}';
            } else {
              label = '${ponto.data.day.toString().padLeft(2, '0')}/${ponto.data.month.toString().padLeft(2, '0')}/${ponto.data.year}';
            }
            return LineTooltipItem(
              'R\$ ${ponto.precoMedio.toStringAsFixed(2)}\n$label',
              GoogleFonts.poppins(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: _corLinha,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, bar) => spot.x == bar.spots.last.x,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 5,
              color: _corLinha,
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
 
  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCabecalho(),
          const SizedBox(height: 12),
          TokenChartPeriodButtons(
            periodoSelecionado: _periodo,
            onPeriodoChanged: (novo) {
              setState(() => _periodo = novo);
              // Recarrega o histórico com o novo período (exceto 1D que já está carregado)
              if (novo != PeriodoGrafico.dia) _carregarTudo();
            },
          ),
          const SizedBox(height: 8),
          // Banner de mercado fechado (só para o período 1D)
          if (_periodo == PeriodoGrafico.dia && !_mercadoAberto)
            _buildMercadoFechado(),
          if (_carregando)
            const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator(
                  color: Color(0xFFE91E63), strokeWidth: 2)),
            )
          else if (_erro != null)
            _buildErro()
          else if (_semDados)
            _buildSemDados()
          else ...[
            if (_dadosInsuficientes) _buildAviso(),
            AspectRatio(
              aspectRatio: 1.8,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: LineChart(_mainData(
                  (_periodo == PeriodoGrafico.seisMeses || _periodo == PeriodoGrafico.ano)
                      ? _agruparPorMes(_dadosDoPeriodo)
                      : _mediaMovel(_dadosDoPeriodo),
                )),
              ),
            ),
          ],
        ],
      ),
    );
  }
 
  Widget _buildCabecalho() {
    final v = _variacao;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Valorização do Token',
            style: GoogleFonts.poppins(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        if (v != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: v >= 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%',
              style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: v >= 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
              ),
            ),
          ),
      ],
    );
  }
 
  Widget _buildMercadoFechado() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _statusMercado,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
          ),
        ),
      ]),
    );
  }
 
  Widget _buildAviso() {
    final n = _dadosDoPeriodo.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFCC02)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline, size: 16, color: Color(0xFFF9A825)),
        const SizedBox(width: 8),
        Expanded(child: Text(
          'Dados insuficientes para ${_periodo.label}. '
          'Exibindo os últimos ${_dadosDoPeriodo.length} '
          'dia${_dadosDoPeriodo.length > 1 ? 's' : ''} disponíveis.',
          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6D4C00)),
        )),
      ]),
    );
  }
 
  Widget _buildSemDados() => SizedBox(
    height: 160,
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.show_chart, color: Colors.grey.shade300, size: 40),
      const SizedBox(height: 8),
      Text('Nenhuma transação registrada ainda.',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black38)),
    ])),
  );
 
  Widget _buildErro() => SizedBox(
    height: 160,
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
      const SizedBox(height: 8),
      Text(_erro!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
      TextButton(
        onPressed: _carregarTudo,
        child: Text('Tentar novamente',
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4D338E))),
      ),
    ])),
  );
}