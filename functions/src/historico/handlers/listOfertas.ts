// Beatriz Naomi
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getOfertas } from "../repositories/historicoRepository";
import { Timestamp } from "firebase-admin/firestore";

export const listOfertas = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        const { startupId } = request.data;

        if (!startupId) {
            throw new HttpsError("invalid-argument", "O startupId é obrigatório.");
        }

        // Horário de funcionamento do mercado: 09:00 às 18:00 (horário de Brasília)
        // O Firebase roda em UTC, então 09:00 BRT = 12:00 UTC / 18:00 BRT = 21:00 UTC
        const hoje    = new Date();
        const dataId  = hoje.toISOString().split("T")[0];

        const abertura    = Timestamp.fromDate(new Date(dataId + "T12:00:00.000Z")); // 09:00 BRT
        const fechamento  = Timestamp.fromDate(new Date(dataId + "T21:00:00.000Z")); // 18:00 BRT

        const snapshot = await getOfertas(startupId, abertura, fechamento);

        // Agrupa por hora e calcula preço médio ponderado
        const porHora: Record<number, { somaValor: number; somaTokens: number; dataHora: Date }> = {};

        snapshot.forEach((doc) => {
            const { precoUnitario, quantidadeTokens, dataVenda } = doc.data();
            const dataHora = (dataVenda as Timestamp).toDate();

            // Chave única por hora do dia
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