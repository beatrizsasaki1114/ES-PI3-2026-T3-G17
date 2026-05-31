// Beatriz Naomi

import {CallableRequest, HttpsError} from "firebase-functions/https";
import {AuthenticatedUser} from "../types/authenticatedUser";

// Função que verifica se o usuário está autenticado
export function requireAuthenticatedUser(
  request: CallableRequest
): AuthenticatedUser {

  if (!request.auth) {
  // Lança HttpsError "unauthenticated" se não estiver logado
   throw new HttpsError(
    "unauthenticated",
    "Usuario precisa estar autenticado para acessar esta funcao."
   );
 }

 // Retorna uid e email do usuário autenticado
 return {
 uid: request.auth.uid,
 email: request.auth.token.email as string | undefined,
 };
}
