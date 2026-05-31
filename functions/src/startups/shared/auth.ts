//Sofia de Sousa

import { CallableRequest, HttpsError } from "firebase-functions/v2/https";
import { AuthenticatedUser } from "../../types/authenticatedUser";

//Função que verifica se o usuário está logados, impede o acesso 
 //se não estiver autenticado, e retorna os dados do usuário autenticado
export function requireAuthenticatedUser(

    //Parametro - a função irá receber a requisição da Cloud Function, que contém os dados de autenticação do usuário
    request: CallableRequest
): AuthenticatedUser { // tipo de objeto que a função retorna
    if (!request.auth || !request.auth.uid) { //se não existe autentificação ou se não existe o ID do user
        throw new HttpsError(
            //Erro
            "unauthenticated",
            "Usuário precisa estar autenticado para acessar esta função."
        );
    }
    
    //Se passou pela verificação, retorna o ID e o email
    return {
        uid: request.auth.uid,
        email: request.auth.token.email,
    };
}
