import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<User?> createAccount({
    required String nome,
    required String email,
    required String telefone,
    required String cpf,
    required String password,
  }) async {
    UserCredential result = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await FirebaseFunctions.instanceFor(
      region: 'southamerica-east1',
    ).httpsCallable('createUser').call({
      'uid': result.user!.uid,
      'nome': nome,
      'email': email,
      'cpf': cpf,
      'telefone': telefone,
    });

    return result.user;
  }
}
