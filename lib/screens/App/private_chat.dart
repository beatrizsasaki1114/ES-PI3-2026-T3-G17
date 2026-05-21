// Luca Filippi
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PrivateChatPage extends StatefulWidget {
  final Startup startup;

  const PrivateChatPage({super.key, required this.startup});

  @override
  State<PrivateChatPage> createState() => _PrivateChatPageState();
}

class _PrivateChatPageState extends State<PrivateChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final callable = _functions.httpsCallable('getMessages');
      final result = await callable.call({
        'userId': user.uid,
        'startupId': widget.startup.id,
        'limit': 50,
      });

      if (result.data['success']) {
        final messages = result.data['messages'] as List;
        setState(() {
          _messages.clear();
          for (var msg in messages) {
            _messages.add(ChatMessage(
              text: msg['text'] as String,
              isFromStartup: msg['isFromStartup'] as bool,
              timestamp: DateTime.fromMillisecondsSinceEpoch(msg['timestamp'] as int),
            ));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Adicionar mensagem do usuário localmente
    setState(() {
      _messages.add(ChatMessage(
        text: messageText,
        isFromStartup: false,
        timestamp: DateTime.now(),
      ));
      _isSending = true;
    });

    _messageController.clear();

    try {
      // Chamar a função do backend para enviar a mensagem
      final callable = _functions.httpsCallable('sendMessage');
      final result = await callable.call({
        'userId': user.uid,
        'startupId': widget.startup.id,
        'text': messageText,
        'isFromStartup': false,
      });

      if (result.data['success']) {
        // Simular resposta da empresa após 2 segundos
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          final callableReply = _functions.httpsCallable('sendMessage');
          await callableReply.call({
            'userId': user.uid,
            'startupId': widget.startup.id,
            'text': 'Obrigado pela sua mensagem! Em breve retornaremos.',
            'isFromStartup': true,
          });

          // Recarregar mensagens
          await _loadMessages();
        }
      }
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      // Remover mensagem em caso de erro
      if (mounted) {
        setState(() {
          if (_messages.isNotEmpty && !_messages.last.isFromStartup) {
            _messages.removeLast();
          }
          _isSending = false;
        });
      }
    }

    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  widget.startup.name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.startup.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE91E63).withValues(alpha:0.2),
                    const Color(0xFFE91E63).withValues(alpha:0.1),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9C27B0).withValues(alpha:0.25),
                    const Color(0xFF9C27B0).withValues(alpha:0.15),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                        ? Center(
                            child: Text(
                              'Nenhuma mensagem ainda',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return MessageBubble(message: _messages[index]);
                            },
                          ),
              ),
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
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: _isSending
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _isSending ? null : _sendMessage,
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

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isFromStartup
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (message.isFromStartup) ...[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withValues(alpha:0.15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
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

class ChatMessage {
  final String text;
  final bool isFromStartup;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromStartup,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isFromStartup: json['is_from_startup'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_from_startup': isFromStartup,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}