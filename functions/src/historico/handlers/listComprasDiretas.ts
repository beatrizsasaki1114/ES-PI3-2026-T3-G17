// Beatriz Naomi
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getComprasDiretas } from "../repositories/historicoRepository";
import { Timestamp } from "firebase-admin/firestore";

export const listComprasDiretas = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        // Extrai o startupId enviado pelo Flutter
        const { startupId } = request.data;

        if (!startupId) {
            throw new HttpsError("invalid-argument", "O startupId é obrigatório.");
        }
      
        // Pega a data atual
        const hoje   = new Date();
        // Converte para YYYY-MM-DD
        const dataId = hoje.toISOString().split("T")[0];
        
        // Abertura do mercado: 09:00 BRT = 12:00 UTC
        const abertura   = Timestamp.fromDate(new Date(dataId + "T12:00:00.000Z")); 
        // Fechamento do mercado: 18:00 BRT = 21:00 UTC
        const fechamento = Timestamp.fromDate(new Date(dataId + "T21:00:00.000Z")); 

        // Busca todas as compras diretas da startup dentro do horário de mercado de hoje
        const snapshot = await getComprasDiretas(startupId, abertura, fechamento);
         // Objeto para agrupar compras por hora
        const porHora: Record<number, { somaValor: number; somaTokens: number; dataHora: Date }> = {};

        // Itera sobre cada compra direta encontrada
        snapshot.forEach((doc) => {
            const { precoUnitario, quantidadeTokens, dataCompra } = doc.data();
            // Converte o Timestamp do Firestore para Date
            const dataHora = (dataCompra as Timestamp).toDate();
             // Cria chave única por hora 
            const chave = dataHora.getUTCFullYear() * 1000000
                        + (dataHora.getUTCMonth() + 1) * 10000
                        + dataHora.getUTCDate() * 100
                        + dataHora.getUTCHours();

             // Se ainda não tem entrada para essa hora, cria uma nova
            if (!porHora[chave]) {
                porHora[chave] = { somaValor: 0, somaTokens: 0, dataHora };
            }

            // Acumula valor total e tokens da hora
            porHora[chave].somaValor  += precoUnitario * quantidadeTokens;
            porHora[chave].somaTokens += quantidadeTokens;
        });

        // Converte para array, ordena por hora e calcula preço médio
        const data = Object.entries(porHora)
            .sort(([a], [b]) => parseInt(a) - parseInt(b))
            .map(([, { somaValor, somaTokens, dataHora }]) => ({
                dataHora:   dataHora.toISOString(),
                // Preço médio ponderado da hora
                precoMedio: parseFloat((somaValor / somaTokens).toFixed(2)),
                 // Volume total de tokens negociados
                volume: somaTokens,
            }));

        // Retorna a contagem e os dados para o Flutter
        return { count: data.length, data };
    }
);