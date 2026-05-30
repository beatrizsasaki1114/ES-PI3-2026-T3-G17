// Beatriz Naomi
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'token_price_chart.dart';

class TokenChartPeriodButtons extends StatelessWidget {
  final PeriodoGrafico periodoSelecionado;
  final ValueChanged<PeriodoGrafico> onPeriodoChanged;

  const TokenChartPeriodButtons({
    super.key,
    required this.periodoSelecionado,
    required this.onPeriodoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PeriodoGrafico.values.map((periodo) {
        final selecionado = periodo == periodoSelecionado;
        return GestureDetector(
          onTap: () => onPeriodoChanged(periodo),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selecionado
                  ? const Color.fromARGB(255, 77, 51, 142)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selecionado
                    ? const Color.fromARGB(255, 77, 51, 142)
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              periodo.label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selecionado ? Colors.white : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
