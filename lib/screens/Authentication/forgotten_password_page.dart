//Bruno Machado e Beatriz Naomi

import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/services/authentication/auth_services.dart';

class ForgottenPasswordPage extends StatefulWidget {
  const ForgottenPasswordPage({super.key});

  @override
  State<ForgottenPasswordPage> createState() => _ForgottenPasswordPageState();
}

class _ForgottenPasswordPageState extends State<ForgottenPasswordPage> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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

            Positioned.fill(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                        'Para recuperar sua conta, insira seu email.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF313131),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),

                      _buildFieldLabel("E-mail"),
                      const SizedBox(height: 8),
                      _buildCustomInput(
                        hint: "Insira seu e-mail",
                        controller: emailController),

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
                            if (emailController.text == "") {
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
                                await AuthService().resetPassword(
                                  email: emailController.text,
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Email enviado!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              
                              
                              } catch (e, stackTrace) {
                               
                                debugPrint("Erro: $e");
                                debugPrint("Stacktrace: $stackTrace");
                              }
                            }
              
                            },
                          
                          child: const Text(
                              'Enviar Email',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 30,
              left: 20,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    'assets/images/backButton.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
