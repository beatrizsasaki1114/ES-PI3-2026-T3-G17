import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/config_page.dart';
import 'package:google_fonts/google_fonts.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

/// Modelo simples para representar uma startup
class Startup {
  final String id;
  final String name;
  final String description;
  final String stage;
  final String tokenType;

  Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.stage,
    required this.tokenType,
  });
}

class _CataloguePageState extends State<CataloguePage> {

  final List<Startup> startups = [
    Startup(
      id: 'ex1',
      name: 'EXEMPLO 1',
      description: 'Plataforma de aklasgyuidagbdf iuavauyfvfysfgbjka',
      stage: 'Operação',
      tokenType: 'FINTECH',
    ),
    Startup(
      id: 'ex2',
      name: 'EXEMPLO 2',
      description: 'Soluções de iajfghuiayfhkban8y  GB8UIYaga78GObyuibUYJK',
      stage: 'Validação',
      tokenType: 'LOGTECH',
    ),
    Startup(
      id: 'ex3',
      name: 'EXEMPLO 3',
      description: 'Integração de ajofjiasfniajsflasbnifukabfiyualbfkjhbj',
      stage: 'Tração',
      tokenType: 'EDTECH',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 51, 142),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 65,

        leading: IconButton(
          icon: Image.asset(
            'assets/images/menuIcon.png',
            height: 40,
            width: 40,
          ),
          onPressed: () {},
        ),

        title: InkWell(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const CataloguePage()),
              (route) => false,
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Transform.translate(
            offset: const Offset(0, -6), 
            child: Image.asset(
              'assets/images/logoMesclaInvest.png',
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/userIcon.png',
              height: 40,
              width: 40,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Image.asset(
              'assets/images/configIcon.png',
              height: 40,
              width: 40,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfigPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Catálogo de Startups',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
                const SizedBox(height: 20),
              Expanded(
                child: startups.isEmpty
                    ? const Center(child: Text('Nenhuma startup disponível.'))
                    : ListView.separated(
                        itemCount: startups.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final s = startups[index];
                          return StartupCard(
                            startup: s,
                            onTap: () {
                                //AQUI FICARA A NAVEGAÇÃO PARA A PÁGINA DA STARTUP
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StartupCard extends StatelessWidget {
  final Startup startup;
  final VoidCallback onTap;

  const StartupCard({super.key, required this.startup, required this.onTap});

  @override
Widget build(BuildContext context) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: const Color.fromARGB(255, 182, 38, 111),
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
    ],
    border: Border.all(color: Colors.white, width: 5), 
  ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                startup.name.isNotEmpty ? startup.name[0].toUpperCase() : '?',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  startup.name,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  startup.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha:0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(
                      label: startup.stage,
                      color: Colors.green.shade50,
                      textColor: Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      label: startup.tokenType,
                      color: Colors.orange.shade50,
                      textColor: Colors.black87,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    ),
  );
}

  }


/// Chip simples usado no card
class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _InfoChip({
    required this.label,
    required this.color,
    this.textColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

