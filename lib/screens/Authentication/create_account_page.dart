//Bruno Machado e Beatriz Naomi

import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/authentication/login_page.dart';
import 'package:projeto_integrador_3_grupo_17/services/authentication/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmEmailController = TextEditingController();
  TextEditingController telefoneController = TextEditingController();
  TextEditingController cpfController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;


  bool _hasMinLength = false;
  bool _hasMinNumbers = false;
  bool _hasNoSpecialChars = false;


  void _validatePassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 6;
      _hasMinNumbers = RegExp(r'\d').allMatches(value).length >= 2;
      _hasNoSpecialChars = value.isNotEmpty && !RegExp(r'[^a-zA-Z0-9]').hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                'assets/images/sideImage1.png',
                width: screenWidth * 0.6,
                fit: BoxFit.contain,
              ),
            ),
            SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),

                    Image.asset(
                      'assets/images/logoMesclaInvest.png',
                      width: 320,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      'Crie Sua Conta!',
                      style: TextStyle(
                        color: Color(0xFFF3009A),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Crie uma conta para acessar o aplicativo!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF313131), fontSize: 16),
                    ),

                    const SizedBox(height: 40),

                    _buildFieldLabel("Nome"),
                    const SizedBox(height: 4),
                    _buildCustomInput(
                      hint: "Insira seu nome",
                      controller: firstNameController,
                    ),

                    const SizedBox(height: 8),

                    _buildFieldLabel("Sobrenome"),
                    const SizedBox(height: 4),
                    _buildCustomInput(
                      hint: "Insira seu sobrenome",
                      controller: lastNameController,
                    ),

                    const SizedBox(height: 8),

                    _buildFieldLabel("E-mail"),
                    const SizedBox(height: 4),
                    _buildCustomInput(
                      hint: "Insira seu e-mail",
                      controller: emailController,
                    ),

                    const SizedBox(height: 8),

                    _buildFieldLabel("Confirmar E-mail"),
                    const SizedBox(height: 4),
                    _buildCustomInput(
                      hint: "Confirme seu e-mail",
                      controller: confirmEmailController,
                    ),

                    const SizedBox(height: 8),

                    _buildFieldLabel("Telefone"),
                    const SizedBox(height: 4),
                    _buildCustomInput(
                      hint: "Insira seu telefone",
                      controller: telefoneController,
                    ),

                    const SizedBox(height: 8),

                    _buildFieldLabel("CPF"),
                    const SizedBox(height: 4),
                    _buildCustomInput(
                      hint: "Insira seu CPF",
                      controller: cpfController,
                    ),

                    const SizedBox(height: 8),

                    _buildFieldLabel("Senha"),
                    const SizedBox(height: 4),
                    _buildCustomInput(
                      hint: "Informe sua senha",
                      controller: passwordController,
                      isPassword: true,
                      obscure: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                      onChanged: _validatePassword, 
                    ),

                    const SizedBox(height: 8),

                    _buildPasswordRule("Pelo menos 6 dígitos", _hasMinLength),
                    _buildPasswordRule("No mínimo 2 números", _hasMinNumbers),
                    _buildPasswordRule("Sem caracteres especiais", _hasNoSpecialChars),

                    const SizedBox(height: 8),

                    _buildFieldLabel("Confirme sua Senha"),
                    const SizedBox(height: 4),
                    _buildCustomInput(
                      hint: "Confirme sua senha",
                      controller: confirmPasswordController,
                      isPassword: true,
                      obscure: _obscurePassword,
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3009A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          if (emailController.text.trim().isEmpty ||
                              firstNameController.text.trim().isEmpty ||
                              lastNameController.text.trim().isEmpty ||
                              passwordController.text.isEmpty ||
                              confirmPasswordController.text.isEmpty ||
                              telefoneController.text.trim().isEmpty ||
                              cpfController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Todos os campos são obrigatórios"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return; 
                          } 
                          
                          if (!_hasMinLength || !_hasMinNumbers || !_hasNoSpecialChars) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("A senha não atende a todos os requisitos"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return; 
                          }

                          if (passwordController.text != confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("As senhas não coincidem"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return; 
                          } 
                          

                          if (emailController.text != confirmEmailController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("E-mails não coincidem"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return; 
                          } 
                          

                          try {
                            User? result = await AuthService().createAccount(
                              nome: firstNameController.text.trim(),
                              sobrenome: lastNameController.text.trim(),
                              email: emailController.text.trim(),
                              telefone: telefoneController.text.trim(),
                              cpf: cpfController.text.trim(),
                              password: passwordController.text,
                            );
                            if (result != null) {
                              debugPrint("Sucesso");
                              if (!context.mounted) return;
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Conta criada com sucesso!"),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()), 
                                backgroundColor: Colors.red
                              ),
                            );
                            debugPrint("ERRO: $e");
                          }
                        },
                        child: const Text(
                          'Criar Conta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Já tem uma conta? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement( 
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Faça login Aqui!',
                              style: TextStyle(
                                color: Color(0xFFF3009A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordRule(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomInput({
    required String hint,
    TextEditingController? controller,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    ValueChanged<String>? onChanged, 
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05), 
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
        onChanged: onChanged, 
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
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