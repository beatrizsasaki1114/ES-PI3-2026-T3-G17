
import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/catalogue_page.dart';

class UserConfigPage extends StatefulWidget {
  const UserConfigPage({super.key});

  @override
  State<UserConfigPage> createState() => _UserConfigPageState();
}

class _UserConfigPageState extends State<UserConfigPage> {
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
                  "Informações do Usuário",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
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
