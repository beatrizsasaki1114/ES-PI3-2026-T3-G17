// Beatriz Naomi
import {Users} from "../types";
import {db} from "../../shared/firebase";
// import { getDataConnect } from "firebase-admin/data-connect";
// import { CollectionGroup } from "firebase-admin/firestore";
// import { getFirestore, collection, getDocs } from "firebase/firestore";

const usuariosCollection = db.collection("Usuários");

// function que adiciona um novo usuário na coleção Usuários
export async function setUser(data: Users) {

  await usuariosCollection.doc(data.uid).set({
    uid: data.uid,
    nome: data.nome,
    sobrenome: data.sobrenome,
    email: data.email,
    cpf: data.cpf,
    telefone: data.telefone,
    saldo: data.saldo,       
    descricao: data.descricao
  });

  return {
    message: "Usuário cadastrado com sucesso",
    uid: data.uid,
  };
}

// Aproveite para atualizar o getUser para que ele também retorne esses dados
export async function getUser(email: string) {
  const querySnapshot = await usuariosCollection.where('email', '==', email).get();
  
  if (querySnapshot.empty){
    return null;
  } 
  
  const doc = querySnapshot.docs[0];
  const userData = doc.data();

  return {
    id: doc.id,          
    nome: userData.nome, 
    email: userData.email,
    saldo: userData.saldo,       
    descricao: userData.descricao 
  };
}