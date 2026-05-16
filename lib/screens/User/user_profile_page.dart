//Bruno Machado
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String userName = "Carregando...";
  String userBio = "Buscando informações do perfil...";
  bool _isLoading = true;
  final List<Startup> userInvestments = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Usuários')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userName = doc.data()?['nome'] ?? "Usuário Sem Nome";
            userBio = doc.data()?['descricao'] ?? "Clique aqui para adicionar uma descrição.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar dados do perfil: $e");
      setState(() => _isLoading = false);
    }
  }

  void _editBioDialog() {
    final TextEditingController bioController = TextEditingController(text: userBio);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Descrição", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: bioController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Diga algo sobre você...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 77, 51, 142)),
              onPressed: () async {
                final newBio = bioController.text.trim();
                final user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('Usuários')
                      .doc(user.uid)
                      .update({'descricao': newBio});

                  setState(() {
                    userBio = newBio;
                  });
                }
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Salvar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String get userStatus {
    int count = userInvestments.length;
    if (count >= 7) return "Investidor Expert";
    if (count >= 3) return "Investidor Assíduo";
    return "Investidor Novato";
  }

  Color get statusColor {
    int count = userInvestments.length;
    if (count >= 7) return const Color(0xFFE1BEE7);
    if (count >= 3) return const Color(0xFFC8E6C9);
    return const Color(0xFFBBDEFB);
  }

  Color get statusTextColor {
    int count = userInvestments.length;
    if (count >= 7) return const Color(0xFF4A148C);
    if (count >= 3) return const Color(0xFF1B5E20);
    return const Color(0xFF0D47A1);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 4, 
      appBarActions: [
        IconButton(
          icon: Image.asset('assets/images/userIcon.png', height: 40, width: 40),
          onPressed: () {}, // Já está na página de perfil
        ),
        IconButton(
          icon: Image.asset('assets/images/configIcon.png', height: 40, width: 40),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigPage()));
          },
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color.fromARGB(255, 77, 51, 142), width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color.fromARGB(255, 230, 225, 245),
                        child: Icon(Icons.person, size: 60, color: Color.fromARGB(255, 77, 51, 142)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userName,
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userStatus,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: statusTextColor),
                    ),
                  ),
                  InkWell(
                    onTap: _editBioDialog,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Column(
                        children: [
                          Text(
                            userBio,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 4),
                          const Icon(Icons.edit, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 40, thickness: 1, indent: 30, endIndent: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Meus Investimentos (${userInvestments.length})",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 77, 51, 142),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}