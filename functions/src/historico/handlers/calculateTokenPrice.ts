// Beatriz Naomi
// Calcula e atualiza o preço do token de cada startup com base em:
//  VWAP do dia — preço médio ponderado das transações executadas
// Escassez — quanto dos tokens emitidos já estão em circulação

import { onSchedule } from "firebase-functions/v2/scheduler";
import { Timestamp } from "firebase-admin/firestore";
import {
    getOfertas,
    getComprasDiretas,
    getStartups,
    atualizarPrecoToken,
} from "../repositories/historicoRepository";

export const calculateTokenPrice = onSchedule(
    {
        // Roda às 18:05 todos os dias, logo após o fechamento do mercado (18:00)
        schedule: "5 18 * * *",
        timeZone: "America/Sao_Paulo",
        region:   "southamerica-east1",
    },
    async () => {
        const agora   = new Date();
        const dataId  = agora.toISOString().split("T")[0];

        const inicioDoDia = Timestamp.fromDate(new Date(dataId + "T00:00:00.000Z"));
        const fimDoDia    = Timestamp.fromDate(new Date(dataId + "T23:59:59.999Z"));

        const startupsSnapshot = await getStartups();

        for (const startupDoc of startupsSnapshot.docs) {
            const startupId = startupDoc.id;
            const startup   = startupDoc.data();

            const tokensEmitidos: number = startup.TotalTokensEmitidos ?? startup.totalTokensEmitidos ?? 0;
            const precoAtual:     number = startup.PrecoAtualToken ?? startup.precoAtualToken ?? 1.0;

            if (tokensEmitidos === 0) continue;

            // ── 1. VWAP do dia ─────────────────────────────────────────────
            // Apenas transações executadas — o preço real que o mercado pagou
            const ofertasHoje = await getOfertas(startupId, inicioDoDia, fimDoDia);
            const comprasHoje = await getComprasDiretas(startupId, inicioDoDia, fimDoDia);

            if (ofertasHoje.empty && comprasHoje.empty) {
                console.log(`Startup ${startupId}: sem transações hoje, preço mantido em R$${precoAtual}`);
                continue;
            }

            let somaValor  = 0;
            let somaTokens = 0;

            ofertasHoje.forEach(doc => {
                const { precoUnitario, quantidadeTokens } = doc.data();
                somaValor  += (precoUnitario   as number) * (quantidadeTokens as number);
                somaTokens += (quantidadeTokens as number);
            });

            comprasHoje.forEach(doc => {
                const { precoUnitario, quantidadeTokens } = doc.data();
                somaValor  += (precoUnitario   as number) * (quantidadeTokens as number);
                somaTokens += (quantidadeTokens as number);
            });

            const vwapHoje = somaValor / somaTokens;

          
            // Conta todos os tokens que já circulam no histórico completo
            // Passa intervalo desde o início até agora para pegar tudo
            const inicio = Timestamp.fromDate(new Date("2020-01-01T00:00:00.000Z"));
            const agora2 = Timestamp.fromDate(new Date());

            const todasCompras = await getComprasDiretas(startupId, inicio, agora2);
             let tokensCirculando = 0;
    
            todasCompras.forEach(doc => {
                tokensCirculando += (doc.data().quantidadeTokens as number) ?? 0;
            });

           const taxaCirculacao = tokensCirculando / tokensEmitidos

          
            //  define o preço base; a escassez amplifica levemente
            const novoPreco = parseFloat(
                Math.max(0.01, vwapHoje * (1 + taxaCirculacao * 0.10)).toFixed(2)
            );

           
            await atualizarPrecoToken(startupId, novoPreco, precoAtual, Timestamp.now());

            console.log(
                `Startup ${startupId}: ` +
                `VWAP=R$${vwapHoje.toFixed(2)} | ` +
                `circulação=${(taxaCirculacao * 100).toFixed(1)}% | ` +
                `preço: R$${precoAtual} → R$${novoPreco}`
            );
        }
    }
);