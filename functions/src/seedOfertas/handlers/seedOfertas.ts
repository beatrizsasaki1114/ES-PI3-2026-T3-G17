// Beatriz Naomi

import { onCall , HttpsError} from "firebase-functions/v2/https";
import { seedDemoOfertas } from "../repositories/ofertasRepository";
import { normalizeString } from "../../shared/validation";

// Função para gerar Massa de dados de transações
export const seedOfertas = onCall(
    // seedKey: mesclainvest123
     { region: "southamerica-east1",
      secrets: ["SEED_OFERTAS_KEY"],
     },
      async (request)=>{
        if(!process.env.FUNCTIONS_EMULATOR){

            const seedKey = normalizeString(request.data?.seedKey);
            
            if(!process.env.SEED_OFERTAS_KEY  || seedKey !== process.env.SEED_OFERTAS_KEY){
                throw new HttpsError("permission-denied", "Fora do emulador sem seedKey válida.");
            }
        }
        const ofertasId = await seedDemoOfertas();
        return {
          data: {
              count: ofertasId.length,
              ids: ofertasId
            }
        };
})