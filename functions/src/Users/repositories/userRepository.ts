import {Users} from "../types";
import {db} from "../../shared/firebase";
//import { getDataConnect } from "firebase-admin/data-connect";
//import { CollectionGroup } from "firebase-admin/firestore";
//import { getFirestore, collection, getDocs } from "firebase/firestore";

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

export async function getUser(email: string) {
  const querySnapshot = await usuariosCollection.where('email', '==', email).get();
  if (querySnapshot.empty){
    return null;
  } 
  const doc = querySnapshot.docs[0]; // o documento do usuario
  const userData = doc.data(); // informações do doc

  return {
    // id do Firestore
    id: doc.id,          
    nome: userData.nome, 
    email: userData.email,
    senha: userData.senha
  };
}
