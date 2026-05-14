// Beatriz Naomi
import {Users} from "../types";
import {db} from "../../shared/firebase";
// import { getDataConnect } from "firebase-admin/data-connect";
// import { CollectionGroup } from "firebase-admin/firestore";
// import { getFirestore, collection, getDocs } from "firebase/firestore";

const usuariosCollection = db.collection("Usuários");

// function que adiciona um novo usuário na coleção Usuários
export async function setUser(data: Users) {

  await  usuariosCollection.doc(data.uid).set({
    uid: data.uid,
    nome: data.nome,
    sobrenome: data.sobrenome,
    email: data.email,
    cpf: data.cpf,
    telefone: data.telefone,
  });

   return {
      message: "Usuário cadastrado com sucesso",
      uid: data.uid,
    };

}

// Feito por Heloisa

// function que procura o usuário no banco
export async function getUser(email: string) {
  const querySnapshot = await usuariosCollection.where('email', '==', email).get(); // verifica email
  if (querySnapshot.empty){
    return null;
  } 
  const doc = querySnapshot.docs[0]; // o documento do usuario
  const userData = doc.data(); // informações do documento

  return {
    // id do Firestore
    id: doc.id,          
    nome: userData.nome, 
    email: userData.email
  };
}
