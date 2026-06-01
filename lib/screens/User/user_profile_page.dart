// Bruno Machado
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart';

class UserProfilePage extends StatefulWidget {
  // Deixa um espaço para ver o perfil de um colega caso o ID seja passado
  final String? userId; 

  const UserProfilePage({super.key, this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String userName = "Carregando...";
  String userBio = "Buscando informações do perfil...";
  bool _isLoading = true;
  
  List<Map<String, dynamic>> userInvestments = [];

  @override
  void initState() {
    super.initState();
    // Vai buscar as informações quando a tela abre
    _fetchUserData();
  }

  // Pede os dados da pessoa para o banco de dados
  Future<void> _fetchUserData() async {
    try {
      final String? targetUid = widget.userId ?? FirebaseAuth.instance.currentUser?.uid;
      if (targetUid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Usuários')
            .doc(targetUid) 
            .get();

        if (doc.exists) {
          final data = doc.data();
          final List<dynamic> rawInvestments = data?['investimentos'] ?? [];
          
          setState(() {
            userName = data?['nome'] ?? "Usuário Sem Nome";
            userBio = data?['descricao'] ?? "Clique aqui para adicionar uma descrição.";
            userInvestments = rawInvestments.map((e) => e as Map<String, dynamic>).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar dados do perfil: $e");
      setState(() => _isLoading = false);
    }
  }

  // Janela flutuante para a pessoa trocar o texto da sua descrição
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

                // Manda o novo texto para o banco
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

  // Lógica da medalha de prestígio dependendo de quantas compras a pessoa fez
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

  // Desenha os cartões menores da lista inferior da tela
  Widget _buildInvestmentCard(Map<String, dynamic> investment) {
    final String startupName = investment['startupName'] ?? 'Desconhecida';
    
    // Tratamento de datas para garantir que fique bonito independente de como venha da internet
    String dateStr = "Data não informada";
    dynamic rawDate = investment['data'] ?? investment['date'];
    
    if (rawDate != null) {
      if (rawDate is Timestamp) {
        final DateTime dt = rawDate.toDate();
        dateStr = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
      } else {
        dateStr = rawDate.toString();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 30, right: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 240, 235, 255),
            ),
            alignment: Alignment.center,
            child: Text(
              startupName.isNotEmpty ? startupName[0].toUpperCase() : 'S',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 77, 51, 142),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startupName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Investido em: $dateStr",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 4, 
      appBarActions: [
        IconButton(
          icon: Image.asset('assets/images/userIcon.png', height: 40, width: 40),
          onPressed: () {}, 
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
                  // ícone de perfil no topo da página
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
                  // nível de prestígio
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
                  // Botão invisível em cima da descrição para a pessoa clicar e editar
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

                  if (userInvestments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Nenhum investimento encontrado.",
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    )
                  else
                    // Constrói os cartões usando a função contruída anteriormente
                    ...userInvestments.map((inv) => _buildInvestmentCard(inv)),
                    
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}