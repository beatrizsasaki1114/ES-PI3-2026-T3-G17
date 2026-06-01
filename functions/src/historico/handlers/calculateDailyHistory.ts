// Beatriz Naomi

import {Timestamp} from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { processarHistoricoDiarioNoBanco } from "../repositories/historicoRepository";

// Função que calcula diariamente o histórico das transações realizadas no dia atual
// Assim conseguimos tirar o valor médio do token em cada dia 
export const calculateDailyHistory = onSchedule(
    // atribuindo algumas informações para a função 
    {   
        // fazendo a função rodar todo dia às 23:59 
        schedule: "59 23 * * *",
        timeZone: "America/Sao_Paulo",
        region: "southamerica-east1",
    },

    async()=>{
        // Pegando data de hoje
        const hoje = new Date();
        // formalizando para informar apenas YYYY-MM-DD
        const dataId = hoje.toISOString().split("T")[0]

        const inicioDoDia = Timestamp.fromDate(new Date(dataId + "T00:00:00.000Z"));
        const fimDoDia = Timestamp.fromDate(new Date(dataId + "T23:59:59.999Z"));
        // Processa todas as transações do dia e salva o resumo no HistoricoDiario
        await processarHistoricoDiarioNoBanco(dataId, inicioDoDia, fimDoDia);
    }
)

