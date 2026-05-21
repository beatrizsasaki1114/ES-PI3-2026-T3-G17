//Bruno Machado
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart'; 

class SocietyStructurePage extends StatelessWidget {

  final Startup startup;

  const SocietyStructurePage({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {

    final founders = startup.founders;
    final externalMembers = startup.externalMembers;

    // Paleta de cores para o gráfico
    final List<Color> sectionColors = [
      const Color(0xFFE91E63),
      const Color(0xFF3F51B5),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF00BCD4),
      const Color(0xFF9C27B0),
    ];

    List<PieChartSectionData> pieSections = [];
    List<Widget> founderCards = [];
    List<Widget> externalCards = [];
    int colorIndex = 0;

    // Montando dados para o gráfico e os Cards dos Fundadores
    for (var f in founders) {
      Color color = sectionColors[colorIndex % sectionColors.length];
      pieSections.add(
        PieChartSectionData(
          color: color,
          value: f.porcentagem,
          title: '${f.porcentagem}%',
          radius: 50,
          titleStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      founderCards.add(FounderCard(founder: f, badgeColor: color));
      colorIndex++;
    }

    // Montando dados para o gráfico e os Cards dos Membros Externos
    for (var m in externalMembers) {
      Color color = sectionColors[colorIndex % sectionColors.length];
      pieSections.add(
        PieChartSectionData(
          color: color,
          value: m.porcentagem,
          title: '${m.porcentagem}%',
          radius: 50,
          titleStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
      externalCards.add(ExternalMemberCard(member: m, badgeColor: color));
      colorIndex++;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91E63),
              Color(0xFF9C27B0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Estrutura Societária',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Se não houver nenhum sócio nem membro
                        if (pieSections.isEmpty)
                           Center(
                            child: Text(
                              'Nenhum dado societário encontrado',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                            ),
                          )
                        else ...[
                          // GRÁFICO
                          SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                sections: pieSections,
                                centerSpaceRadius: 40,
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // SÓCIOS (FUNDADORES)
                          if (founderCards.isNotEmpty) ...[
                            Text(
                              'Sócios Fundadores',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...founderCards,
                          ],

                          // MEMBROS EXTERNOS
                          if (externalCards.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Membros Externos',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...externalCards,
                          ],
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FounderCard extends StatelessWidget {
  final Founder founder;
  final Color badgeColor;

  const FounderCard({super.key, required this.founder, required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          Text(
            founder.role,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: _buildPlaceholderAvatar(), 
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${founder.name} (${founder.porcentagem}%)',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            founder.shortDescription, 
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return const Icon(
      Icons.person,
      size: 60,
      color: Colors.black38,
    );
  }
}

class ExternalMemberCard extends StatelessWidget {
  final ExternalMember member;
  final Color badgeColor;

  const ExternalMemberCard({super.key, required this.member, required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 24, color: Colors.black38),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${member.name} (${member.porcentagem}%)',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  member.role,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}