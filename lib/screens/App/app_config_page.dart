//Bruno Machado

import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/catalogue_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/forgotten_password_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/wallet_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/login_page.dart';

class AppConfigPage extends StatefulWidget {
  const AppConfigPage({super.key});

  @override
  State<AppConfigPage> createState() => _AppConfigPageState();
}

class _AppConfigPageState extends State<AppConfigPage> {
  final _selectedIndex = 1;
  bool isDarkTheme = false;
  bool receiveNotifications = true;
  String selectedLanguage = 'Português (BR)';
  String selectedCurrency = 'BRL';
  final List<String> languages = ['Português (BR)', 'English (US)', 'Español'];
  final List<String> currencies = ['BRL', 'USD', 'EUR'];
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
                  builder: (context) => const  ConfigPage(),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configurações do App',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Personalize o aplicativo',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Preferências',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: isDarkTheme,
                        onChanged: (v) => setState(() => isDarkTheme = v),
                        title: Text(
                          'Tema escuro',
                          style: GoogleFonts.poppins(textStyle: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        subtitle: Text(
                          isDarkTheme ? 'Ativado' : 'Desativado',
                          style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.grey.shade600)),
                        ),
                        secondary: const Icon(Icons.dark_mode),
                      ),

                      const Divider(height: 1),


                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(
                          'Idioma',
                          style: GoogleFonts.poppins(textStyle: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        subtitle: Text(
                          selectedLanguage,
                          style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.grey.shade600)),
                        ),
                        trailing: DropdownButton<String>(
                          value: selectedLanguage,
                          underline: const SizedBox(),
                          items: languages
                              .map((l) => DropdownMenuItem(value: l, child: Text(l, style: GoogleFonts.poppins())))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => selectedLanguage = v);
                          },
                        ),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(Icons.monetization_on),
                        title: Text(
                          'Moeda',
                          style: GoogleFonts.poppins(textStyle: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        subtitle: Text(
                          selectedCurrency,
                          style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.grey.shade600)),
                        ),
                        trailing: DropdownButton<String>(
                          value: selectedCurrency,
                          underline: const SizedBox(),
                          items: currencies
                              .map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins())))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => selectedCurrency = v);
                          },
                        ),
                      ),

                      const Divider(height: 1),

                      SwitchListTile(
                        value: receiveNotifications,
                        onChanged: (v) => setState(() => receiveNotifications = v),
                        title: Text(
                          'Notificações',
                          style: GoogleFonts.poppins(textStyle: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        subtitle: Text(
                          receiveNotifications ? 'Receber notificações' : 'Silenciado',
                          style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.grey.shade600)),
                        ),
                        secondary: const Icon(Icons.notifications),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Conta e Segurança',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: Text('Alterar senha', style: GoogleFonts.poppins()),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const  ForgottenPasswordPage(),
                                  ),
                            );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.fingerprint),
                        title: Text('Autenticação biométrica', style: GoogleFonts.poppins()),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Configuração biométrica')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Sobre',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text('Versão do app', style: GoogleFonts.poppins()),
                        trailing: Text('v1.0.0', style: GoogleFonts.poppins(textStyle: const TextStyle(fontWeight: FontWeight.w600))),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text('Termos e Privacidade', style: GoogleFonts.poppins()),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Termos e Privacidade')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.update),
                        title: Text('Verificar atualizações', style: GoogleFonts.poppins()),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Verificando atualizações')),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {

                          setState(() {
                            isDarkTheme = false;
                            receiveNotifications = true;
                            selectedLanguage = languages.first;
                            selectedCurrency = currencies.first;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Configurações restauradas')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Restaurar Padrões', style: GoogleFonts.poppins()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Configurações salvas')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Salvar', style: GoogleFonts.poppins()),
                      ),
                    ),
                  ],
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
}
