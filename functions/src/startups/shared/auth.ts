import { CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { AuthenticatedUser } from "../types/authenticatedUser";


export function requireAuthenticatedUser(
    request: CallableRequest
): AuthenticatedUser {
    if (!request.auth || !request.auth.uid) {
        throw new HttpsError(
            "unauthenticated",
            "Usuário precisa estar autenticado para acessar esta função."
        );
    }

    return {
        uid: request.auth.uid,
        email: request.auth.token.email,
    };
}
