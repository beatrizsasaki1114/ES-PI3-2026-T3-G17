// Beatriz Naomi

import {getAuth} from "firebase-admin/auth";
import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

// Inicializa o Firebase Admin SDK apenas uma vez
// getApps().length === 0 evita erro de inicialização duplicada em hot reload
if (getApps().length === 0) {
  initializeApp();
}
 
// Instâncias compartilhadas — importar diretamente nos repositórios e functions
export const auth =getAuth();
export const db = getFirestore();
