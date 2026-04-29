import {setUser} from "../repositories/userRepository";
import {CallableRequest, onCall, HttpsError} from "firebase-functions/v2/https";
import type {Users} from "../types/index";

// Function para criação do usuário no firebase
export const createUser = onCall(
  {region: "southamerica-east1"},
  async (request: CallableRequest<Users>) => {

    try {
    // verifica se o usuário está autenticado
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }
    // verifica se o campo nome não está vazio e sua tipagem é string
    const data= request.data;
    if (!data.nome || typeof data.nome != "string") {
      throw new HttpsError("invalid-argument", "Campo nome obrigatório");
    }
    // verifica se o campo sobrenome está vazio e sua tipagem é string
    if (!data.sobrenome || typeof data.sobrenome != "string") {
      throw new HttpsError("invalid-argument", "Campo sobrenome obrigatório");
    }
    // verifica se o campo email está vazio e sua tipagem é string
    if (!data.email || typeof data.email != "string") {
      throw new HttpsError("invalid-argument", "Campo nome obrigatório");
    }
    // verifica se o campo cpf está vazio e sua tipagem é string
    if (!data.cpf || typeof data.cpf != "string") {
      throw new HttpsError("invalid-argument", "Campo nome obrigatório");
    }
    // verifica se o campo telefone está vazio e sua tipagem é string
    if (!data.telefone || typeof data.telefone != "string") {
      throw new HttpsError("invalid-argument", "Campo nome obrigatório");
    }

    return setUser({
      uid: request.auth.uid,
      nome: data.nome,
      sobrenome: data.sobrenome,
      email: data.email,
      cpf: data.cpf,
      telefone: data.telefone,
    });

  }catch(error){
    
   if (error instanceof HttpsError) {
      throw error;
    }
    // erros genéricos
      console.error("Erro no login:", error);
      throw new HttpsError("internal", "Erro interno ao processar o login.");
  }
});
