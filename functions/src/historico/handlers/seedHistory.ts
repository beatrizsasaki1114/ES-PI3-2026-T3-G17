// Beatriz Naomi
import {onCall} from "firebase-functions/v2/https";
import { seedHistoricoDiarioNoBanco } from "../repositories/historicoRepository";

export const seedHistory = onCall(
    { region: "southamerica-east1" },
    async () => {
        
    try {
     
        await seedHistoricoDiarioNoBanco();
        
        return { 
            success: true, 
            message: "Histórico diário populado com sucesso!" 
        };
        } catch (error) {
            console.error("Erro ao popular histórico:", error);
            throw new Error("Falha ao executar o seed do histórico.");
        }
    }
    
);