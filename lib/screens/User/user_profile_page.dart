import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/catalogue_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/wallet_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/login_page.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart';


class UserProfilePage extends StatefulWidget {
  
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
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
  final _selectedIndex = 2;

  final String userName = "João Silva";
  final String userBio = "Entusiasta de tecnologia e investimentos em startups de impacto socioambiental.";

  final List<Startup> userInvestments = [

    
  ];
  String get userStatus {
    int count = userInvestments.length;
    if (count >= 7) return "Investidor Expert";
    if (count >= 3) return "Investidor Assíduo";
    return "Investidor Novato";
  }

  Color get statusColor {
    int count = userInvestments.length;
    if (count >= 7) return const Color(0xFFE1BEE7); 
    if (count >= 3) return const Color(0xFFC8E6C9); 
    return const Color(0xFFBBDEFB);               
  }

  Color get statusTextColor {
    int count = userInvestments.length;
    if (count >= 7) return const Color(0xFF4A148C);
    if (count >= 3) return const Color(0xFF1B5E20);
    return const Color(0xFF0D47A1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 65,
        leading: Builder( 
          builder: (BuildContext context) {
            return IconButton(
              icon: Image.asset('assets/images/menuIcon.png', height: 40, width: 40),
              onPressed: () {
                Scaffold.of(context).openDrawer(); 
              },
            );
          },
        ),
        title: InkWell(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CataloguePage()), (route) => false,
            );
          },
          child: Transform.translate(
            offset: const Offset(0, -6),
            child: Image.asset('assets/images/logoMesclaInvest.png', height: 80, fit: BoxFit.contain),
          ),
        ),
        actions: [
          IconButton(
            icon: Image.asset('assets/images/userIcon.png', height: 40, width: 40),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset('assets/images/configIcon.png', height: 40, width: 40),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigPage()));
            },
          ),
        ],
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
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color.fromARGB(255, 77, 51, 142), width: 2),
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color.fromARGB(255, 230, 225, 245),
                  child: Icon(Icons.person, size: 60, color: Color.fromARGB(255, 77, 51, 142)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              userName,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor, 
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userStatus,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: statusTextColor, 
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                userBio,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
              ),
            ),
            const Divider(height: 40, thickness: 1, indent: 30, endIndent: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Meus Investimentos (${userInvestments.length})",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 77, 51, 142),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userInvestments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  return StartupCard(
                    startup: userInvestments[index],
                    onTap: () {},
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletPage()));
          if (index == 1) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const CataloguePage()), (route) => false);
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
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
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
                  const SizedBox(height: 4),
                  Text(startup.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoChip(label: startup.stage, color: const Color.fromARGB(255, 73, 46, 143), textColor: Colors.white),
                      const SizedBox(width: 8),
                      _InfoChip(label: startup.tokenType, color: const Color.fromARGB(255, 182, 38, 111), textColor: Colors.white),
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

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  const _InfoChip({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}