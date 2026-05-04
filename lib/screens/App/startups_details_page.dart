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
import 'package:url_launcher/url_launcher.dart';

class StartupDetailsPage extends StatefulWidget {
  final Startup startup;

  const StartupDetailsPage({super.key, required this.startup});

  @override
  State<StartupDetailsPage> createState() => _StartupDetailsPageState();
}

class _StartupDetailsPageState extends State<StartupDetailsPage> {
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
              decoration: const BoxDecoration(color: Color.fromARGB(255, 77, 51, 142)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, size: 40, color: Color.fromARGB(255, 77, 51, 142)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mescla Invest',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.business_center,
              text: 'Catálogo de Startups',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CataloguePage())),
            ),
            _buildDrawerItem(
              icon: Icons.account_balance_wallet,
              text: 'Minha Carteira',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletPage())),
            ),
            _buildDrawerItem(
              icon: Icons.trending_up,
              text: 'Investimentos',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletPage())), 
            ),
            _buildDrawerItem(
              icon: Icons.person,
              text: 'Meu Perfil',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfilePage())),
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              text: 'Configurações',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigPage())),
            ),
            const Divider(), 
            _buildDrawerItem(
              icon: Icons.exit_to_app,
              text: 'Sair',
              color: Colors.red,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 77, 51, 142).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          fullStartup.name.isNotEmpty ? fullStartup.name[0].toUpperCase() : 'S',
                          style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 77, 51, 142)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fullStartup.name, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              InfoChip(label: fullStartup.stage, color: const Color.fromARGB(255, 73, 46, 143)),
                              InfoChip(label: fullStartup.tokenType, color: const Color.fromARGB(255, 182, 38, 111)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                Text(
                  "Sobre a Startup",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 77, 51, 142)),
                ),
                const SizedBox(height: 12),
                Text(
                  fullStartup.longDescription,
                  style: GoogleFonts.poppins(fontSize: 15, height: 1.5, color: Colors.black87),
                ),

                if (_controller != null) ...[
                  const SizedBox(height: 30),
                  Text(
                    "Vídeo de Demonstração",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 77, 51, 142)),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.purple,
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                Text(
                  "Fundadores",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 77, 51, 142)),
                ),
                const SizedBox(height: 12),
                
                ...fullStartup.founders.map((founder) => Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 230, 230, 250),
                        child: Icon(Icons.person, color: Color.fromARGB(255, 77, 51, 142)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(founder.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${founder.role} • ${founder.shortDescription}", 
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),

                const SizedBox(height: 30),
                Text(
                  "Documentos Oficiais",
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 77, 51, 142)),
                ),
                const SizedBox(height: 12),

                ...fullStartup.publicDocuments.map((doc) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: Colors.grey[100],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(doc.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: const Icon(Icons.download, color: Color.fromARGB(255, 77, 51, 142)),
                    onTap: () async {
                      final Uri url = Uri.parse(doc.url);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                )),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 77, 51, 142),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      "Investir em ${fullStartup.name}",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
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
}

class InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const InfoChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}