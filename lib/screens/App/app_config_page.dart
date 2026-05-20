//Bruno Machado
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/forgotten_password_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/login_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/Authentication/two_factor_auth_page.dart';
import 'package:projeto_integrador_3_grupo_17/services/authentication/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart'; 

class AppConfigPage extends StatefulWidget {
  const AppConfigPage({super.key});

  @override
  State<AppConfigPage> createState() => _AppConfigPageState();
}

class _AppConfigPageState extends State<AppConfigPage> {
  bool isMultiFactorSession = false;
  bool receiveNotifications = true;
  String selectedLanguage = 'Português (BR)';
  String selectedCurrency = 'BRL';
  final List<String> languages = ['Português (BR)', 'English (US)', 'Español'];
  final List<String> currencies = ['BRL', 'USD', 'EUR'];

  @override
  void initState() {
    super.initState();
    _checkMFAStatus();
  }

  void _iniciar2FA(BuildContext context){
    try {
      AuthService().setupTwoFactor(
        onSmsSent: (vId) async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TwoFactorAuthPage(
                verificationId: vId,
              ),
            ),
          );

          if (result == true) {
            _checkMFAStatus();
          }
        },
        onError: (erro) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $erro'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
  
      } catch (e) {
        if (e.toString().contains('requires-recent-login')) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Por segurança, faça login novamente para alterar esta configuração.',
              ),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        }
      }
                        
  }
  void _checkMFAStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final mfa = user.multiFactor;
      final factors = await mfa.getEnrolledFactors();
      setState(() {
        isMultiFactorSession = factors.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 1, 
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configurações do App',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Personalize o aplicativo',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Preferências',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: Column(
                  children: [
                    SwitchListTile(
                      value: isMultiFactorSession,
                      onChanged: (v) async {
                        if (v) {
                          final user = FirebaseAuth.instance.currentUser;
                          await user?.reload();
                          if (user != null && !user.emailVerified) {
                            await AuthService().sendEmailVerification();
                            if (!context.mounted) return;

                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Verificação Necessária'),
                                content: const Text('Enviamos um link para o seu e-mail. Clique no link e depois aperte em "Já verifiquei".'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final user = FirebaseAuth.instance.currentUser;
                                      await user?.reload(); 
                                      final usuarioAtualizado = FirebaseAuth.instance.currentUser;
                                      if (usuarioAtualizado != null && usuarioAtualizado.emailVerified) {
                                        Navigator.pop(dialogContext); 
                                        _iniciar2FA(context); 
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('E-mail ainda não verificado!')),
                                        );
                                      }
                                    },
                                    child: const Text('Já verifiquei'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                          _iniciar2FA(context);
                        } else{
                           
                          try {
                            await AuthService().unenrollMFA();
                            _checkMFAStatus();
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Autenticação de dois fatores desativada.'),
                              ),
                            );
                          } catch (e) {
                            if (e.toString().contains('requires-recent-login')) {
                              setState(() => isMultiFactorSession = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por segurança, faça login novamente para desativar o 2FA.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      title: Text(
                        'Autenticação 2FA',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        isMultiFactorSession ? 'Ativado' : 'Desativado',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      secondary: const Icon(Icons.phonelink_lock),
                    ),

                    const Divider(height: 1),

                    ListTile(
                      leading: const Icon(Icons.language),
                      title: Text(
                        'Idioma',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        selectedLanguage,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: selectedLanguage,
                        underline: const SizedBox(),
                        items: languages
                            .map(
                              (l) => DropdownMenuItem(
                                value: l,
                                child: Text(l, style: GoogleFonts.poppins()),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => selectedLanguage = v);
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    ListTile(
                      leading: const Icon(Icons.monetization_on),
                      title: Text(
                        'Moeda',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        selectedCurrency,
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: selectedCurrency,
                        underline: const SizedBox(),
                        items: currencies
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c, style: GoogleFonts.poppins()),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => selectedCurrency = v);
                        },
                      ),
                    ),

                    const Divider(height: 1),

                    SwitchListTile(
                      value: receiveNotifications,
                      onChanged: (v) => setState(() => receiveNotifications = v),
                      title: Text(
                        'Notificações',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        receiveNotifications ? 'Receber notificações' : 'Silenciado',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      secondary: const Icon(Icons.notifications),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Conta e Segurança',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text(
                        'Alterar senha',
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgottenPasswordPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.fingerprint),
                      title: Text(
                        'Autenticação biométrica',
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Configuração biométrica'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Sobre',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(
                        'Versão do app',
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: Text(
                        'v1.0.0',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(
                        'Termos e Privacidade',
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Termos e Privacidade'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.update),
                      title: Text(
                        'Verificar atualizações',
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verificando atualizações'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          isMultiFactorSession = false;
                          receiveNotifications = true;
                          selectedLanguage = languages.first;
                          selectedCurrency = currencies.first;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Configurações restauradas'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Restaurar Padrões',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Configurações salvas'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('Salvar', style: GoogleFonts.poppins()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}