// Beatriz Naomi
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  // instancia do firebaseAuth
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  
  // Retorna o usuário atualmente logado — null se não há usuário autenticado
  User? get currentUser => firebaseAuth.currentUser;
  // Stream que emite eventos quando o estado de autenticação muda
  // Ex: usuário faz login, logout ou o token expira
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  // Cria uma nova conta com email e senha e salva dados extras junto
  Future<User?> createAccount({
    required String nome,
    required String sobrenome,
    required String email,
    required String telefone,
    required String cpf,
    required String password,
  }) async {
    try {
       // Retorna um UserCredential com os dados do usuário criado
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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'A senha escolhida é muito fraca. Tente uma mais longa';
      } else if (e.code == 'email-already-in-use') {
        throw 'Este e-mail já está em uso';
      } else {
        throw 'Ocorreu um erro ao criar a conta. Tente novamente';
      }
    }
  }

  // Faz login com email e senha
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Retorna o usuário logado
    return credential.user;
  }

  
  // Envia email de redefinição de senha para o endereço informado
  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Ativando autenticação de 2 fatores
  Future<void> setupTwoFactor({
    required Function(String vId) onSmsSent,
    required Function(String error) onError,
  }) async {
    try {
      // verificado se o usuário esta autenticado
      if (currentUser == null) throw 'Usuário não autenticado';
      // Pega a sessão multifator do usuário atual 
      // necessária para vincular o telefone
      final session = await currentUser!.multiFactor.getSession();
      //  Chama a Cloud Function signInUser para buscar o telefone do usuário no Firestore
      final result = await FirebaseFunctions.instanceFor(
        region: 'southamerica-east1',
      ).httpsCallable('signInUser').call({'email': currentUser!.email});

       // Verifica se o telefone foi retornado pela Cloud Function
      if (result.data != null && result.data['telefone'] != null) {
        String telefone = result.data['telefone'].trim();

         // Garante que o número está no formato internacional (+55)
        if (!telefone.startsWith('+')) {
          telefone = '+55$telefone';
        }

         // Dispara o envio do SMS de verificação
        await firebaseAuth.verifyPhoneNumber(
          multiFactorSession: session,// Sessão multifator do usuário
          phoneNumber: telefone, // Número que vai receber o SMS
          verificationCompleted: (_) {},
          // acionado se algo der errado antes mesmo do SMS ser processado
          verificationFailed: (e) =>
              onError(e.message ?? 'Falha na verificação'),
          // acionado um aviso assim que o google envia o sms para o dispositivo
          codeSent: (vId, _) => onSmsSent(vId),
          // Chamado quando o tempo limite de verificação automática expira
          codeAutoRetrievalTimeout: (_) {},
        );
      }
    } catch (e) {
      onError(e.toString());
    }
  }

  // Envia SMS de login para o número já cadastrado no 2FA
  // Quando o usuário tenta fazer login com email/senha e tem 2FA ativo,
  // o Firebase não deixa entrar direto — ele lança FirebaseAuthMultiFactorException.
  // Dentro da exceção vem o MultiFactorResolver com:
  //  resolver.session → prova que a senha estava correta (vincula o SMS ao login)
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

  // Valida o código SMS digitado pelo usuário e completa o 2FA
  Future<void> validateCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Cria a credencial de autenticação por telefone com o código recebido
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      // Converte a credencial em asserção multifator
      final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
       // Recarrega o usuário para garantir estado atualizado
      await firebaseAuth.currentUser?.reload();
      // Registra o fator de autenticação no perfil do usuário
      await currentUser!.multiFactor.enroll(assertion);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Remove o 2FA do usuário — desativa a autenticação de dois fatores
  Future<void> unenrollMFA() async {
    try {
      if (currentUser != null) {
        // Acessa o objeto multifator do usuário atual
        final mfaUser = currentUser!.multiFactor;
         // Busca todos os fatores de autenticação ativos
        final enrolledFactors = await mfaUser.getEnrolledFactors();
        if (enrolledFactors.isNotEmpty) {
          // remove o primeiro fator encontrado (telefone cadastrado)
          await mfaUser.unenroll(factorUid: enrolledFactors.first.uid);
        }
      }
    } catch (e) {
      throw Exception("Erro ao desativar 2FA: $e");
    }
  }

  
  // Envia email de verificação para o usuário atual
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}