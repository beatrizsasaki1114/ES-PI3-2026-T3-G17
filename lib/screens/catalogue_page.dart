import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/config_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

// Parte do model correta com o banco 
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

  factory Startup.fromJson(Map<String, dynamic> json) {
    return Startup(
      id: json['ID'] ?? '',
      name: json['NomeStartup'] ?? '',
      description: json['DescricaoCurta'] ?? '',
      stage: _mapStage(json['Estagio']),
      tokenType: _mapTokenType(json['tags']),
    );
  }

  static String _mapStage(String? stage) {
    switch (stage?.toLowerCase()) {
      case 'nova':
        return 'Nova';
      case 'operacao':
        return 'Operação';
      case 'expansao':
        return 'Expansão';
      default:
        return 'Desconhecido';
    }
  }

  // Até aqui é o model Startups.dart

  static String _mapTokenType(List<dynamic>? tags) {
    if (tags == null || tags.isEmpty) return 'N/A';
    return tags.first.toString().toUpperCase();
  }
}

class _CataloguePageState extends State<CataloguePage> {
  // Essa função é a que busca as startups do backend usando Cloud Functions

   //Chama a função do backend 'listStartupItems' e transforma o resultado em uma lista de objetos Startup
  Future<List<Startup>> fetchStartups() async {

     // A chamada da função do back qu é a listStartupItems 
    final callable = FirebaseFunctions.instance.httpsCallable(
      'listStartups',
    );

    // flutter vai enviar a requisição, o firebase vai executar a function
     // Backend vai retornas os dados e o flutter vai receber as respostas 
      // O await faz com que espere o back responder
    final result = await callable.call();

    // Acesso do json retornado pelo back (lista de dados)
    final List data = result.data['data'];
   
   // Transforma a lista de json em uma lista de objetos Startup usando o fromJson do model
    return data.map((item) => Startup.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

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
                MaterialPageRoute(builder: (context) => const ConfigPage()),
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
                      color: Color.fromARGB(255, 77, 51, 142),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

            
              Expanded(

                // Espera os dados do backend chegar e faz aquilo que o flutter vaz de construir a tela
                child: FutureBuilder<List<Startup>>(

                  //Vai construir o UI baseando no resultado que a função retornar
                  // Fetch - função que chama o firebase e pega os dados
                  future: fetchStartups(),
                  builder: (context, snapshot) {

                    // Enquanto os dados não chegam, loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // Se deu erro na chamada
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Erro ao carregar startups'),
                      );
                    }

                    final startups = snapshot.data ?? [];
                    
                    // Se não veio nada
                    if (startups.isEmpty) {
                      return const Center(
                        child: Text('Nenhuma startup disponível.'),
                      );
                    }
                    
                    // Se tudo der certo (Deus queira que sim) os dados chegam aqui
                    return ListView.separated(
                      itemCount: startups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 20),
                      itemBuilder: (context, index) {
                        final s = startups[index];

                        // Vai retornar os dados pro card
                        return StartupCard(
                          startup: s,
                          onTap: () {
                            // futura navegação
                          },
                        );
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
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
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
                        color: Color.fromARGB(255, 0, 0, 0),
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
                        color: const Color.fromARGB(
                          255,
                          0,
                          0,
                          0,
                        ).withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoChip(
                        label: startup.stage,
                        color: const Color.fromARGB(255, 73, 46, 143),
                        textColor: const Color.fromARGB(221, 255, 255, 255),
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        label: startup.tokenType,
                        color: const Color.fromARGB(255, 182, 38, 111),
                        textColor: const Color.fromARGB(221, 255, 255, 255),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Color.fromARGB(200, 182, 38, 111),
            ),
          ],
        ),
      ),
    );
  }
}

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
