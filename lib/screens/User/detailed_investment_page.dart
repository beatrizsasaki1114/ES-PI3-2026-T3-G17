// Bruno Machado
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart';

class DetailedInvestmentPage extends StatefulWidget {
  final Map<String, dynamic> investment;

  const DetailedInvestmentPage({super.key, required this.investment});

  @override
  State<DetailedInvestmentPage> createState() => _DetailedInvestmentPageState();
}

class _DetailedInvestmentPageState extends State<DetailedInvestmentPage> {
  @override
  Widget build(BuildContext context) {
    final String startupName = widget.investment['startupName'] ?? 'Desconhecida';
    final int tokenQuantity = widget.investment['tokenQuantity'] ?? 0;
    final double amountSpent = (widget.investment['amountSpent'] ?? 0).toDouble();
    
    final double currentAmount = amountSpent; 

    final Timestamp? timestamp = widget.investment['date'] as Timestamp?;
    final DateTime date = timestamp != null ? timestamp.toDate() : DateTime.now();
    final String formattedDate = 
        "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    return MainLayout(
      selectedIndex: 3, 
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 77, 51, 142).withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 182, 38, 111).withValues(alpha: 0.05),
              ),
            ),
          ),
          
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 77, 51, 142)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Detalhes do Investimento',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 240, 235, 255),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            startupName.isNotEmpty ? startupName[0].toUpperCase() : 'S',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 77, 51, 142),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          startupName,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$tokenQuantity Tokens Adquiridos',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE91E63),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Data Inicial do Investimento',
                          value: formattedDate,
                        ),
                        const Divider(height: 32, thickness: 1),
                        _buildDetailRow(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Valor Gasto no Investimento',
                          value: 'R\$ ${amountSpent.toStringAsFixed(2).replaceAll('.', ',')}',
                          valueColor: Colors.black87,
                        ),
                        const Divider(height: 32, thickness: 1),
                        _buildDetailRow(
                          icon: Icons.trending_up,
                          label: 'Valor Atual Estimado',
                          value: 'R\$ ${currentAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                          valueColor: const Color(0xFF4CAF50), 
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Desempenho do Investimento",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Espaço reservado para o\ngráfico de desenvolvimento',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color.fromARGB(255, 77, 51, 142)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}