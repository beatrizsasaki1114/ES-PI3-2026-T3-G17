import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/login_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/app_config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/user_data_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/catalogue_page.dart';


class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Barra superior
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 65,

        leading: IconButton(
          icon: Image.asset(
            'assets/images/menuIcon.png',
            height: 40,
            width: 40,
          ),
          onPressed: () {},
        ),

        title: InkWell(
          onTap: () {
            // Opção A: volta/abre a página de catálogo e remove a pilha anterior
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CataloguePage()),
              (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Transform.translate(
            offset: const Offset(0, -6), 
            child: Image.asset(
              'assets/images/logoMesclaInvest.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/userIcon.png',
              height: 40,
              width: 40,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset(
              'assets/images/configIcon.png',
              height: 40,
              width: 40,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfigPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
  child: SingleChildScrollView(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            "Configurações",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          _buildSettingsButton(
            label: "Configurações de Usuário",
            icon: Icons.person_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => const  UserConfigPage(),
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
                builder: (context) => const  AppConfigPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          _buildSettingsButton(
            label: "Sair",
            icon: Icons.logout,
            color: Colors.redAccent,
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
  ),
),
    );
  }
}


  

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
              color: Colors.black.withOpacity(0.05),
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
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.3), size: 18),
          ],
        ),
      ),
    ),
  );
}

  