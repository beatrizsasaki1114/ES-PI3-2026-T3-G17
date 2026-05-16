import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/private_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InvestPage extends StatefulWidget {
  final Startup startup;

  const InvestPage({super.key, required this.startup});

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final TextEditingController _amountController = TextEditingController();

  bool _isProcessing = false;

  Future<void> _processInvestment(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_amountController.text.isEmpty) return;

    final tokenQuantity = int.parse(_amountController.text);
    // Usando o mesmo valor de R$ 10 por token que você definiu no _calculateEstimatedValue
    final estimatedValue = tokenQuantity * 10.0; 

    setState(() => _isProcessing = true);

    try {
      final userRef = FirebaseFirestore.instance.collection('Usuários').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        
        if (!snapshot.exists) {
          throw Exception("Usuário não encontrado.");
        }

        final double saldoAtual = (snapshot.data()?['saldo'] ?? 0).toDouble();

        if (saldoAtual < estimatedValue) {
          throw Exception("Saldo insuficiente para esta compra.");
        }

        // Calcula o novo saldo
        final novoSaldo = saldoAtual - estimatedValue;

        // Cria o objeto do investimento
        final novoInvestimento = {
          'startupId': widget.startup.id, // Supondo que a model Startup tenha um 'id'
          'startupName': widget.startup.name,
          'tokenQuantity': tokenQuantity,
          'amountSpent': estimatedValue,
          'date': Timestamp.now(), // Salva a data atual
        };

        // Atualiza o saldo e insere no array de investimentos
        transaction.update(userRef, {
          'saldo': novoSaldo,
          'investimentos': FieldValue.arrayUnion([novoInvestimento]),
        });
      });

      if (mounted) {
        Navigator.pop(context); // Fecha o modal de confirmação
        _showSuccessMessage(context);
        _amountController.clear();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fecha o modal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 77, 51, 142)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tela de informações ...',
          style: GoogleFonts.poppins(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Decoração de fundo
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.pink.shade200.withValues(alpha:0.5),
                    Colors.purple.shade200.withValues(alpha:0.5),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: 20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade300.withValues(alpha:0.6),
                    Colors.purple.shade400.withValues(alpha:0.6),
                  ],
                ),
              ),
            ),
          ),
          // Conteúdo principal
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo da startup
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        widget.startup.name[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 77, 51, 142),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Nome da startup
                Center(
                  child: Text(
                    widget.startup.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Comprar AOTP
                Text(
                  'Comprar AOTP',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                // Qtd de tokens
                Text(
                  'Qtd de tokens',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                // Campo de input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: '150',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Valor estimado
                Text(
                  'Valor estimado',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'R\$ ${_calculateEstimatedValue()}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Botões Investir e Chat Privado
                Row(
                  children: [
                    // Botão Investir
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            _showInvestmentConfirmation(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Investir',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botão Chat Privado
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrivateChatPage(
                                  startup: widget.startup,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFE91E63),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: const Color(0xFFE91E63),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateEstimatedValue() {
    if (_amountController.text.isEmpty) {
      return '0,00';
    }
    try {
      final amount = int.parse(_amountController.text);
      // Valor estimado por token (exemplo: R$ 10 por token)
      final estimatedValue = amount * 10;
      return estimatedValue.toStringAsFixed(2).replaceAll('.', ',');
    } catch (e) {
      return '0,00';
    }
  }

  void _showInvestmentConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Confirmar Investimento',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 77, 51, 142),
            ),
          ),
          content: Text(
            'Deseja investir ${_amountController.text} tokens em ${widget.startup.name}?',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: _isProcessing 
                  ? null 
                  : () => _processInvestment(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 77, 51, 142),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Confirmar',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Investimento realizado com sucesso!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}