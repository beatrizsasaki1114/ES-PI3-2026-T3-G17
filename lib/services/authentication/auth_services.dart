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
    try {
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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw ' A senha escolhida é muito fraca. Tente uma mais longa';
      } else if (e.code == 'email-already-in-use') {
        throw 'Este e-mail já está em uso';
      } else {
        throw 'Ocorreu um erro ao criar a conta. Tente novamente';
      }
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Ativando autenticação de 2 fatores
  Future<void> setupTwoFactor({
    required Function(String vId) onSmsSent,
    required Function(String error) onError,
  }) async {
    try {
      // verificando se o usuário esta autenticado
      if (currentUser == null) throw 'Usuário não autenticado';

      final session = await currentUser!.multiFactor.getSession();
      final result = await FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('signInUser').call({'email': currentUser!.email});

      if (result.data != null && result.data['telefone'] != null) {
        String telefone = result.data['telefone'].trim();

        if (!telefone.startsWith('+')) {
          telefone = '+55$telefone';
        }

        await firebaseAuth.verifyPhoneNumber(
          multiFactorSession: session,
          phoneNumber: telefone,
          verificationCompleted: (_) {},
          // acionado se algo der errado antes mesmo do SMS ser processado
          verificationFailed: (e) =>
              onError(e.message ?? 'Falha na verificação'),
          // acionado um aviso assim que o google envia o sms para o dispositivo
          codeSent: (vId, _) => onSmsSent(vId),

          codeAutoRetrievalTimeout: (_) {},
        );
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> sendLoginSms({
    required MultiFactorResolver resolver,
    required Function(String vId) onSmsSent,
    required Function(String error) onError,
  }) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        // Aqui usamos a sessão que o erro de login nos deu
        multiFactorSession: resolver.session,
        // Aqui pegamos o telefone que já está salvo no Firebase
        multiFactorInfo: resolver.hints.first as PhoneMultiFactorInfo, 
        verificationCompleted: (_) {},
        verificationFailed: (e) => onError(e.message ?? 'Falha na verificação'),
        codeSent: (vId, _) => onSmsSent(vId),
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      onError(e.toString());
    }
}
  Future<void> validateCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try{
      final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
    await firebaseAuth.currentUser?.reload();
    await currentUser!.multiFactor.enroll(assertion);
    } on FirebaseAuthException catch (e) {
        rethrow;
    }

  }

  Future<void> unenrollMFA() async {
    try {
      if (currentUser != null) {
        final mfaUser = currentUser!.multiFactor;
        // pega a lista de todos os fatores de autenticação ativos
        final enrolledFactors = await mfaUser.getEnrolledFactors();
        if (enrolledFactors.isNotEmpty) {
          // remove o primeiro fator encontrado
          await mfaUser.unenroll(factorUid: enrolledFactors.first.uid);
        }
      }
    } catch (e) {
      throw Exception("Erro ao desativar 2FA: $e");
    }
  }

  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
