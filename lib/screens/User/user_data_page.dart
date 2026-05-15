//Bruno Machado

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _cpf = "";

  bool _isLoading = true;
  final _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Usuários')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _firstNameController.text = data['nome'] ?? "";
            _lastNameController.text = data['sobrenome'] ?? "";
            _emailController.text = data['email'] ?? user.email ?? "";
            _phoneController.text = data['telefone'] ?? "";
            _cpf = data['cpf'] ?? "Não informado";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Usuários')
            .doc(user.uid)
            .update({
              'nome': _firstNameController.text.trim(),
              'sobrenome': _lastNameController.text.trim(),
              'email': _emailController.text.trim(),
              'telefone': _phoneController.text.trim(),
            });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Dados atualizados com sucesso!")),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      debugPrint("Erro ao atualizar: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao salvar alterações.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Informações de Usuário',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      _buildFieldLabel("Nome"),
                      _buildCustomInput(controller: _firstNameController),
                      const SizedBox(height: 20),

                      _buildFieldLabel("Sobrenome"),
                      _buildCustomInput(controller: _lastNameController),
                      const SizedBox(height: 20),

                      _buildFieldLabel("E-mail"),
                      _buildCustomInput(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      _buildFieldLabel("Telefone"),
                      _buildCustomInput(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),

                      _buildFieldLabel("CPF"),
                      _buildCustomInput(initialValue: _cpf, isEditable: false),

                      const SizedBox(height: 40),
                      _buildSaveButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3009A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _updateUserData,
        child: const Text(
          "Salvar Alterações",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomInput({
    TextEditingController? controller,
    String? initialValue,
    bool isEditable = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isEditable ? const Color(0xFFF2F2F2) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller ?? TextEditingController(text: initialValue),
        readOnly: !isEditable,
        keyboardType: keyboardType,
        style: TextStyle(color: isEditable ? Colors.black : Colors.black54),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      toolbarHeight: 65,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Image.asset('assets/images/menuIcon.png', height: 40),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: InkWell(
        onTap: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CataloguePage()),
          (route) => false,
        ),
        child: Image.asset('assets/images/logoMesclaInvest.png', height: 80),
      ),
      actions: [
        IconButton(
          icon: Image.asset('assets/images/userIcon.png', height: 40),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserProfilePage()),
          ),
        ),
        IconButton(
          icon: Image.asset('assets/images/configIcon.png', height: 40),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ConfigPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 77, 51, 142)),
            child: Center(
              child: Text(
                "Mescla Invest",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          _buildDrawerItem(
            Icons.business_center,
            'Catálogo',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CataloguePage()),
            ),
          ),
          _buildDrawerItem(
            Icons.account_balance_wallet,
            'Carteira',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalletPage()),
            ),
          ),
          _buildDrawerItem(
            Icons.person,
            'Perfil',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProfilePage()),
            ),
          ),
          const Divider(),

          _buildDrawerItem(
            Icons.exit_to_app,
            'Sair',
            () => FirebaseAuth.instance.signOut().then(
              (_) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
            ),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String text,
    VoidCallback onTap, {
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WalletPage()),
          );
        if (index == 1)
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const CataloguePage()),
            (route) => false,
          );
        if (index == 2)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserProfilePage()),
          );
      },
      selectedItemColor: const Color.fromARGB(255, 77, 51, 142),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: 'Investimentos',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
