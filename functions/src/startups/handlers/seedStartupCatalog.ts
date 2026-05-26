// Sofia de Sousa - Lembrar de voltar para comentar dps 

import { HttpsError, onCall } from "firebase-functions/v2/https";
import { seedDemoStartups } from "../repositories/startupRepository";
import { normalizeString } from "../../shared/validation";

// seed_key: mesclainvest123
export const seedStartupCatalog = onCall(
    { region: "southamerica-east1" ,
    secrets: ["SEED_STARTUP_CATALOG_KEY"]
    },
    async (request) => {


    if (!process.env.FUNCTIONS_EMULATOR) {

        const seedKey = normalizeString(
            request.data?.seedKey
        );

        if (
            !process.env.SEED_STARTUP_CATALOG_KEY ||
            seedKey !== process.env.SEED_STARTUP_CATALOG_KEY
        ) {
            throw new HttpsError(
                "permission-denied",
                "Seed bloqueada. Fora do emulator sem seedKey válido"
            );
        }
    }

    const startupIds = await seedDemoStartups();

    return {
        data: {
            count: startupIds.length,
            ids: startupIds
        }
    };

});