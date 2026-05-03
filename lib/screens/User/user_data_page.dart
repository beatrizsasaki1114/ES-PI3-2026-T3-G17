import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/catalogue_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/wallet_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/login_page.dart';

class UserConfigPage extends StatefulWidget {
  const UserConfigPage({super.key});

  @override
  State<UserConfigPage> createState() => _UserConfigPageState();
}

class _UserConfigPageState extends State<UserConfigPage> {
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
  final _selectedIndex = 1;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Informações de Usuário',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 40),

                _buildFieldLabel("Nome"),
                _buildCustomInput(initialValue: "Fred Albuquerque"),
                const SizedBox(height: 20),

                _buildFieldLabel("E-mail"),
                _buildCustomInput(initialValue: "fred.alb@gmail.com"),
                const SizedBox(height: 20),

                _buildFieldLabel("Telefone"),
                _buildCustomInput(initialValue: "(11) 99789-6767"),
                const SizedBox(height: 20),

                _buildFieldLabel("CPF"),
                _buildCustomInput(initialValue: "535.456.987-14", isEditable: false),
                const SizedBox(height: 20),

                _buildFieldLabel("Senha"),
                _buildCustomInput(
                  initialValue: "FredAlb1976", 
                  isEditable: false,
                  isPassword: true,
                  obscure: _obscurePassword,
                  onToggle: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3009A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Salvar Alterações",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalletPage()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CataloguePage()),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            );
          }
        },
        selectedItemColor: const Color.fromARGB(255, 77, 51, 142),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Investimentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          label,
          style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
  Widget _buildCustomInput({
    required String initialValue,
    bool isEditable = true,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEditable ? const Color(0xFFF2F2F2) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: TextEditingController(text: initialValue),
        readOnly: !isEditable, 
        obscureText: isPassword ? obscure : false,
        style: TextStyle(color: isEditable ? Colors.black : Colors.black54),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onToggle,
                )
              : null,
        ),
      ),
    );
  }
}
