import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/catalogue_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _selectedIndex = 0;
  double _currentBalance = 0; 
  final TextEditingController _valueController = TextEditingController();

 
  void _addFunds(double amount) {
    setState(() {
      _currentBalance += amount;
    });


    Navigator.of(context, rootNavigator: true).pop();

  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('R\$ ${amount.toStringAsFixed(2)} adicionados com sucesso!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 65,
        leading: IconButton(
          icon: Image.asset('assets/images/menuIcon.png', height: 40, width: 40),
          onPressed: () {},
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
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfilePage()));
            },
          ),
          IconButton(
            icon: Image.asset('assets/images/configIcon.png', height: 40, width: 40),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigPage()));
            },
          ),
        ],
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
                    color: const Color.fromARGB(255, 77, 51, 142).withValues(alpha:0.1),
                  ),
                  Column(
                    children: [
                      Text(
                        'Saldo Atual',
                        style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
                      ),
                      Text(
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
                      onPressed: () => _showValueInput(false), // Cartão
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
                      onPressed: () => _showValueInput(true), // PIX
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
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CataloguePage()),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfilePage()));
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