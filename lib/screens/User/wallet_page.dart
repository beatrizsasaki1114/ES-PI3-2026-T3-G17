//Bruno Machado

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/catalogue_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/login_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _selectedIndex = 0;
  double _currentBalance = 0;
  bool _isLoading = true; 
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('Usuários').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _currentBalance = (doc.data()?['saldo'] ?? 0).toDouble();
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar saldo: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addFunds(double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newBalance = _currentBalance + amount;

    try {
      await FirebaseFirestore.instance.collection('Usuários').doc(user.uid).update({
        'saldo': newBalance,
      });

      setState(() {
        _currentBalance = newBalance;
      });

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('R\$ ${amount.toStringAsFixed(2)} adicionados com sucesso!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao processar transação no servidor.')),
        );
      }
    }
  }

  void _showValueInput(bool isPix) {
    _valueController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quanto deseja adicionar?', style: GoogleFonts.poppins()),
        content: TextField(
          controller: _valueController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: 'R\$ ', hintText: '0,00'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              double? value = double.tryParse(_valueController.text);
              if (value != null && value > 0) {
                Navigator.pop(context);
                isPix ? _showPixPayment(value) : _showCardPayment(value);
              }
            },
            child: const Text('Próximo'),
          ),
        ],
      ),
    );
  }

  void _showCardPayment(double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dados do Cartão - R\$ ${amount.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(decoration: InputDecoration(labelText: 'Número do Cartão')),
              const TextField(decoration: InputDecoration(labelText: 'Nome no Cartão')),
              Row(
                children: [
                  Expanded(child: const TextField(decoration: InputDecoration(labelText: 'Validade (MM/AA)'))),
                  const SizedBox(width: 10),
                  Expanded(child: const TextField(decoration: InputDecoration(labelText: 'CVV'))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => _addFunds(amount),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Confirmar Pagamento', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPixPayment(double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pagamento via PIX'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Valor: R\$ ${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              width: 150,
              height: 150,
              color: Colors.grey[200],
              child: const Icon(Icons.qr_code_2, size: 100),
            ),
            const SizedBox(height: 10),
            const Text(
              'Aponte a câmera ou copie o código', 
              style: TextStyle(fontSize: 12), 
              textAlign: TextAlign.center
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _addFunds(amount),
            child: const Text('QRCode Pago', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CataloguePage()),
              (route) => false,
            );
          },
          child: Image.asset('assets/images/logoMesclaInvest.png', height: 80, fit: BoxFit.contain),
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
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              icon: Icons.trending_up,
              text: 'Investimentos',
              onTap: () => Navigator.pop(context), 
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
              onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 250,
                    color: const Color.fromARGB(255, 77, 51, 142).withValues(alpha: 0.1),
                  ),
                  Column(
                    children: [
                      Text(
                        'Saldo Atual',
                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                      ),
                      _isLoading 
                        ? const CircularProgressIndicator()
                        : Text(
                            'R\$ ${_currentBalance.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 77, 51, 142),
                            ),
                          ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Adicionar Saldo via:',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showValueInput(false), 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 77, 51, 142),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.credit_card, color: Colors.white),
                      label: const Text('Cartão de Crédito', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () => _showValueInput(true), 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 182, 38, 111),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.pix, color: Colors.white),
                      label: const Text('PIX', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const CataloguePage()), (r) => false);
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfilePage()));
          }
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