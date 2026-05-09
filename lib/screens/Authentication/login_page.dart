import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/create_account_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/forgotten_password_page.dart';
<<<<<<< HEAD
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/two_factor_auth_page.dart';
=======
import 'package:projeto_integrador_3_grupo_17/screens/App/catalogue_page.dart';


>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

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
<<<<<<< HEAD

=======
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
                    Image.asset(
                      'assets/images/logoMesclaInvest.png',
                      width: 320,
                      fit: BoxFit.contain,
                    ),
<<<<<<< HEAD

                    const SizedBox(height: 40),

=======
                    const SizedBox(height: 40),
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
                    const Text(
                      'Bem vindo!',
                      style: TextStyle(
                        color: Color(0xFFF3009A),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
<<<<<<< HEAD

                    const SizedBox(height: 10),

                    const Text(
                      'Entre em sua conta para acessar o aplicativo',
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
                    ),
=======
                    const SizedBox(height: 10),
                    const Text(
                      'Entre em sua conta para acessar o aplicativo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF313131), fontSize: 16),
                    ),
                    const SizedBox(height: 40),

                    _buildFieldLabel("E-mail"),
                    const SizedBox(height: 8),
                    _buildCustomInput(hint: "Insira seu e-mail"),
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2

                    const SizedBox(height: 20),

                    _buildFieldLabel("Senha"),
<<<<<<< HEAD

                    const SizedBox(height: 8),

=======
                    const SizedBox(height: 8),
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
                    _buildCustomInput(
                      hint: "Informe sua senha",
                      isPassword: true,
                      obscure: _obscurePassword,
<<<<<<< HEAD
                      onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                      ),
=======
                      onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
                    ),

                    const SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: MouseRegion(
<<<<<<< HEAD
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ForgottenPasswordPage(),
                              ),
=======
                        cursor: SystemMouseCursors.click, 
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const  ForgottenPasswordPage(),
                                  ),
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
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
<<<<<<< HEAD

=======
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3009A),
<<<<<<< HEAD
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
=======
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.push(
<<<<<<< HEAD
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const TwoFactorAuthPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
=======
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CataloguePage(),
                                    ),
                                  );
                        },
                        child: const Text(
                          'Entrar',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não tem uma conta? ',
<<<<<<< HEAD
                          style: TextStyle(
                            color: Colors.grey,
                          ),
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
=======
                          style: TextStyle(color: Colors.grey),
                        ),
                        MouseRegion(
                            cursor: SystemMouseCursors.click, 
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const  CreateAccountPage(),
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
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
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
<<<<<<< HEAD
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
=======
          style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),
          children: const [
            TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
          ],
        ),
      ),
    );
  }

  Widget _buildCustomInput({
    required String hint,
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
<<<<<<< HEAD
            color: Colors.black.withValues(alpha: 0.05),
=======
            color: Colors.black.withValues(alpha:0.05),
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        obscureText: isPassword ? obscure : false,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
<<<<<<< HEAD
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: onToggle,
          )
=======
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onToggle,
                )
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
              : null,
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> c6d172fc9248897ae5295f6eae3191946aeb8da2
