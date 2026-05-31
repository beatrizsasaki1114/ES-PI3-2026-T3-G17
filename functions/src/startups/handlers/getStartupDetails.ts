// Sofia de Sousa, Bruno Machado

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { requireAuthenticatedUser } from "../shared/auth";
import { normalizeString } from "../../shared/validation";

//Importação das funções do repositório para acessar os dados das startups e verificar o status do usuário como investidor
import {
    getStartupById,
    userIsInvestor
} from "../repositories/startupRepository";


export const getStartupDetails = onCall(
    { region: "southamerica-east1" },
    async (request) => {

    //Verifica se o usuário está autenticado, se não tiver a função lança erro automaticamente
    const user = requireAuthenticatedUser(request);
    //Normaliza o ID da startup recebido na requisição, garantindo que seja uma string limpa e sem espaços extras
    const startupId = normalizeString(request.data?.startupId);

    //Se o id estiver vazio, retorna erro
    if (!startupId) {
        throw new HttpsError(
            "invalid-argument",
            "ID da startup é obrigatório"
        );
    }
    
    //Busca startup no firestore usando o id fornecido, espera o banco responder
    const startup = await getStartupById(startupId);

   
    if (!startup) {
        throw new HttpsError(
            "not-found",
            "Startup não encontrada"
        );
    }

    //Verifica se o usuário é um investidor da startup, o que pode influenciar as informações que ele tem acesso
    const isInvestor = await userIsInvestor(startupId, user.uid);

    
    return {
        data: {
            
            //Campos retornados
            ID: startup.ID,
            NomeStartup: startup.NomeStartup,
            Estagio: startup.Estagio,
            DescricaoCurta: startup.DescricaoCurta,
            DescricaoLonga: startup.DescricaoLonga,
            SumarioExecutivo: startup.SumarioExecutivo,
            CapitalCaptadoCent: startup.CapitalCaptadoCent,
            TotalTokensEmitidos: startup.TotalTokensEmitidos,
            PrecoAtualToken:  (startup as any).PrecoAtualToken ?? startup.PrecoAtualToken,
            PrecoAnteriorToken: (startup as any).PrecoAnteriorToken  ?? null,
            Fundadores: startup.Fundadores,
            MembrosExterno: startup.MembrosExterno,
            DemoVideo: startup.DemoVideo,
            DocumentosPublicos: startup.DocumentosPublicos,
            tags: startup.tags,
            Perguntas: startup.Perguntas ?? [],
            Respostas: startup.Respostas ?? [],
            Eventos: startup.Eventos ?? {},
            createdAt: startup.createdAt,
            updatedAt: startup.updatedAt,

            //Controle de acesso, indica se o usuário investe
              //e que só pode negocias os tokens se for investidos.
            access: {
                isInvestor,
                canTradeTokens: isInvestor
            }
        }
    };
});