import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart';

class UserInvestmentsPage extends StatefulWidget {
  const UserInvestmentsPage({super.key});

  @override
  State<UserInvestmentsPage> createState() => _UserInvestmentsPageState();
}

class _UserInvestmentsPageState extends State<UserInvestmentsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return MainLayout(
      selectedIndex: 3,
      body: user == null
          ? const Center(child: Text("Usuário não autenticado"))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Usuários')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Dados não encontrados."));
                }

                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final List<dynamic> rawInvestments = userData['investimentos'] ?? [];

                // Filtra os investimentos com base no texto digitado na barra de pesquisa
                final filteredInvestments = rawInvestments.where((inv) {
                  final name = (inv['startupName'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                // Calcula o patrimônio total somando o valor gasto em cada investimento
                double totalInvested = 0;
                for (var inv in rawInvestments) {
                  totalInvested += (inv['amountSpent'] ?? 0).toDouble();
                }

                return Stack(
                  children: [
                    // Círculos decorativos de fundo
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 77, 51, 142).withValues(alpha:0.05),
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
                          color: const Color.fromARGB(255, 182, 38, 111).withValues(alpha:0.05),
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        // Card de Patrimônio Total
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha:0.1),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Patrimônio Total Investido',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.account_balance_wallet,
                                    color: Color.fromARGB(255, 77, 51, 142),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'R\$ ${totalInvested.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Barra de Pesquisa
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey.shade500),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Pesquisar startup...',
                                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
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
                          child: filteredInvestments.isEmpty
                              ? Center(
                                  child: Text(
                                    'Nenhum investimento encontrado.',
                                    style: GoogleFonts.poppins(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: filteredInvestments.length,
                                  itemBuilder: (context, index) {
                                    final inv = filteredInvestments[index];
                                    return _buildInvestmentCard(inv);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildInvestmentCard(Map<String, dynamic> investment) {
    final String startupName = investment['startupName'] ?? 'Desconhecida';
    final int tokenQuantity = investment['tokenQuantity'] ?? 0;
    final double amountSpent = (investment['amountSpent'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Ícone redondo com a inicial da startup
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 240, 235, 255),
            ),
            alignment: Alignment.center,
            child: Text(
              startupName.isNotEmpty ? startupName[0].toUpperCase() : 'S',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 77, 51, 142),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Informações de Nome e Tokens
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startupName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tokenQuantity tokens',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Valor Financeiro Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${amountSpent.toStringAsFixed(2).replaceAll('.', ',')}',
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