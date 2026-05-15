import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/login_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/app_config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_data_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart'; 

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {

  final int _layoutSelectedIndex = 2; 

  @override
  Widget build(BuildContext context) {

    final List<Widget> configAppBarActions = [
      IconButton(
        icon: Image.asset(
          'assets/images/userIcon.png',
          height: 40,
          width: 40,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserProfilePage()),
          );
        },
      ),
      IconButton(
        icon: Image.asset(
          'assets/images/configIcon.png',
          height: 40,
          width: 40,
        ),
        onPressed: () {
          // Já estamos na ConfigPage, não faz nada ou dá um feedback
        },
      ),
    ];

    return MainLayout(
      selectedIndex: _layoutSelectedIndex,
      appBarActions: configAppBarActions,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Configurações',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),

              _buildSettingsButton(
                label: "Configurações de Usuário",
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserConfigPage(), 
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              _buildSettingsButton(
                label: "Configurações do App",
                icon: Icons.settings_applications_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppConfigPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              _buildSettingsButton(
                label: "Sair",
                icon: Icons.logout,
                color: Colors.redAccent,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar mantido fora da classe principal para organização
Widget _buildSettingsButton({
  required String label,
  required IconData icon,
  required VoidCallback onTap,
  Color color = const Color(0xFF313131),
}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withValues(alpha: 0.3), size: 18),
          ],
        ),
      ),
    ),
  );
}