import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Imports de Telas
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/wallet_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/startups_details_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/login_page.dart';

// Imports de Model e Service (Ajuste os nomes dos arquivos conforme sua estrutura real)
import 'package:projeto_integrador_3_grupo_17/models/startups.dart'; 
import 'package:projeto_integrador_3_grupo_17/services/startups/startups_services.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  final int _selectedIndex = 1; // Home selecionada por padrão

  // Função auxiliar para construir itens do Drawer (do Arquivo 1)
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
          color: color == Colors.red ? Colors.red : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- APP BAR (Unificada com Logo e Ações) ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 65,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset('assets/images/menuIcon.png', height: 40, width: 40),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: InkWell(
          onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CataloguePage())),
          child: Transform.translate(
            offset: const Offset(0, -6),
            child: Image.asset('assets/images/logoMesclaInvest.png', height: 80, fit: BoxFit.contain),
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/userIcon.png', height: 40, width: 40),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfilePage())),
          ),
          IconButton(
            icon: Image.asset('assets/images/configIcon.png', height: 40, width: 40),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigPage())),
          ),
        ],
      ),

      // --- DRAWER (Menu Lateral do Arquivo 1) ---
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
              onTap: () => Navigator.pop(context),
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
              onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false),
            ),
          ],
        ),
      ),

      // --- BODY (Lógica de Backend do Arquivo 2) ---
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Catálogo de Startups',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 77, 51, 142),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Startup>>(
                  future: StartupService().fetchStartups(), // Chamada real ao Service
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
                    }

                    final startups = snapshot.data ?? [];

                    if (startups.isEmpty) {
                      return const Center(child: Text('Nenhuma startup disponível.'));
                    }

                    return ListView.separated(
                      itemCount: startups.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final s = startups[index];
                        return StartupCard(
                          startup: s,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => StartupDetailsPage(startup: s)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // --- BOTTOM NAVIGATION BAR (Arquivo 1) ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletPage()));
          if (index == 1) return; // Já está na home
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

// --- WIDGETS DE APOIO (StartupCard e InfoChip) ---

class StartupCard extends StatelessWidget {
  final Startup startup;
  final VoidCallback onTap;

  const StartupCard({super.key, required this.startup, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          border: Border.all(color: Colors.white, width: 5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text(
                  startup.name.isNotEmpty ? startup.name[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(startup.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(startup.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, // Espaço horizontal entre os chips
                    runSpacing: 4, // Espaço vertical se ele pular de linha
                    children: [
                      InfoChip(label: startup.stage, color: const Color.fromARGB(255, 73, 46, 143)),
                      InfoChip(label: startup.tokenType, color: const Color.fromARGB(255, 182, 38, 111)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color.fromARGB(200, 182, 38, 111)),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}