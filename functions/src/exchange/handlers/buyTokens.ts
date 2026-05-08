import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { db } from "../../shared/firebase";

// O que a função tem que fazer

//verifica login
//valida dados
//busca startup
//verifica saldo
//desconta dinheiro
//adiciona tokens
//salva ordem
//calcula participação

export const buyTokens = onCall(async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
        throw new HttpsError(
            "unauthenticated",
            "Usuário não autenticado.",
        );
    }
    

    // Pega o id que vai pelo front da startup 
    const startupId = String(request.data.startupId ?? "").trim();
    // Quantidade dos tokens que o usuário quer comprar da startup 
    const quantity = Number(request.data.quantity ?? 0);
    

    // Validação caso a compra seja inválida, startup n existe
    if (!startupId) {
        throw new HttpsError(
            "invalid-argument",
            "Startup inválida.",
        );
    }
    

    // Validação que impede NaN, negativo e zero
    if (!Number.isFinite(quantity) || quantity <= 0) {
        throw new HttpsError(
            "invalid-argument",
            "Quantidade inválida.",
        );
    }

    const startupRef = db.collection("startups").doc(startupId);
    const userRef = db.collection("users").doc(uid);
    const walletRef = db.collection("wallets").doc(uid);

    // Vai criar um ID automático para a nova ordem
    const orderRef = db.collection("orders").doc();
 
    // Nesse try a gente tem algo muito importeee, ele vai garantir que nada falhe
    try {
        await db.runTransaction(async (transaction) => {
            // Busca startup
            const startupDoc = await transaction.get(startupRef);

            if (!startupDoc.exists) {
                throw new HttpsError(
                    "not-found",
                    "Startup não encontrada.",
                );
            }

            // Busca usuário
            const userDoc = await transaction.get(userRef);

            if (!userDoc.exists) {
                throw new HttpsError(
                    "not-found",
                    "Usuário não encontrado.",
                );
            }

            // Busca a carteiaa 
            const walletDoc = await transaction.get(walletRef);
            
            // Aqui são os dados do banco de dados que vão ser transformados em objetos de JS
            const startup = startupDoc.data() ?? {};
            const user = userDoc.data() ?? {};
            const wallet = walletDoc.data() ?? {};

            // Dados da startup que estão no banco
            const startupName = startup.NomeStartup ?? "Startup";

            const tokenPrice = Number(
                startup.PrecoAtualToken ?? 0,
            );

            const totalTokensEmitidos = Number(
                startup.TotalTokensEmitidos ?? 0,
            );
            
            //Validção para que o preço seja válido 
            if (tokenPrice <= 0) {
                throw new HttpsError(
                    "failed-precondition",
                    "Token inválido.",
                );
            }

            // Cálculo da compra
            const total = Number(
                (quantity * tokenPrice).toFixed(2),
            );

            // Saldo do usuário
            const saldoAtual = Number(
                user.saldoReais ?? 0,
            );

            // Verifica saldo é o suficiente, pq não da para comprar se ele não tiver
            if (saldoAtual < total) {
                throw new HttpsError(
                    "failed-precondition",
                    "Saldo insuficiente.",
                );
            }

            // Tokens atuais do usuário
            const currentTokens = Number(
                wallet.tokens ?? 0,
            );

            // Total investido
            const currentInvested = Number(
                wallet.totalInvested ?? 0,
            );

            // Atualiza saldo do usuário
            transaction.update(userRef, {

                // Saldo novo
                saldoReais: Number(
                    (saldoAtual - total).toFixed(2),
                ),
                // Isso aqui é só para salvar quando foi essa última atualização
                updatedAt: FieldValue.serverTimestamp(),
            });

            // Atualiza a carteira do usuário 
            transaction.set(
                walletRef,
                { 
                    //Vai adicionar os tokens comprados pelo usuário
                    tokens: currentTokens + quantity,
                    // Soma o investimentoa
                    totalInvested: Number(
                        (currentInvested + total).toFixed(2),
                    ),

                    updatedAt: FieldValue.serverTimestamp(),
                },

                //Atualiza sem apagar os outros campos
                // Merge - é um recurso onde o compilador combina duas ou mais declarações separadas com o mesmo nome em uma única definição
                { merge: true },
            );

            // Participação do usuário
            const participacaoPercentual =
                totalTokensEmitidos > 0
                    ? Number(
                        (
                            ((currentTokens + quantity) /
                                totalTokensEmitidos) *
                            100
                        ).toFixed(4),
                    )
                    : 0;

            // Cria ordem
            // Salva o histórico da operação 
            transaction.set(orderRef, {
                
                // Campos da ordem
                id: orderRef.id,
                userId: uid,
                startupId,
                startupName,
                type: "buy",
                quantity,
                price: tokenPrice,
                total,
                participacaoPercentual,
                status: "completed",
                createdAt: FieldValue.serverTimestamp(),
            });
        });
        

        // Resposta que vai para o front se tudo der certinho
        return {
            success: true,

            message: "Compra realizada com sucesso.",
        };
    } catch (error) {
        console.error(error);
        
        // Se der erro resposta que vai para o front end padrão de erro
        throw new HttpsError(
            "internal",
            "Erro ao comprar tokens.",
        );
    }
});