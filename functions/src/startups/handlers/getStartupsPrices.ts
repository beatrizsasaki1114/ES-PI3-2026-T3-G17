// Beatriz Naomi
// Retorna PrecoAtualToken e PrecoAnteriorToken de uma startup pelo ID
// Usado pelo InvestmentPerformanceChart para calcular a projeção de investimento

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getStartupPrices as getPrices } from "../repositories/startupRepository";

export const getStartupPrices = onCall(
    { region: "southamerica-east1" },
    async (request) => {
        // Extrai o startupName enviado pelo Flutter
        const { startupName } = request.data;

        // Valida que o startupName foi informado
        if (!startupName) {
            throw new HttpsError("invalid-argument", "O startupName é obrigatório.");
        }

        // Busca o documento da startup no Firestore
        const precos = await getPrices(startupName);
        // Se não encontrou, retorna erro
        if (!precos) {
            throw new HttpsError("not-found", "Startup não encontrada.");
        }


        // Retorna apenas os campos de preço necessários para o gráfico
        return {
            precoAtual:    precos.precoAtual,
            precoAnterior: precos.precoAnterior,
        };
    }
);