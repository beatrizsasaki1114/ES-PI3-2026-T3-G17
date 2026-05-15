import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocietyStructurePage extends StatelessWidget {
  const SocietyStructurePage({super.key});

  // Método que futuramente buscará dados do banco
  Future<List<Founder>> _fetchFounders() async {
    // TODO: Implementar busca do banco de dados
    // Por enquanto retorna dados mockados
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      Founder(
        name: 'Lucas Henrique de Oliveira',
        role: 'Fundador da Agrotech',
        description:
        'Com formação em Engenharia de Computação e vivência na agronegócio, Lucas lidera a visão estratégica da empresa.\n\nÉ responsável por identificar oportunidades de mercado e direcionar o crescimento da startup. Sua experiência no campo e na tecnologia foi fundamental para a criação da solução.',
        imageUrl: null, // Quando vier do banco, será uma URL real
      ),
      Founder(
        name: 'Rafael Martins Carvalho',
        role: 'Co-fundador da Agrotech',
        description:
        'Especialista em inteligência artificial e desenvolvimento de sistemas, Rafael lidera a área tecnológica da Agrotech.\n\nSua expertise em machine learning e IoT e na integração de IoT, garantindo que as soluções sejam eficientes e escaláveis.',
        imageUrl: null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91E63),
              Color(0xFF9C27B0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar customizada
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Estrutura Societária',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Conteúdo com os fundadores
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: FutureBuilder<List<Founder>>(
                    future: _fetchFounders(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF9C27B0),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro ao carregar dados',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhum fundador encontrado',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }

                      final founders = snapshot.data!;

                      return ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: founders.length,
                        itemBuilder: (context, index) {
                          return FounderCard(founder: founders[index]);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FounderCard extends StatelessWidget {
  final Founder founder;

  const FounderCard({super.key, required this.founder});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        children: [
          // Cargo/Título
          Text(
            founder.role,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Foto do fundador (placeholder ou imagem real)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: founder.imageUrl != null
                ? ClipOval(
              child: Image.network(
                founder.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderAvatar();
                },
              ),
            )
                : _buildPlaceholderAvatar(),
          ),
          const SizedBox(height: 16),

          // Nome do fundador
          Text(
            founder.name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Descrição
          Text(
            founder.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return const Icon(
      Icons.person,
      size: 60,
      color: Colors.black38,
    );
  }
}

// Model para Fundador - futuramente virá do banco de dados
class Founder {
  final String name;
  final String role;
  final String description;
  final String? imageUrl; // URL da foto quando vier do banco

  Founder({
    required this.name,
    required this.role,
    required this.description,
    this.imageUrl,
  });

  // Factory para criar a partir de JSON do banco de dados
  factory Founder.fromJson(Map<String, dynamic> json) {
    return Founder(
      name: json['name'] as String,
      role: json['role'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  // Converter para JSON para enviar ao banco
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'description': description,
      'image_url': imageUrl,
    };
  }
}