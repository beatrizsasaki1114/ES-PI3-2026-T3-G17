//Feito por Heloisa

/**
import {CallableRequest, onCall} from "firebase-functions/v2/https";
import type {Users} from "../types/index";
 */

import {getUser} from "../repositories/userRepository";
import {onCall, HttpsError} from "firebase-functions/v2/https";

export const signInUser = onCall({ region: "southamerica-east1" }, async (request) => {
  const { email, password } = request.data; 
  // request.data: Aqui você está "abrindo a caixa" que veio do aplicativo para extrair o e-mail e a senha que o usuário digitou

  // O Handler atua como um filtro de segurança antes de qualquer contato com o banco de dados.
  try {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Usuário não autenticado");
      // HttpsError: É a forma padronizada do Firebase de avisar ao aplicativo que algo deu errado.
    }
    // validar se os campos estão preenchidos
    if (!email || !password) {
      throw new HttpsError("invalid-argument", "E-mail e senha são obrigatórios.");
    }

    // busca no db o usuário pelo email 
    const user = await getUser(email);
    // aqui o Handler faz o seu papel de coordenador. Ele não sabe como procurar no banco; 
    // ele apenas chama o "especialista" (o repositório getUser) e espera o resultado usando o await.
    
    
    /*
    Se o usuário não for encontrado no banco, o Handler decide enviar um erro de "não encontrado".
    Se tudo estiver certo, ele retorna apenas as informações necessárias para o aplicativo (uid e nome). 
    Isso protege os outros dados do usuário que estão no banco, como a senha.
    */
    if (!user) {
      // email não encontrado
      throw new HttpsError("not-found", "Usuário não encontrado.");
    }

    // retorno sucess
    return {
      uid: user.id,
      nome: user.nome,
      //token: "0"  
    };

  } catch (error) {
    if (error instanceof HttpsError) {
      throw error;
    }
    // erros genéricos
      console.error("Erro no login:", error);
      throw new HttpsError("internal", "Erro interno ao processar o login.");
  }
});
