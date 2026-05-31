// Bruno Machado, Luca Filippi e Heloisa Marinho

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Cria a página de conversa e exige que o nome da empresa seja informado para abrir
class PrivateChatPage extends StatefulWidget {
  final String startupName;

  const PrivateChatPage({super.key, required this.startupName});

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  // Ferramenta que guarda o que a pessoa está digitando na caixa de texto
  final TextEditingController _messageController = TextEditingController();
  // Ferramenta que controla a barra de rolagem da tela
  final ScrollController _scrollController = ScrollController();
  // Identifica quem é o usuário logado no aplicativo
  final user = FirebaseAuth.instance.currentUser;

  // Limpa essas ferramentas da memória do celular quando o usuário sai da tela
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Função ativada quando o botão de enviar é pressionado
  void _sendMessage() async {
    // Se a caixa estiver vazia ou o usuário não estiver logado, não faz nada
    if (_messageController.text.trim().isEmpty || user == null) return;

    // Guarda o texto escrito e apaga da caixinha de digitação na hora
    final text = _messageController.text.trim();
    _messageController.clear(); 

    // Cria o caminho exato no banco de dados para guardar essa conversa específica
    final chatRef = FirebaseFirestore.instance
        .collection('Usuários')
        .doc(user!.uid)
        .collection('chats')
        .doc(widget.startupName)
        .collection('mensagens');

    // Manda a mensagem para a internet avisando que foi o usuário quem enviou, junto com a hora exata
    await chatRef.add({
      'text': text,
      'is_from_startup': false,
      'timestamp': FieldValue.serverTimestamp(),
    });


    _scrollToBottom();
  }


  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Barra superior com o nome da empresa e botão de voltar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.startupName.isNotEmpty ? widget.startupName[0].toUpperCase() : 'S',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.startupName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
      // Corpo principal da tela empilhando o fundo colorido com as mensagens
      body: Stack(
        children: [
          // Bolinhas coloridas decorativas no fundo da tela
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE91E63).withValues(alpha:0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9C27B0).withValues(alpha:0.05),
              ),
            ),
          ),
          
          Column(
            children: [
              // Área onde a lista de mensagens aparece
              Expanded(
                child: user == null
                    ? const Center(child: Text("Usuário não autenticado"))
                    // Espera as novas mensagens
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Usuários')
                            .doc(user!.uid)
                            .collection('chats')
                            .doc(widget.startupName)
                            .collection('mensagens')
                            .orderBy('timestamp', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          // Loading
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          // Se a conversa estiver vazia, convida o usuário a mandar a primeira mensagem
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                'Nenhuma mensagem ainda.\nEnvie a primeira mensagem!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black38,
                                ),
                              ),
                            );
                          }

                          // Pega a lista de mensagens que chegou do banco de dados
                          final docs = snapshot.data!.docs;

                          // Dá um pequeno empurrãozinho na tela para baixo sempre que a lista for desenhada
                          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                          // Constrói visualmente a lista rolável com todos os balões de conversa
                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              final message = ChatMessage.fromFirestore(data);
                              return MessageBubble(message: message);
                            },
                          );
                        },
                      ),
              ),
              // Rodapé branco onde fica a caixa para digitar o texto e o botão de enviar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Digite sua mensagem...',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// O molde visual que desenha cada balãozinho de conversa na tela
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        // Joga o balão para a esquerda se for da empresa, e para a direita se for do usuário
        mainAxisAlignment:
            message.isFromStartup ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          // Configuração do balão cinza 
          if (message.isFromStartup) ...[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4), 
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ] else ...[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4), 
                ),
              ),
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

//  organiza as informações cruas que chegam do banco
class ChatMessage {
  final String text;
  final bool isFromStartup;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromStartup,
    required this.timestamp,
  });

  // Traduz os dados do Firebase para o formato que o aplicativo entende
  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      text: data['text'] ?? '',
      isFromStartup: data['is_from_startup'] ?? false,
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}