//Bruno Machado

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/catalogue_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/login_page.dart'; 
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/wallet_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart';
import 'package:projeto_integrador_3_grupo_17/services/startups/startups_services.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/invest_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/token_market_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/society_structure.dart';
import 'package:url_launcher/url_launcher.dart';


class StartupDetailsPage extends StatefulWidget {
  final Startup startup;

  const StartupDetailsPage({super.key, required this.startup});

  @override
  State<StartupDetailsPage> createState() => _StartupDetailsPageState();
}

class _StartupDetailsPageState extends State<StartupDetailsPage> {
  int? _expandedFaqIndex;
  final int _selectedIndex = 1;
  YoutubePlayerController? _controller;

  void _initializeVideo(String url) {
    if (_controller != null || url.isEmpty) return;

    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          isLive: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = const Color.fromARGB(255, 77, 51, 142),
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: GoogleFonts.poppins(
            fontSize: 16,
            color: color == Colors.red ? Colors.red : Colors.black87),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDocumentButton({
    required String title,
    required String size,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.description, color: Colors.black54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    size,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required int index,
  }) {
    final isExpanded = _expandedFaqIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.black54,
          ),
          onExpansionChanged:(expanded) {
            setState(() {
              _expandedFaqIndex = expanded ? index : null;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 77, 51, 142)),
        title: Text(
          widget.startup.name,
          style: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 77, 51, 142),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 77, 51, 142),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person,
                        size: 40, color: Color.fromARGB(255, 77, 51, 142)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mescla Invest',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.business_center,
              text: 'Catálogo de Startups',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CataloguePage())),
            ),
            _buildDrawerItem(
              icon: Icons.account_balance_wallet,
              text: 'Minha Carteira',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WalletPage())),
            ),
            _buildDrawerItem(
              icon: Icons.trending_up,
              text: 'Investimentos',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TokenMarketPage())),
            ),
            _buildDrawerItem(
              icon: Icons.person,
              text: 'Meu Perfil',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const UserProfilePage())),
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              text: 'Configurações',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ConfigPage())),
            ),
            const Divider(),
            _buildDrawerItem(
              icon: Icons.exit_to_app,
              text: 'Sair',
              color: Colors.red,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<Startup>(
        future: StartupService().fetchStartupDetails(widget.startup.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum dado encontrado.'));
          }

          final fullStartup = snapshot.data!;

          if (fullStartup.videoUrl.isNotEmpty) {
            _initializeVideo(fullStartup.videoUrl);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          fullStartup.name.isNotEmpty ? fullStartup.name[0].toUpperCase() : 'S',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullStartup.name,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              InfoChip(
                                label: fullStartup.stage,
                                color: const Color.fromARGB(255, 73, 46, 143),
                              ),
                              const SizedBox(width: 8),
                              InfoChip(
                                label: fullStartup.tokenType,
                                color: const Color.fromARGB(255, 182, 38, 111),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Preços
                Row(
                  children: [
                    _buildPriceInfo('Preço/Token', 'R\$ 1,00'),
                    const SizedBox(width: 24),
                    _buildPriceInfo('Valor Atual', 'R\$ "0,00"'),
                  ],
                ),
                
                const SizedBox(height: 24),

                // Botão Investir
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvestPage(startup: fullStartup),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Investir em ${fullStartup.tokenType}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            
                const SizedBox(height: 24),
                // Gráfico de Apresentação (placeholder)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Aqui seria o gráfico
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Gráfico de Valorização',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Descrição
                Text(
                  "Sobre a Startup",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  fullStartup.longDescription,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
                

                const SizedBox(height: 24),

                // Player de Vídeo
                if (fullStartup.videoUrl.isNotEmpty && _controller != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pitch de Apresentação',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: YoutubePlayer(
                            controller: _controller!,
                            showVideoProgressIndicator: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 32),

                // Documentos Oficiais
                Text(
                  'Documentos Oficiais',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 77, 51, 142),
                  ),
                ),
                const SizedBox(height: 12),
                ...fullStartup.publicDocuments.map((doc) => _buildDocumentButton(
                  title: doc.title,
                  size: 'PDF - Acessar arquivo',
                  onTap: () async {
                    final Uri url = Uri.parse(doc.url);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                )),

                const SizedBox(height: 32),

                // FAQ
                Text(
                  'FAQ',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFaqItem(
                  question: 'A tokenização da ${fullStartup.name} está validada?',
                  answer: 'Sim, a plataforma possui validação técnica e conformidade regulatória.',
                  index: 0,
                ),
                _buildFaqItem(
                  question: 'Quais são os próximos passos?',
                  answer: 'Expansão de mercado e novas funcionalidades na plataforma.',
                  index: 1,
                ),

                const SizedBox(height: 32),

                // Estrutura Societária
                Text(
                  'Estrutura Societária',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SocietyStructurePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Acessar Estrutura Societária',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletPage()));
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const CataloguePage()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfilePage()));
        },
        selectedItemColor: const Color.fromARGB(255, 77, 51, 142),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Investimentos'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
  Widget _buildPriceInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
  

class InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const InfoChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}