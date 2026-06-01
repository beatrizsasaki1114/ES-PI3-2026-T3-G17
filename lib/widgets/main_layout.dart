//Bruno Machado

//Imports usados no layout do projeto, incluindo appbar, bottombar e sidebar/drawer
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:projeto_integrador_3_grupo_17/screens/App/catalogue_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/wallet_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_investments_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/login_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/tradecenter_page.dart';

//O MainLayout é uma estrutura geral do aplicativo, por isso está num arquivo separado para ser encorporado na maioria das outras páginas mais facilmente, 
//o que ele faz é basicamente encapsular o scaffold principal da página com esse layout

//Cria um widget de molde para indicar a parte da tela que será alterada
//O selectedIndex mostra na bottom bar qual página o usuário está, ou caso ele não esteja em nenhum das indicadas, mostra o botão central
//O appBarActions permite a adição e remoção de botões em algumas páginas caso necessitado
class MainLayout extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final List<Widget>? appBarActions;

  const MainLayout({
    super.key,
    required this.body,
    required this.selectedIndex,
    this.appBarActions,
  });

//Função para construir os itens do drawer/sidebar, você passa apenas o ícone e o nome do botão, além de sua ação no OnTap
  Widget _buildDrawerItem({
    required BuildContext context,
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

      //A AppBar é o menu superior do aplicativo, ele dá ao usuário algumas opções de navegação para o catálogo, 
      //sua página de perfil, a abertura do drawer e as configurações
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 65,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset(
              'assets/images/menuIcon.png',
              height: 40,
              width: 40,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: InkWell(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CataloguePage()),
              (route) => false,
            );
          },
          child: Transform.translate(
            offset: const Offset(0, -6),
            child: Image.asset(
              'assets/images/logoMesclaInvest.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: appBarActions,
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
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Color.fromARGB(255, 77, 51, 142),
                    ),
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

            //Aqui são construídos os itens do drawer, eles incluem os botões de navegação para o catálogo, carteira, investimentos do usuário,
            //configurações, perfil do usuário e a opção de sair da conta
            _buildDrawerItem(
              context: context,
              icon: Icons.business_center,
              text: 'Catálogo de Startups',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CataloguePage()));
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.account_balance_wallet,
              text: 'Minha Carteira',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletPage()));
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.trending_up,
              text: 'Investimentos',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UserInvestmentsPage()));
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.person,
              text: 'Meu Perfil',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage()));
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.settings,
              text: 'Configurações',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigPage()));
              },
            ),
            const Divider(),
            _buildDrawerItem(
              context: context,
              icon: Icons.exit_to_app,
              text: 'Sair',
              color: Colors.red,
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

      //Aqui fica a barra de navegação inferior, ela dá ao usuário uma forma dinâmica de navegar pelo aplicativo nas telas principais dele, 
      //ela apresenta os botões de catálogo de startups, carteira, investimentos do usuário, perfil do usuário e o balcão de venda de tokens.
      body: SafeArea(child: body),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == selectedIndex) return;
          
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletPage()));
          } else if (index == 2) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CataloguePage()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OffersPage()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UserInvestmentsPage()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage()));
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
            icon: Icon(Icons.storefront),
            label: 'Balcão de Tokens',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Meus Investimentos',
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