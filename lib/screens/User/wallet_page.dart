import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _selectedIndex = 0; // Ícone de Investimentos/Carteira selecionado
  double _currentBalance = 0;
  bool _isLoading = true; 
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: 'R\$ ', hintText: '0,00'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              double? value = double.tryParse(_valueController.text.replaceAll(',', '.'));
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
    return MainLayout(
      selectedIndex: _selectedIndex,
      appBarActions: [
        IconButton(
          icon: Image.asset('assets/images/userIcon.png', height: 40, width: 40),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfilePage())),
        ),
        IconButton(
          icon: Image.asset('assets/images/configIcon.png', height: 40, width: 40),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfigPage())),
        ),
      ],
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
    );
  }
}