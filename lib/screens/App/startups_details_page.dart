import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/catalogue_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/login_page.dart'; 
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/wallet_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart';

class StartupDetailsPage extends StatelessWidget {
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
      style: GoogleFonts.poppins(fontSize: 16, color: color == Colors.red ? Colors.red : Colors.black87),
    ),
    onTap: onTap,
  );
}
  final Startup startup;

  const StartupDetailsPage({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 77, 51, 142)),
        title: Text(
          startup.name,
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
              child: Icon(Icons.person, size: 40, color: Color.fromARGB(255, 77, 51, 142)),
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
        onTap: () {
          Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => const  LoginPage(),
                ),
              );
        },
      ),
    ],
  ),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      startup.name[0].toUpperCase(),
                      style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(startup.name, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          InfoChip(label: startup.stage, color: const Color.fromARGB(255, 73, 46, 143)),
                          const SizedBox(width: 8),
                          InfoChip(label: startup.tokenType, color: const Color.fromARGB(255, 182, 38, 111)),
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
              startup.description,
              style: GoogleFonts.poppins(fontSize: 15, height: 1.5, color: Colors.black87),
            ),
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
                  "Investir em ${startup.name}",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}