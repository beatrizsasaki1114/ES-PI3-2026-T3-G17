import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart'; // <-- Ajuste o caminho se necessário

class UserInvestmentsPage extends StatefulWidget {
  const UserInvestmentsPage({super.key});

  @override
  State<UserInvestmentsPage> createState() => _UserInvestmentsPageState();
}

class _UserInvestmentsPageState extends State<UserInvestmentsPage> {
  final TextEditingController _searchController = TextEditingController();

  // Lista mockada mockando os investimentos reais que o usuário JÁ possui
  final List<UserInvestment> _myInvestments = [
    UserInvestment(
      id: 1,
      startupName: 'AgroTech',
      tokenQuantity: 150,
      totalValue: 'R\$ 1.500,00',
    ),
    UserInvestment(
      id: 2,
      startupName: 'EcoEnergy',
      tokenQuantity: 80,
      totalValue: 'R\$ 800,00',
    ),
    UserInvestment(
      id: 3,
      startupName: 'BioFuture',
      tokenQuantity: 210,
      totalValue: 'R\$ 2.100,00',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 3,
      body: Stack(
        children: [
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade200.withValues(alpha: 0.5),
                    Colors.purple.shade200.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade300.withValues(alpha: 0.6),
                    Colors.purple.shade400.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),

          // Conteúdo Principal da Página
          Column(
            children: [
              // Card de Patrimônio Total do Usuário em Tokens
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.grey.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Total Investido em Tokens',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'R\$ 4.400,00', // Soma mockada do patrimônio
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Barra de Pesquisa de investimentos do portfólio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Buscar nos meus investimentos...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade400,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Lista de Investimentos Ativos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _myInvestments.length,
                  itemBuilder: (context, index) {
                    final investment = _myInvestments[index];
                    return _buildInvestmentCard(investment);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Componente visual do card de investimento formatado
  Widget _buildInvestmentCard(UserInvestment investment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Inicial da Startup decorativa
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 237, 233, 247),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                investment.startupName[0],
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 77, 51, 142),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Informações do Investimento (Nome e Quantidade de Tokens)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  investment.startupName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${investment.tokenQuantity} tokens',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Valor Financeiro Total e Ação lateral
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                investment.totalValue,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ver detalhes',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFFE91E63),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Modelo de Dados adaptado para a carteira de investimentos do Usuário
class UserInvestment {
  final int id;
  final String startupName;
  final int tokenQuantity;
  final String totalValue;

  UserInvestment({
    required this.id,
    required this.startupName,
    required this.tokenQuantity,
    required this.totalValue,
  });
}