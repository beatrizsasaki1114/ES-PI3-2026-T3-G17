import {getUser} from "../repositories/userRepository";
import {onCall, HttpsError} from "firebase-functions/v2/https";

export const signInUser = onCall({ region: "southamerica-east1" }, async (request) => {
  const { email, password } = request.data; 

  try {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }
    // validar se os campos estão preenchidos
    if (!email || !password) {
      throw new HttpsError("invalid-argument", "E-mail e senha são obrigatórios.");
    }

    // busca no db o usuário pelo email 
    const user = await getUser(email);

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
