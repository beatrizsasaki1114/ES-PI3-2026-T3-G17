// Beatriz Naomi
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getHistoricoPorPeriodo } from "../repositories/historicoRepository";
// Função para listagem do histórico de transações de uma startup
export const listHistorico = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        // Extrai os parâmetros enviados pelo Flutter
        // startupId: qual startup buscar
        // periodo: "1S", "1M", "6M" ou "1A"
        const { startupId, periodo } = request.data;
        
        if (!startupId) {
            throw new HttpsError("invalid-argument", "O startupId é obrigatório.");
        }

        if (!periodo) {
            throw new HttpsError("invalid-argument", "O periodo é obrigatório.");
        }

        // Busca o histórico diário da startup para o período solicitado
        // Retorna array de { data: "YYYY-MM-DD", precoMedio: number, volumeNegociado: number }
        const historico = await getHistoricoPorPeriodo(startupId, periodo);
        
        // Retorna a contagem e os dados para o Flutter
        return {
            count: historico.length,
            data: historico,
        };
    }
);