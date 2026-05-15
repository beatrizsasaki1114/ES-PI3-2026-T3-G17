//Beatriz Naomi, Bruno Machado

import {setUser} from "../repositories/userRepository";
import {CallableRequest, onCall, HttpsError} from "firebase-functions/v2/https";
import type {Users} from "../types/index";

export const createUser = onCall(
  {region: "southamerica-east1"},
  async (request: CallableRequest<Users>) => {

    try {
      if (!request.auth) {
        throw new HttpsError("unauthenticated", "Usuário não autenticado");
      }

      const data = request.data;

      if (!data.nome || typeof data.nome !== "string") {
        throw new HttpsError("invalid-argument", "Campo nome obrigatório");
      }
      if (!data.sobrenome || typeof data.sobrenome !== "string") {
        throw new HttpsError("invalid-argument", "Campo sobrenome obrigatório");
      }
      if (!data.email || typeof data.email !== "string") {
        throw new HttpsError("invalid-argument", "Campo email obrigatório");
      }
      if (!data.cpf || typeof data.cpf !== "string") {
        throw new HttpsError("invalid-argument", "Campo cpf obrigatório");
      }
      if (!data.telefone || typeof data.telefone !== "string") {
        throw new HttpsError("invalid-argument", "Campo telefone obrigatório");
      }


      return setUser({
        uid: request.auth.uid,
        nome: data.nome,
        sobrenome: data.sobrenome,
        email: data.email,
        cpf: data.cpf,
        telefone: data.telefone,
        saldo: 0, 
        descricao: data.descricao || "Novo investidor", 
      });

    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      console.error("Erro na criação do usuário:", error);
      throw new HttpsError("internal", "Erro interno ao processar a criação do perfil.");
    }
  }
);