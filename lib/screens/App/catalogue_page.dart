//Bruno Machado, Beatriz Naomi
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projeto_integrador_3_grupo_17/models/startups.dart';
import 'package:projeto_integrador_3_grupo_17/services/startups/startups_services.dart';
import 'package:projeto_integrador_3_grupo_17/screens/App/startups_details_page.dart';
import 'package:projeto_integrador_3_grupo_17/widgets/main_layout.dart'; 

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  final int _selectedIndex = 2;
  final _minhaRequisicao = StartupService().fetchStartups();
  String _categoriaSelecionada = 'Todos';

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: _selectedIndex,
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.search, size: 30.0),
          onPressed: () {
            showSearch(
              context: context,
              delegate: MySearchDelegate(minhaRequisicao: _minhaRequisicao),
            );
          },
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catálogo de Startups',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 77, 51, 142),
              ),
            ),
            const SizedBox(height: 10),
            
            Expanded(
              child: FutureBuilder<List<Startup>>(
                future: _minhaRequisicao,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar dados: ${snapshot.error}'),
                    );
                  }

                  final startups = snapshot.data ?? [];
                  final categorias = [
                    'Todos',
                    ...startups.map((s) => s.stage).toSet() 
                  ];

                  final startupsExibidas = _categoriaSelecionada == 'Todos'
                      ? startups.toList()
                      : startups.where((s) => s.stage.toLowerCase() == _categoriaSelecionada.toLowerCase()).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categorias.length, 
                          itemBuilder: (context, index) {
                            final cat = categorias[index];
                            final isSelected = _categoriaSelecionada == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InfoChip(
                                label: cat,
                                color: isSelected ? const Color.fromARGB(255, 77, 51, 142) : Colors.grey[300]!,
                                onTap: () {
                                  setState(() {
                                    _categoriaSelecionada = cat;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  
                      const SizedBox(height: 20),
                      Expanded(
                        child: startupsExibidas.isEmpty 
                            ? const Center(child: Text('Nenhuma startup encontrada.'))
                            : ListView.separated(
                                itemCount: startupsExibidas.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 20),
                                itemBuilder: (context, index) {                  
                                  final s = startupsExibidas[index];
                                  return StartupCard(
                                    startup: s,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StartupDetailsPage(startup: s),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    startup.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      InfoChip(
                        label: startup.stage,
                        color: const Color.fromARGB(255, 73, 46, 143),
                      ),
                      InfoChip(
                        label: startup.tokenType,
                        color: const Color.fromARGB(255, 182, 38, 111),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

class InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const InfoChip({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        
        ),
      ),
      )
    );
  }
}


class MySearchDelegate extends SearchDelegate {
  final Future<List<Startup>> minhaRequisicao;
  MySearchDelegate({required this.minhaRequisicao});

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
  ];


  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );


  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Startup>>(
      future: minhaRequisicao,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final startups = snapshot.data!;

        final filtradas = startups
            .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: filtradas.length,
          itemBuilder: (context, index) {
            final s = filtradas[index];
            return ListTile(
              title: Text(s.name),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StartupDetailsPage(startup: s),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
