// Sofia de Sousa 

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { seedDemoStartups } from "../repositories/startupRepository";
import { normalizeString } from "../shared/validation";

//Cria a função de ver o catalago de startups
export const seedStartupCatalog = onCall(

    //Configuração da função, define a região onde ela será executa
    { region: "southamerica-east1" ,
    secrets: ["SEED_STARTUP_CATALOG_KEY"]
    },
    async (request) => {
      
    //Verifica se a funções não está rodando localmente    
     //Caso seja false irá significar que a função está rodando em produção, 
     // e nesse caso é necessário verificar a seedKey para 
     // garantir que apenas pessoas autorizadas possam executar a função de seed, 
     // protegendo os dados e o ambiente de produção contra execuções não autorizadas ou acidentais. 

    if (!process.env.FUNCTIONS_EMULATOR) {
        
        //
        const seedKey = normalizeString(
            request.data?.seedKey
        );

        if (
            //Validação da secret

            //Caso a secret nn exista
            !process.env.SEED_STARTUP_CATALOG_KEY ||
            //Se a chave enviada for diferente da correta
            seedKey !== process.env.SEED_STARTUP_CATALOG_KEY
        ) {
            throw new HttpsError(
                "permission-denied",
                "Seed bloqueada. Fora do emulator sem seedKey válido"
            );
        }
    }
    
    //Cria a startups de demo no banco
    const startupIds = await seedDemoStartups();
    
    //Retorna dados para o front, de quantas startups foram criada e seus ids
    return {
        data: {
            count: startupIds.length,
            ids: startupIds
        }
    };

});