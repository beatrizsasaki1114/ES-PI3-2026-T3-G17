// Beatriz Naomi
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getComprasDiretas } from "../repositories/historicoRepository";
import { Timestamp } from "firebase-admin/firestore";

export const listComprasDiretas = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        const { startupId } = request.data;

        if (!startupId) {
            throw new HttpsError("invalid-argument", "O startupId é obrigatório.");
        }

        // Horário de funcionamento do mercado: 09:00 às 18:00 (horário de Brasília)
        
        const hoje   = new Date();
        const dataId = hoje.toISOString().split("T")[0];

        const abertura   = Timestamp.fromDate(new Date(dataId + "T12:00:00.000Z")); 
        const fechamento = Timestamp.fromDate(new Date(dataId + "T21:00:00.000Z")); 

        const snapshot = await getComprasDiretas(startupId, abertura, fechamento);

        const porHora: Record<number, { somaValor: number; somaTokens: number; dataHora: Date }> = {};

        snapshot.forEach((doc) => {
            const { precoUnitario, quantidadeTokens, dataCompra } = doc.data();
            const dataHora = (dataCompra as Timestamp).toDate();

            const chave = dataHora.getUTCFullYear() * 1000000
                        + (dataHora.getUTCMonth() + 1) * 10000
                        + dataHora.getUTCDate() * 100
                        + dataHora.getUTCHours();

            if (!porHora[chave]) {
                porHora[chave] = { somaValor: 0, somaTokens: 0, dataHora };
            }

            porHora[chave].somaValor  += precoUnitario * quantidadeTokens;
            porHora[chave].somaTokens += quantidadeTokens;
        });

        const data = Object.entries(porHora)
            .sort(([a], [b]) => parseInt(a) - parseInt(b))
            .map(([, { somaValor, somaTokens, dataHora }]) => ({
                dataHora:   dataHora.toISOString(),
                precoMedio: parseFloat((somaValor / somaTokens).toFixed(2)),
                volume:     somaTokens,
            }));

        return { count: data.length, data };
    }
);