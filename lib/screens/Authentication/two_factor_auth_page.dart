import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/catalogue_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_integrador_3_grupo_17/services/authentication/auth_services.dart';

class TwoFactorAuthPage extends StatefulWidget {
  final String? verificationId;
  final MultiFactorResolver? resolver;

  const TwoFactorAuthPage({super.key, this.verificationId, this.resolver});

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage> {
  late String _idAtivo;
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  // pega o código inteiro do usuário
  String get _fullCode => _controllers.map((c) => c.text).join();
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    Image.asset(
                      'assets/images/logoMesclaInvest.png',
                      width: 260,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      'Digite seu código de 6 dígitos enviado para seu numero de telefone',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 45,
                          height: 55,
                          child: TextField(
                            controller: _controllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFFF2F2F2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFF3009A),
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.length == 1 && index < 5) {
                                FocusScope.of(context).nextFocus();
                              }

                              if (value.isEmpty && index > 0) {
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não recebeu? ',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await AuthService().sendLoginSms(
                              resolver: widget.resolver!,
                              onSmsSent: (vId) {
                                setState(() {
                                  _idAtivo = vId;
                                });
                                for (var c in _controllers) {
                                  c.clear();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Novo código enviado!"),
                                  ),
                                );
                              },
                              onError: (erro) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Erro ao reenviar'),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            'Reenviar código',
                            style: TextStyle(
                              color: Color(0xFFF3009A),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3009A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          // Beatriz Naomi
                          String codigoFinal = _fullCode;
                          if (codigoFinal.length == 6) {
                            try{
                                final String vId = widget.verificationId ?? "";

                                if ( widget.resolver == null) {
                                  if (vId.isEmpty) throw "ID de verificação ausente.";
                                  await AuthService().validateCode(
                                    verificationId: widget.verificationId ?? _idAtivo,
                                    smsCode: codigoFinal,
                                  );
                                  if (!context.mounted) return;
                                  Navigator.pop(context, true);
                                } else if (widget.resolver != null) {
                                  if (vId.isEmpty) throw "ID de verificação de login ausente.";
                                  final credential = PhoneAuthProvider.credential(
                                    verificationId: widget.verificationId!,
                                    smsCode: codigoFinal,
                                  );
                                  final assertion =
                                      PhoneMultiFactorGenerator.getAssertion(
                                        credential,
                                      );
                                  await widget.resolver!.resolveSignIn(assertion);
                                  if (!context.mounted) return;

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CataloguePage(),
                                    ),
                                  );
                                } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Código incompleto"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                          } on FirebaseAuthException catch (e) {
                                String mensagem = "Erro ao validar código";
                                if (e.code == 'requires-recent-login') {
                                  mensagem = "Sessão expirada. Por favor, saia e entre novamente no app antes de ativar o 2FA.";
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(mensagem), backgroundColor: Colors.red),
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
}
