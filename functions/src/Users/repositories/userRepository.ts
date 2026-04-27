import {Users} from "../types";
import {db} from "../../shared/firebase";


const usuariosCollection = db.collection("Usuários");
/**
 * Cria um usuário no Firestore
 * @param {Users} data Dados do usuário
 * @return {Promise<void>}
 */
export async function setUser(data: Users) {
  return usuariosCollection.doc(data.uid).set({
    uid: data.uid,
    nome: data.nome,
    sobrenome: data.sobrenome,
    email: data.email,
    cpf: data.cpf,
    telefone: data.telefone,
  });
}

export async function getUser
