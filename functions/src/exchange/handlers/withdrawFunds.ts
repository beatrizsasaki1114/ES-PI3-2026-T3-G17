// Crida por Sofia de Sousa

import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { db } from "../../shared/firebase";
import { BalanceOperationDTO, BalanceOperationResultDTO } from "../types/balance";

// O que a função tem que fazer
     // Verifica login - se o usuário está autenticado
     // Valida o valor 
     // Verificar o saldo 
     // Descontar o dinheiro 
     // Retornar o resultado 


// Essa funão irrá validar o valor enviado pelo Flutter
function validarValor(data: BalanceOperationDTO): number {
    // tranforma em número
    const valor = Number(data.valor);
    
    // validação
    if (!Number.isFinite(valor) || valor <= 0) {
        throw new HttpsError(
            "invalid-argument",
            "Informe um valor válido para retirar."
        );
    }

    return valor;
}

// Criando a function 
export const withdrawFunds = onCall(async (request): Promise<BalanceOperationResultDTO> => {
        const uid = request.auth?.uid;
        
    //  Valiação
        if (!uid) {
            throw new HttpsError(
                "unauthenticated",
                "Usuário não autenticado."
            );
        }
        
        // Aqui pega os dados enviado do Flutter e os valida 
        const valor = validarValor(
            request.data as BalanceOperationDTO
        );
        
        //Aponta para users no Firestore, para o usuário logado 
        const userRef = db.collection("users").doc(uid);

       // Transação para garantir que o processo seja atômico, ou seja, ou tudo acontece ou nada acontece, evitando erros de concorrência
        const saldoReais = await db.runTransaction(
            async (transaction) => {

                // Lê os documentos do usuário
                const snapshot = await transaction.get(userRef);
                
                // Verifica se o usuário existe
                if (!snapshot.exists) {
                    throw new HttpsError(
                        "not-found",
                        "Usuário não encontrado."
                    );
                }
                
                // Pega o saldo atual do usuário
                const saldoAtual = Number(
                    snapshot.data()?.saldoReais ?? 0
                );
                
                // Verifica se o saldo é suficiente para retirar 
                if (saldoAtual < valor) {
                    throw new HttpsError(
                        "failed-precondition",
                        "Saldo insuficiente para retirada."
                    );
                }
                
                // Calcula o novo saldo após a retirada
                const novoSaldo = saldoAtual - valor;
                

                // Atualiza o documento no firestore
                transaction.set(
                    userRef,
                    {
                        saldoReais: novoSaldo,
                        updatedAt: FieldValue.serverTimestamp(),
                    },

                    // Mantém os outros campos do documento (usuário)
                    { merge: true },
                );
                
                // Aqui vai retornar a transção atualizada 
                return novoSaldo;
            }
        );
        
        // Mensagem final, resposta para o flutter
        return {
            success: true,
            message: "Saldo retirado com sucesso.",
            saldoReais,
        };
    }
);