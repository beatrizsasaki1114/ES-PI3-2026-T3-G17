// Beatriz Naomi
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getHistoricoPorPeriodo } from "../repositories/historicoRepository";

export const listHistorico = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        const { startupId, periodo } = request.data;

        if (!startupId) {
            throw new HttpsError("invalid-argument", "O startupId é obrigatório.");
        }

        if (!periodo) {
            throw new HttpsError("invalid-argument", "O periodo é obrigatório.");
        }

        const historico = await getHistoricoPorPeriodo(startupId, periodo);

        return {
            count: historico.length,
            data: historico,
        };
    }
);