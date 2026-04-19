// tela de login do app

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //visibilidade do campo senha
  bool _obscurePassword = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              
              // logo
              Image.asset(
                'assets/images/logoMesclaInvest.png',
                width: 387,
                height: 166,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),

              // texto bem-vindo
              const Text(
                'Bem vindo de volta!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF3009A),
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // texto dps do bem vindo
              SizedBox(
                width: 322,
                height: 81,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Entre em sua conta para acessar o aplicativo',
                      style: TextStyle(
                        color: Color(0xFF313131), fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // formulário do login 
              SizedBox(
                width: 322,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [              
                    // campo para o e-mail
                    SizedBox(
                      width: 157,
                      height: 25,
                      child: RichText(
                        text: TextSpan(
                          text: 'E-mail',
                          style: TextStyle(
                            color: Color(0xFF272727),
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Color(0xFFFF0000)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: 322,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFFEFEFEF), 
                        borderRadius: BorderRadius.circular(15), 
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40000000), 
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16, right: 8), 
                      child: TextField(
                        obscureText: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Insira seu e-mail', 
                          hintStyle: TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // campo para senha
                    SizedBox(
                      width: 157,
                      height: 25,
                      child: RichText(
                        text: TextSpan(
                          text: 'Senha',
                          style: TextStyle(
                            color: Color(0xFF272727),
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Color(0xFFFF0000)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: 322,
                      height: 50,
                      decoration: BoxDecoration(
                        color:  Color(0xFFEFEFEF), 
                        borderRadius: BorderRadius.circular(15), 
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40000000), 
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 16, right: 8), 
                      child: TextField(
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Informe sua senha', 
                          hintStyle: TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Color(0xFF313131),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ), 
                    const SizedBox(height: 20),

                    // texto esqueci minha senha
                    Text(
                      'Esqueci minha senha',
                      style: TextStyle(
                        color: Color(0xFFF3009A),
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // botão para entrar
                    Container(
                      width: 322,
                      height: 51,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40000000), 
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF3009A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0, 
                        ),
                        onPressed: () {},
                        child: Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // texto para cadastrar-se
                    Center(
                      child: SizedBox(
                        width: 421, 
                        height: 29,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'Não tem uma conta? ',
                            style: TextStyle(
                              color: Color(0xFF8C8C8C), 
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(
                                text: 'Cadastre-se Aqui!',
                                style: TextStyle(
                                  color: Color(0xFFF3009A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
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