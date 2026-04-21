import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/config_page.dart';
import 'package:projeto_integrador_3_grupo_17/screens/catalogue_page.dart';



class AppConfigPage extends StatefulWidget {
  const AppConfigPage({super.key});

  @override
  State<AppConfigPage> createState() => _AppConfigPageState();
}

class _AppConfigPageState extends State<AppConfigPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
            // Opção A: volta/abre a página de catálogo e remove a pilha anterior
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
  child: SingleChildScrollView(
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            "Informações do Aplicativo",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          
        ],
      ),
    ),
  ),
),
    );
  }
}

  

  

