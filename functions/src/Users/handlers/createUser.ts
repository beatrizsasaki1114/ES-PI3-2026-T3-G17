import {setUser} from "../repositories/userRepository";
import {CallableRequest, onCall} from "firebase-functions/v2/https";
import type {Users} from "../types/index";

// Function para criação do usuário no firebase
export const createUser = onCall(
  {region: "southamerica-east1"},
  async (request: CallableRequest<Users>) => {
    const data= request.data;
    return setUser({
      uid: data.uid,
      nome: data.nome,
      sobrenome: data.sobrenome,
      email: data.email,
      cpf: data.cpf,
      telefone: data.telefone,
    });
  });
