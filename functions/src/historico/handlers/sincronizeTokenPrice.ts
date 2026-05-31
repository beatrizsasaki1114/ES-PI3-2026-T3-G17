// Beatriz Naomi
// Roda para sincronizar o seedOfertas e o precoAtualToken  de cada startup 
// com base no último dia disponível no HistoricoDiario + tokens circulados

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
          // Busca todas as startups para processar
        const startupsSnapshot = await getStartups();

         // Array para guardar o resultado de cada startup
        const resultados: { startupId: string; precoAnterior: number; novoPreco: number }[] = [];

        for (const startupDoc of startupsSnapshot.docs) {
            const startupId = startupDoc.id;
            const startup   = startupDoc.data();

            // Total de tokens emitidos — usado para calcular tokens circulados
            const tokensEmitidos: number = startup.TotalTokensEmitidos ?? startup.totalTokensEmitidos ?? 0;
            // Preço atual antes da sincronização — será salvo como PrecoAnteriorToken
            const precoAtual:     number = startup.PrecoAtualToken ?? startup.precoAtualToken ?? 1.0;

            if (tokensEmitidos === 0) continue;

            // Pega o último dia do HistoricoDiario
            const historicoSnap = await getUltimoDiaHistorico(startupId);

            if (historicoSnap.empty) {
                console.log(`Startup ${startupId}: sem histórico, pulando.`);
                continue;
            }

            // Pega os dados do último dia do histórico
            const ultimoDia = historicoSnap.docs[0].data();

            // Preço médio do último dia — base para o novo preço
            // Se não tiver, usa o preço atual como fallback
            const precoMedioUltimoDia: number = ultimoDia.precoMedio ?? precoAtual;

            // Calcula escassez com base em todas as transações históricas
            const inicio = Timestamp.fromDate(new Date("2020-01-01T00:00:00.000Z"));
            const agora  = Timestamp.fromDate(new Date());

            const todasCompras = await getComprasDiretas(startupId, inicio, agora);
            // Conta quantos tokens já foram comprados no total
            let tokensCirculando = 0;
            todasCompras.forEach(doc => {
                tokensCirculando += (doc.data().quantidadeTokens as number) ?? 0;
            });

            // Taxa de circulação limitada a 100% para não ultrapassar o total emitido
            const taxaCirculacao = Math.min(tokensCirculando / tokensEmitidos, 1.0);

            // preço = valor medio do último dia × (1 + taxa de tokens circulando × 0.10)
            const novoPreco = parseFloat(
                Math.max(0.01, precoMedioUltimoDia * (1 + taxaCirculacao * 0.10)).toFixed(2)
            );
            // Salva o novo preço no Firestore
            // precoAtual vira PrecoAnteriorToken para calcular variação futura
            await atualizarPrecoToken(startupId, novoPreco, precoAtual, Timestamp.now());
            
            // Registra no array de resultados
            resultados.push({ startupId, precoAnterior: precoAtual, novoPreco });
            // Log detalhado para acompanhar o processamento
            console.log(
                `Startup ${startupId}: ` +
                `último dia=${ultimoDia.data} | ` +
                `preçoMédio=R$${precoMedioUltimoDia} | ` +
                `circulação=${(taxaCirculacao * 100).toFixed(1)}% | ` +
                `preço: R$${precoAtual} → R$${novoPreco}`
            );
        }
        // Retorna resumo do processamento
        return {
            success: true,
            message: `${resultados.length} startups sincronizadas`,
            resultados,
        };
    }
);