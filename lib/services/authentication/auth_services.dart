// Beatriz Naomi

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  // instancia do firebaseAuth
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  // pegando o usuário principal
  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
  
  Future<User?> createAccount({
    required String nome,
    required String sobrenome,
    required String email,
    required String telefone,
    required String cpf,
    required String password,
  }) async {
    UserCredential result = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FirebaseFunctions.instanceFor(region: 'southamerica-east1')
        // Nome da função na Cloud Function
        .httpsCallable('createUser')
        .call({
          'uid': result.user!.uid,
          'nome': nome,
          'sobrenome': sobrenome,
          'email': email,
          'cpf': cpf,
          'telefone': telefone,
        });

    return result.user;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
     await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resetPassword({required String email}) async {
     await firebaseAuth.sendPasswordResetEmail(
      email: email,
    );
  }
}
