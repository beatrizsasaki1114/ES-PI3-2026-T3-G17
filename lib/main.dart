import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_page.dart'; // arquivo da tela de login

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // await Firebase.initializeApp(
//   // options: DefaultFirebaseOptions.currentPlatform,
//   // );
//   runApp(const MyApp());
// }


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase inicializado com sucesso");
  } catch (e) {
    print("ERRO NO FIREBASE: $e");
  }

  runApp(MyApp());
}
//TESTAR EM ANDROID EMULADOR NAO EM WEB!

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Página de Login',
      theme: ThemeData(
        //colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
    );
  }
}
