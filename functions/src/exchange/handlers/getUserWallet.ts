// Criada por Sofia de Sousa 

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { db } from "../../shared/firebase"; // Import a conexão com o Firebase Firesstore

     // O que essa função tem que fazer - buscar e montar os dados financeiros da carteira do usuário
       // verifica login
       // busca dados no Firebase
       // lê carteira
       // lê saldo
       // lê ordens
       // calcula investimentos

export const getUserWallet = onCall(async (request) => {

    //Pega o usuário logado
    const uid = request.auth?.uid;


    // Se o usuário não estiver logado, uma validação
    if (!uid) {
        throw new HttpsError(
            "unauthenticated",
            "Usuário não autenticado.",
        );
    }
    

    // Capturar erros, evitando da problema na funçoa
    try {

        // Busca dados em paralelo
        // Aqui tem 3 buscas ao mesmo tempo
        const [walletDoc, userDoc, ordersSnapshot] = await Promise.all([
            db.collection("wallets").doc(uid).get(),
            db.collection("users").doc(uid).get(),

            // Busca todas as ordens do usuário, independente do status ou tipo
            db.collection("orders")
                // Filtra apenas as ordens do usuário logado
                .where("userId", "==", uid)
                // Executa a query do firestore(consulta)
                .get(),
        ]);
        

        // Se pega os dados das coleções, se não tiver dados, retorna um objeto vazio
        const wallet = walletDoc.data() ?? {};
        const user = userDoc.data() ?? {};

        // Saldo disponível do investidor
        const saldoReais = Number(user.saldoReais ?? 0);

        // Quantidade de tokens na carteira do usuário
        const tokens = Number(wallet.tokens ?? 0);

        // QUanto o usuário investiu 
        const totalInvested = Number(wallet.totalInvested ?? 0);

        // pega o documents do Firestore e transforma em um array de objetos JS
        const orders = ordersSnapshot.docs.map((doc) => doc.data());

        // Apenas ordens de compra concluídas
        const buyOrders = orders.filter(
            (order) =>
                order.type === "buy" &&
                //Ignora ordens canceladas, mesmo que sejam de compra, não devem ser consideradas
                order.status !== "cancelled",
        );

        // O reduce soma tudo
        const investedByOrders = buyOrders.reduce(
            // o acc é um acumulador
            // order.total é o valor total daquela ordem
            (acc, order) => acc + Number(order.total ?? 0),
            0,
        );

        // Quantidade total de ordens do usuário
        const totalOrders = orders.length;

        return {

            // Indica que tudo deu certo
            success: true,

            // Saldo em reais
            saldoReais,

            // Carteira
            tokens,
            totalInvested,

            // Dados calculados
            investedByOrders,
            totalOrders,

            // Verifica se o documento da carteira existe
            hasWallet: walletDoc.exists,
            hasUser: userDoc.exists,
        };

        // Captura de erro 
    } catch (error) {
        console.error(error);
        

        // Negocio padronizado do front
        throw new HttpsError(
            "internal",
            "Erro ao buscar carteira do usuário.",
        );
    }
});