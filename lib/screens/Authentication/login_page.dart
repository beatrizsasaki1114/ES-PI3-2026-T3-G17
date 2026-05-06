//Bruno Machado

import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/authentication/create_account_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/authentication/forgotten_password_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/app/catalogue_page.dart';
import 'package:projeto_integrador_3_grupo_17/services/authentication/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
                      'Bem vindo!',
                      style: TextStyle(
                        color: Color(0xFFF3009A),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Entre em sua conta para acessar o aplicativo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF313131), fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    _buildFieldLabel("E-mail"),
                    const SizedBox(height: 8),
                    _buildCustomInput(
                      hint: "Insira seu e-mail",
                      controller: emailController,
                    ),

                    const SizedBox(height: 20),

                    _buildFieldLabel("Senha"),
                    const SizedBox(height: 8),
                    _buildCustomInput(
                      hint: "Informe sua senha",
                      controller: passwordController,
                      isPassword: true,
                      obscure: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgottenPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Esqueci minha senha',
                            style: TextStyle(
                              color: Color(0xFFF3009A),
                              fontWeight: FontWeight.bold,
                            ),  
                          ),
                        ),
                      ),
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
                          if (emailController.text == "" ||
                              passwordController.text == "") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Todos os campos são obrigatórios",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            try {
                              await AuthService().signIn(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              debugPrint("Sucesso");
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CataloguePage(),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              String mensagem;

                              if (e.code == 'user-not-found') {
                                mensagem = "Usuário não encontrado";

                              } else if (e.code == 'wrong-password') {
                                mensagem = "Senha incorreta";

                              } else {
                                mensagem = "Erro ao fazer login";
                              }
                              debugPrint(mensagem);
                              if (!context.mounted) return;
                               ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(mensagem),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                            }
                          }
                        },
                        child: const Text(
                          'Entrar',
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
                          'Não tem uma conta? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateAccountPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Cadastre-se Aqui!',
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
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
