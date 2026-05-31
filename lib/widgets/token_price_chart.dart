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
   // Label exibido no botão (ex: "1D", "1S", "1M", "6M", "1A")
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
 // String enviada para a Cloud Function listHistorico como parâmetro de período
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
}

class TokenPriceChart extends StatefulWidget {
  final String startupId;
  const TokenPriceChart({super.key, required this.startupId});
 
  @override
  State<TokenPriceChart> createState() => _TokenPriceChartState();
}
 
class _TokenPriceChartState extends State<TokenPriceChart> {
   // Período padrão ao abrir a telas de investimento é 1A
  PeriodoGrafico _periodo = PeriodoGrafico.ano;
 
  // Para o período 1D, pegamos os pontos por hora vindos das Cloud Functions (tempo real)
  List<HistoricoPoint> _dadoDiario = [];
  // Dados dos outros período 1S/1M/6M/1A, pegamos do histórico salvo no Firestore via listHistorico
  List<HistoricoPoint> _historicoSalvo = [];
 // Controla o indicador de carregamento
  bool _carregando = true;
  // Mensagem de erro se a busca falhar
  String? _erro;
 

  final _service = DashboardServices();

  final Color _corLinha  = const Color(0xFFE91E63);
  final Color _corSombra = const Color(0xFFE91E63);
 
  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }
 
  // Busca os dados do período atual 
  Future<void> _carregarTudo() async {
      // Ativa o indicador de carregamento e limpa erros anteriores
    setState(() { _carregando = true; _erro = null; });
    try {
      // Para o 1D:  busca dados em tempo real 
      final diario = _periodo == PeriodoGrafico.dia
          ? await _service.fetchHistoricoDiario(widget.startupId)
          : <HistoricoPoint>[];// outros períodos não usam dados diário

       // 1S/1M/6M/1A: busca histórico salvo no HistoricoDiario do Firestore
      final historico = await _service.fetchHistoricoSalvo(
          widget.startupId, _periodo.periodoString);
 
       // Atualiza o estado com os dados recebidos
      setState(() {
        _dadoDiario     = diario;
        _historicoSalvo = historico;
        _carregando     = false;
      });
    } catch (_) {
       // Em caso de erro, exibe mensagem e para o carregamento
      setState(() {
        _erro       = 'Não foi possível carregar o histórico.';
        _carregando = false;
      });
    }
  }

  // Retorna os dados corretos para o período selecionado
  List<HistoricoPoint> get _dadosDoPeriodo {
    switch (_periodo) {
      case PeriodoGrafico.dia:
        return _dadoDiario;
 
      default:
        return _historicoSalvo;
    }
  }
 
  // Aviso de dados insuficientes (só para 1M/6M/1A)
  bool get _dadosInsuficientes {
    if (_periodo == PeriodoGrafico.dia || _periodo == PeriodoGrafico.semana) return false;
    final esperado = {
      PeriodoGrafico.mes:       30,
      PeriodoGrafico.seisMeses: 180,
      PeriodoGrafico.ano:       365,
    }[_periodo]!;
      // Considera insuficiente se tem menos de 70% dos dias esperados
    return _dadosDoPeriodo.length < (esperado * 0.7).round();
  }

     // Retorna true se não há dados para exibir no gráfico
    bool get _semDados =>
      _periodo == PeriodoGrafico.dia ? _dadoDiario.isEmpty : _historicoSalvo.isEmpty;

  // Agrupa os pontos por mês calculando a média ponderada de cada mês
  // Usado para 6M e 1A: cada ponto no gráfico representa um mês inteiro
  List<HistoricoPoint> _agruparPorMes(List<HistoricoPoint> dados) {
    if (dados.isEmpty) return [];
    // Mapa de "YYYY-MM" → lista de preços do mês
    final porMes = <String, List<double>>{};
    // Mapa de "YYYY-MM" → data representativa (dia 15 do mês)
    final dataPorMes = <String, DateTime>{};
 
    for (final p in dados) {
      final chave = '${p.data.year}-${p.data.month.toString().padLeft(2, '0')}';
      porMes.putIfAbsent(chave, () => []);
      porMes[chave]!.add(p.precoMedio);
      // Guarda o dia 15 do mês como data representativa do ponto
      dataPorMes[chave] = DateTime(p.data.year, p.data.month, 15);
    }

    // Converte o mapa em lista de HistoricoPoint com a média de cada mês
    return porMes.entries.map((e) {
      final media = e.value.reduce((a, b) => a + b) / e.value.length;
      return HistoricoPoint(data: dataPorMes[e.key]!, precoMedio: media);
    }).toList()
      ..sort((a, b) => a.data.compareTo(b.data));
  }

  //Calcula a variação % entre o primeiro e último ponto do período
  // Retorna null se não há dados suficientes
  double? get _variacao {
    final d = _dadosDoPeriodo;
    if (d.length < 2 || d.first.precoMedio == 0) return null;
    return ((d.last.precoMedio - d.first.precoMedio) / d.first.precoMedio) * 100;
  }
 
  // Converte a lista de HistoricoPoint em lista de FlSpot para o gráfico
  // x = índice do ponto, y = preço médio
  List<FlSpot> _gerarSpots(List<HistoricoPoint> dados) =>
      List.generate(dados.length, (i) => FlSpot(i.toDouble(), dados[i].precoMedio));
 
 // Retorna o widget de label do eixo X para cada ponto
  Widget _bottomTitleWidget(double value, TitleMeta meta, List<HistoricoPoint> dados) {
    final i = value.toInt();
     // Ignora índices fora do range
    if (i < 0 || i >= dados.length) return const SizedBox.shrink();
    final label = _labelParaIndice(i, dados);
    // Retorna widget vazio se não há label para esse ponto
    if (label.isEmpty) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.black38)),
    );
  }
 
  // Define qual label mostrar no eixo X para cada índice
  String _labelParaIndice(int i, List<HistoricoPoint> dados) {
    final data  = dados[i].data;
    final total = dados.length;
    switch (_periodo) {
       // 1D: mostra hora a cada 4 horas (ex: "08:00", "12:00", "16:00")
      case PeriodoGrafico.dia:
        if (data.hour % 4 == 0) return '${data.hour.toString().padLeft(2, '0')}:00';
        return '';
       // 1S: mostra nome abreviado do dia da semana (ex: "Seg", "Ter")
      case PeriodoGrafico.semana:
        return _diaSemana(data.weekday);
      // 1M: mostra dias marcantes (1, 5, 10, 15, 20, 25) e o último
      case PeriodoGrafico.mes:
        const marcas = {1, 5, 10, 15, 20, 25};
        return (marcas.contains(data.day) || i == total - 1)
            ? data.day.toString().padLeft(2, '0')
            : '';
       // 6M e 1A: mostra o nome do mês na primeira ocorrência de cada mês
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
 
 // Configura e retorna os dados do gráfico de linha
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
           _carregarTudo();
            },
          ),
          const SizedBox(height: 8),

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
                      : _dadosDoPeriodo,
                )),
              ),
            ),
          ],
        ],
      ),
    );
  }
 // Cabeçalho com título "Valorização do Token" e badge de variação %
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
 
  // Banner amarelo de aviso quando os dados do período são insuficientes
  Widget _buildAviso() {
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

// Estado vazio — exibe ícone e mensagem quando não há transações 
  Widget _buildSemDados() => SizedBox(
    height: 160,
    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.show_chart, color: Colors.grey.shade300, size: 40),
      const SizedBox(height: 8),
      Text('Nenhuma transação registrada ainda.',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black38)),
    ])),
  );
 
 // Estado de erro — exibe mensagem e botão para tentar novamente
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