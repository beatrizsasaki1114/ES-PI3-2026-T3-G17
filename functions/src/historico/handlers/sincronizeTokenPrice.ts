// Beatriz Naomi
// Roda para sincronizar o seedOfertas e o precoAtualToken  de cada startup 
// com base no último dia disponível no HistoricoDiario + escassez


import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import {
    getStartups,
    getComprasDiretas,
    getUltimoDiaHistorico,
    atualizarPrecoToken,
} from "../repositories/historicoRepository";

export const sincronizeTokenPrice = onCall(
    { region: "southamerica-east1" },
    async () => {
        const startupsSnapshot = await getStartups();
        const resultados: { startupId: string; precoAnterior: number; novoPreco: number }[] = [];

        for (const startupDoc of startupsSnapshot.docs) {
            const startupId = startupDoc.id;
            const startup   = startupDoc.data();

            const tokensEmitidos: number = startup.TotalTokensEmitidos ?? startup.totalTokensEmitidos ?? 0;
            const precoAtual:     number = startup.PrecoAtualToken ?? startup.precoAtualToken ?? 1.0;

            if (tokensEmitidos === 0) continue;

            // Pega o último dia do HistoricoDiario
            const historicoSnap = await getUltimoDiaHistorico(startupId);

            if (historicoSnap.empty) {
                console.log(`Startup ${startupId}: sem histórico, pulando.`);
                continue;
            }

            const ultimoDia            = historicoSnap.docs[0].data();
            const precoMedioUltimoDia: number = ultimoDia.precoMedio ?? precoAtual;

            // Calcula escassez com base em todas as transações históricas
            const inicio = Timestamp.fromDate(new Date("2020-01-01T00:00:00.000Z"));
            const agora  = Timestamp.fromDate(new Date());

            const todasCompras = await getComprasDiretas(startupId, inicio, agora);

            let tokensCirculando = 0;
            todasCompras.forEach(doc => {
                tokensCirculando += (doc.data().quantidadeTokens as number) ?? 0;
            });

            const taxaCirculacao = Math.min(tokensCirculando / tokensEmitidos, 1.0);

            // preço = VWAP do último dia × (1 + escassez × 0.10)
            const novoPreco = parseFloat(
                Math.max(0.01, precoMedioUltimoDia * (1 + taxaCirculacao * 0.10)).toFixed(2)
            );

            await atualizarPrecoToken(startupId, novoPreco, precoAtual, Timestamp.now());

            resultados.push({ startupId, precoAnterior: precoAtual, novoPreco });

            console.log(
                `Startup ${startupId}: ` +
                `último dia=${ultimoDia.data} | ` +
                `preçoMédio=R$${precoMedioUltimoDia} | ` +
                `circulação=${(taxaCirculacao * 100).toFixed(1)}% | ` +
                `preço: R$${precoAtual} → R$${novoPreco}`
            );
        }

        return {
            success: true,
            message: `${resultados.length} startups sincronizadas`,
            resultados,
        };
    }
);