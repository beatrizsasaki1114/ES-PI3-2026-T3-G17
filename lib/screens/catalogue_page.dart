import 'package:flutter/material.dart';
import 'package:projeto_integrador_3_grupo_17/screens/config_page.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,

        leading: IconButton(
            icon: Image.asset(
              'assets/images/menuIcon.png', 
              height: 40,
              width: 40,
            ),
            onPressed: () {
              
            },
          ),
        
        title: Image.asset(
          'assets/images/logoMesclaInvest.png',
          height: 80,
          fit: BoxFit.contain,
        ),

        actions: [
          IconButton(
            icon: Image.asset(
              'assets/images/userIcon.png', 
              height: 40,
              width: 40,
            ),
            onPressed: () {
              
            },
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
                builder: (context) => const  ConfigPage(),
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
              children: const [
                SizedBox(height: 40),
                Text(
                  "depois eu termino",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


  