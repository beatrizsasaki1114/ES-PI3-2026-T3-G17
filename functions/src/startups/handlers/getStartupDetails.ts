// Sofia de Sousa - Lembrar de voltar para comentar dps 

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { requireAuthenticatedUser } from "../shared/auth";
import { normalizeString } from "../shared/validation";


import {
    getStartupById,
    userIsInvestor
} from "../repositories/startupRepository";


export const getStartupDetails = onCall(async (request) => {

   
    const user = requireAuthenticatedUser(request);

   
    const startupId = normalizeString(request.data?.startupId);

   
    if (!startupId) {
        throw new HttpsError(
            "invalid-argument",
            "ID da startup é obrigatório"
        );
    }

    const startup = await getStartupById(startupId);

   
    if (!startup) {
        throw new HttpsError(
            "not-found",
            "Startup não encontrada"
        );
    }

    
    const isInvestor = await userIsInvestor(startupId, user.uid);

    
    return {
        data: {
            
            ID: startup.ID,
            NomeStartup: startup.NomeStartup,
            Estagio: startup.Estagio,
            DescricaoCurta: startup.DescricaoCurta,
            DescricaoLonga: startup.DescricaoLonga,
            SumarioExecutivo: startup.SumarioExecutivo,
            CapitalCaptadoCent: startup.CapitalCaptadoCent,
            TotalTokensEmitidos: startup.TotalTokensEmitidos,
            PrecoAtualToken: startup.PrecoAtualToken,
            Fundadores: startup.Fundadores,
            MembrosExterno: startup.MembrosExterno,
            DemoVideo: startup.DemoVideo,
            DocumentosPublicos: startup.DocumentosPublicos,
            tags: startup.tags,
            createdAt: startup.createdAt,
            updatedAt: startup.updatedAt,
            access: {
                isInvestor,
                canTradeTokens: isInvestor
            }
        }
    };
});