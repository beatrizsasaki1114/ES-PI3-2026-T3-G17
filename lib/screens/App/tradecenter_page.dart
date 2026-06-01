//Bruno Machado e Luca Filippi
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart';
import 'package:projeto_integrador_3_grupo_17/screens/User/user_profile_page.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  void _showCreateOfferSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateOfferSheet(),
    );
  }

  // Deleta o registro da oferta atrelada ao usuário criador
  Future<void> _deleteOffer(String ofertaId) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Excluir Oferta", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text("Tem certeza que deseja remover este anúncio do balcão?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Excluir", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await FirebaseFirestore.instance.collection('Ofertas').doc(ofertaId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Anúncio removido com sucesso!"), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao remover: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Lógica de transferência de tokens 
  Future<void> _buyTokens(Map<String, dynamic> oferta, String ofertaId) async {
    final buyerUid = currentUser?.uid;
    if (buyerUid == null) return;

    final sellerUid = oferta['vendedorId'];
    final valorTotal = (oferta['valorTotal'] as num).toDouble();
    final quantidadeTokens = oferta['quantidadeTokens'] as int;
    final startupId = oferta['startupId'];
    final startupNome = oferta['startupNome'];

    // Etapa 1: Confirmação na UI
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar Compra", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Deseja comprar $quantidadeTokens tokens da $startupNome por R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63)),
            onPressed: () => Navigator.pop(context, true),
            child: Text("Confirmar", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Loading enquanto processa a transação
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final buyerRef = FirebaseFirestore.instance.collection('Usuários').doc(buyerUid);
      final sellerRef = FirebaseFirestore.instance.collection('Usuários').doc(sellerUid);
      final offerRef = FirebaseFirestore.instance.collection('Ofertas').doc(ofertaId);

      // Etapa 2: Executa a transação englobando comprador, vendedor e o registro da oferta
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final offerSnap = await transaction.get(offerRef);
        final buyerSnap = await transaction.get(buyerRef);
        final sellerSnap = await transaction.get(sellerRef);

        // Previne dupla compra
        if (!offerSnap.exists || offerSnap.data()?['status'] != 'ativa') {
          throw Exception("Esta oferta já foi vendida ou cancelada.");
        }

        final buyerData = buyerSnap.data() ?? {};
        final sellerData = sellerSnap.data() ?? {};

        final double buyerSaldo = (buyerData['saldo'] ?? 0).toDouble();
        if (buyerSaldo < valorTotal) {
          throw Exception("Saldo insuficiente na carteira para esta compra.");
        }

        // --- MANIPULAÇÃO DA CARTEIRA DO COMPRADOR ---
        List<dynamic> buyerInvestments = List.from(buyerData['investimentos'] ?? []);
        
        buyerInvestments.add({
          'startupId': startupId,
          'startupName': startupNome,
          'tokenQuantity': quantidadeTokens,
          'amountSpent': valorTotal,
          'date': Timestamp.now(), 
        });

        // --- MANIPULAÇÃO DA CARTEIRA DO VENDEDOR ---
        List<dynamic> sellerInvestments = List.from(sellerData['investimentos'] ?? []);
        final dynamic offerInvDate = oferta['investmentDate'];

        int sellerIdx = -1;
        // Tenta encontrar o lote exato de investimento que está sendo vendido
        if (offerInvDate != null) {
          sellerIdx = sellerInvestments.indexWhere((inv) {
            final invDate = inv['date'] ?? inv['data'];
            return inv['startupId'] == startupId && invDate == offerInvDate;
          });
        }
        
        // se não achar por data, acha qualquer investimento dessa startup que tenha saldo suficiente
        if (sellerIdx == -1) {
          sellerIdx = sellerInvestments.indexWhere((inv) => 
              inv['startupId'] == startupId && (inv['tokenQuantity'] ?? 0) >= quantidadeTokens);
        }

        if (sellerIdx == -1) {
          throw Exception("Os tokens não foram encontrados na carteira do vendedor.");
        }

        Map<String, dynamic> updatedSellerInv = Map<String, dynamic>.from(sellerInvestments[sellerIdx]);
        int oldSellerQtd = updatedSellerInv['tokenQuantity'] ?? 0;

        if (oldSellerQtd < quantidadeTokens) {
          throw Exception("O vendedor não possui tokens suficientes neste lote.");
        }

        // Recalcula as cotas para o vendedor
        int newSellerQtd = oldSellerQtd - quantidadeTokens;
        double oldSellerAmount = (updatedSellerInv['amountSpent'] ?? 0).toDouble();
        double newSellerAmount = oldSellerQtd > 0 ? oldSellerAmount * (newSellerQtd / oldSellerQtd) : 0;

        // Se ele vender TUDO do lote, o investimento é removido do array dele
        if (newSellerQtd == 0) {
          sellerInvestments.removeAt(sellerIdx); 
        } else {
          updatedSellerInv['tokenQuantity'] = newSellerQtd;
          updatedSellerInv['amountSpent'] = newSellerAmount;
          sellerInvestments[sellerIdx] = updatedSellerInv;
        }

        // --- ATUALIZAÇÕES FINAIS ---
        transaction.update(buyerRef, {
          'saldo': buyerSaldo - valorTotal,
          'investimentos': buyerInvestments,
        });

        final double sellerSaldo = (sellerData['saldo'] ?? 0).toDouble();
        transaction.update(sellerRef, {
          'saldo': sellerSaldo + valorTotal,
          'investimentos': sellerInvestments,
        });

        transaction.update(offerRef, {
          'status': 'vendida',
          'compradorId': buyerUid,
          'dataVenda': Timestamp.now(),
        });
      });

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compra realizada com sucesso! Os tokens já estão na sua carteira."), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro na transação: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 1,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 77, 51, 142).withValues(alpha:0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Balcão de Tokens",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 77, 51, 142),
                  ),
                ),
              ),
              Expanded(
                // StreamBuilder mantém o balcão atualizado em tempo real para todos os usuários logados.
                // Filtra por status 'ativa' para não mostrar negócios já fechados
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Ofertas')
                      .where('status', isEqualTo: 'ativa')
                      .orderBy('dataCriacao', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Erro ao carregar ofertas: ${snapshot.error}",
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "Nenhuma oferta disponível no momento.",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      );
                    }

                    final ofertas = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: ofertas.length,
                      itemBuilder: (context, index) {
                        final oferta = ofertas[index].data() as Map<String, dynamic>;
                        final ofertaId = ofertas[index].id;
                        
                        // Verifica se a oferta que está sendo gerada na lista pertence a quem está logado
                        final isMyOffer = oferta['vendedorId'] == currentUser?.uid;

                        return _buildOfferCard(oferta, ofertaId, isMyOffer);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Color.fromARGB(255, 77, 51, 142), size: 30),
          tooltip: "Anunciar Tokens",
          onPressed: () => _showCreateOfferSheet(context),
        ),
      ],
    );
  }

  // Constrói o card da oferta. Se a oferta for do usuário, o botão é de excluir.
  // Caso contrário, é o botão de comprar.
  Widget _buildOfferCard(Map<String, dynamic> oferta, String ofertaId, bool isMyOffer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 240, 235, 255),
                child: Text(
                  oferta['startupNome'].toString().substring(0, 1).toUpperCase(),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 77, 51, 142)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      oferta['startupNome'],
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navegação para ver o perfil do anunciante
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfilePage(userId: oferta['vendedorId']),
                          ),
                        );
                      },
                      child: Text(
                        "Por: ${isMyOffer ? 'Você' : oferta['vendedorNome']}",
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.blueAccent, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Quantidade", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  Text("${oferta['quantidadeTokens']} tokens", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Preço Total", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  Text(
                    "R\$ ${oferta['valorTotal'].toStringAsFixed(2).replaceAll('.', ',')}",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                  ),
                  Text(
                    "(R\$ ${oferta['precoUnitario'].toStringAsFixed(2).replaceAll('.', ',')}/un)",
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isMyOffer ? Colors.red.shade400 : const Color(0xFFE91E63),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isMyOffer 
                  ? () => _deleteOffer(ofertaId)
                  : () => _buyTokens(oferta, ofertaId),
              child: Text(
                isMyOffer ? "Excluir Oferta" : "Comprar Tokens",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// O componente interno que abre dentro do BottomSheet para criação de oferta
class CreateOfferSheet extends StatefulWidget {
  const CreateOfferSheet({super.key});

  @override
  State<CreateOfferSheet> createState() => _CreateOfferSheetState();
}

class _CreateOfferSheetState extends State<CreateOfferSheet> {
  List<dynamic> myInvestments = [];
  Map<String, dynamic>? selectedInvestment;
  
  final TextEditingController _qtdController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  bool _isLoading = true;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    // Busca os dados da carteira do usuário ao abrir a tela
    _fetchMyInvestments();
  }

  Future<void> _fetchMyInvestments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('Usuários').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          // Preenche o Dropdown apenas com os investimentos do usuário
          myInvestments = doc.data()?['investimentos'] ?? [];
          _isLoading = false;
        });
      }
    }
  }

  // Cria e envia a oferta para a Collection 'Ofertas' no Firebase
  Future<void> _publishOffer() async {
    if (selectedInvestment == null || _qtdController.text.isEmpty || _precoController.text.isEmpty) return;

    final qtdDesejada = int.tryParse(_qtdController.text) ?? 0;
    // Permite que o usuário digite com vírgula
    final precoUnitario = double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0;
    final maxTokens = selectedInvestment!['tokenQuantity'];

    // Validações locais da regra de negócio
    if (qtdDesejada <= 0 || qtdDesejada > maxTokens) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quantidade inválida ou acima do que você possui.")));
      return;
    }

    setState(() => _isPublishing = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance.collection('Usuários').doc(user.uid).get();
      final userName = userDoc.data()?['nome'] ?? "Usuário";

      await FirebaseFirestore.instance.collection('Ofertas').add({
        'vendedorId': user.uid,
        'vendedorNome': userName,
        'startupId': selectedInvestment!['startupId'],
        'startupNome': selectedInvestment!['startupName'],
        'quantidadeTokens': qtdDesejada,
        'precoUnitario': precoUnitario,
        'valorTotal': qtdDesejada * precoUnitario,
        'dataCriacao': Timestamp.now(),
        'status': 'ativa', // O status diz se ela renderiza na StreamBuilder ou não
        'investmentDate': selectedInvestment!['date'] ?? selectedInvestment!['data'], 
      });

      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Oferta publicada com sucesso!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: _isLoading 
        ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Criar Nova Oferta", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              if (myInvestments.isEmpty)
                Text("Você ainda não possui tokens para vender.", style: GoogleFonts.poppins(color: Colors.grey))
              else ...[
                DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: const InputDecoration(labelText: "Qual startup deseja vender?", border: OutlineInputBorder()),
                  items: myInvestments.map((inv) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: inv as Map<String, dynamic>,
                      child: Text("${inv['startupName']} (${inv['tokenQuantity']} tokens disp.)"),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedInvestment = val),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qtdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Qtd. de Tokens", border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _precoController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: "Preço Unitário (R\$)", border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 77, 51, 142)),
                    onPressed: _isPublishing ? null : _publishOffer, 
                    child: _isPublishing 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Publicar Oferta", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
    );
  }
}