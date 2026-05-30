//Bruno Machado
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart';
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

  Future<void> _processInvestment() async {
    if (_amountController.text.isEmpty) return;

    if (widget.startup.id.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: ID da startup não encontrado.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isProcessing = false);
      return;
    }
    
    // Valida se o usuário está logado antes de processar valores financeiros
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final tokenQuantity = int.parse(_amountController.text);
    final estimatedValue = tokenQuantity * widget.startup.precoAtualToken;

    setState(() => _isProcessing = true);

    try {
      final userRef = FirebaseFirestore.instance.collection('Usuários').doc(user.uid);
      final startupRef = FirebaseFirestore.instance.collection('startups').doc(widget.startup.id);

      // Usar runTransaction é importante pois evita erros comuns como por exemplo multiplos compradores simultâneos, queda de rede e problemas com o dispositivo
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception("Usuário não encontrado.");
        }

        final startupSnapshot = await transaction.get(startupRef);
        if (!startupSnapshot.exists) {
          throw Exception("Startup não encontrada.");
        }

        // Validação 1: O usuário tem saldo suficiente?
        final double saldoAtual = (userSnapshot.data()?['saldo'] ?? 0).toDouble();
        if (saldoAtual < estimatedValue) {
          throw Exception("Saldo insuficiente para esta compra.");
        }
        
        // Validação 2: A startup ainda tem tokens disponíveis?
        final int tokensDisponiveis = (startupSnapshot.data()?['TotalTokensEmitidos'] ?? 0).toInt();
        if (tokensDisponiveis < tokenQuantity) {
          throw Exception("A startup não possui tokens suficientes para essa compra.");
        }

        final novoSaldo = saldoAtual - estimatedValue;
        
        // Estrutura do novo investimento a ser salva no array do usuário
        final novoInvestimento = {
          'startupId': widget.startup.id,
          'startupName': widget.startup.name,
          'tokenQuantity': tokenQuantity,
          'amountSpent': estimatedValue,
          'date': Timestamp.now(), 
        };

        // Escrita 1: Atualiza o saldo do usuário e adiciona o histórico de investimento
        transaction.update(userRef, {
          'saldo': novoSaldo,
          'investimentos': FieldValue.arrayUnion([novoInvestimento]), 
        });

        // Escrita 2: Deduz a quantidade de tokens disponíveis da startup
        transaction.update(startupRef, {
          'TotalTokensEmitidos': FieldValue.increment(-tokenQuantity), 
        });
      });

      // Checa se o widget ainda está montado antes de usar o BuildContext
      if (!mounted) return;
      _showSuccessMessage(context);
      _amountController.clear();
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
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
          // Backgrounds decorativos
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
                    Colors.pink.shade200.withAlpha(128),
                    Colors.purple.shade200.withAlpha(128),
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
                    Colors.purple.shade300.withAlpha(153),
                    Colors.purple.shade400.withAlpha(153),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  'Comprar AOTP',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Qtd de tokens',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
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
                    onChanged: (value) => setState(() {}), // Dispara rebuild para recalcular valor estimado sempre que for digitado um numero novo
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
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Abre o pop-up de confirmação antes de processar a compra de fato
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Calcula o custo em tempo real de acordo com a digitação do usuário
  String _calculateEstimatedValue() {
    if (_amountController.text.isEmpty) {
      return '0,00';
    }
    try {
      final amount = int.parse(_amountController.text);
      final estimatedValue = amount * widget.startup.precoAtualToken;
      return estimatedValue.toStringAsFixed(2).replaceAll('.', ',');
    } catch (e) {
      return '0,00';
    }
  }

  void _showInvestmentConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: _isProcessing 
                  ? null 
                  : () {
                      Navigator.pop(dialogContext); // Fecha o dialog
                      _processInvestment(); // Dispara o backend
                    },
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