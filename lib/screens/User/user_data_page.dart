import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart'; 
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';

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
  final _selectedIndex = 2; 

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao salvar alterações.")),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: _selectedIndex,
      appBarActions: [
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
}