import {Users} from "../types";
import {db} from "../shared/firebase";

export const userRepository ={
  createUser(data: Users) {
    return db.collection("Usuários").doc(data.uid).set({
      uid: data.uid,
      nome: data.nome,
      sobrenome: data.sobrenome,
      email: data.email,
      cpf: data.cpf,
      telefone: data.telefone,
    });
  },
};
