import * as functions from "firebase-functions";
import {userRepository} from "../repositories/userRepository";
import {Users} from "../types";

export const createUser = functions.https.onCall(async (request) => {
  const data= request.data as Users;
  return userRepository.createUser({
    uid: data.uid,
    nome: data.nome,
    email: data.email,
    cpf: data.cpf,
    telefone: data.telefone,
  });
});
