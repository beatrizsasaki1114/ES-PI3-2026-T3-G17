// Feito por Sofia de Sousa 

// Importar esse pacote permite que a gente chame as funções no back, enviar os dados e receber respostas
import 'package:cloud_functions/cloud_functions.dart';


// Criando uma classe responsável para comunicação da carteira com o back
// Centralizando as funções que eu(sofia) fiz no exchange 
class WalletService {

  //  Criando a conexão com a Firebase Functions 
  // FirebaseFunctions.instance - acesso principal para Cloud Functions 

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Função async para chamar o back e pegar os dados da carteira 
  Future<Map<String, dynamic>> getUserWallet() async {

    //Espera a resposta do back 
    final response = await _functions.httpsCallable('getUserWallet').call();

    //Converte a resposta do firebase para o map do dart 
    return Map<String, dynamic>.from(response.data);
  }
  
  // Criando a função para retirar o saldo
  Future<void> withdrawFunds(double valor) async {

    //.call - envia os dados para o backend e no back vai virar request.data.valor
    await _functions.httpsCallable('withdrawFunds').call({'valor': valor});
  }

  // Criando a função para comprar tokens 
  Future<void> buyTokens({

    // Dados que a função precisa para comprar os tokens, o id da startup e a quantidade de tokens que quer comprar
    required String startupId,
    required int quantity,
  }) async {

    // Espera o Firebase responder que a compra foi realizada, 
      // e depois envia os dado para o backend
      
    await _functions.httpsCallable('buyTokens').call({
      'startupId': startupId,
      'quantity': quantity,
    });
  }
}
