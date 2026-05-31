// Beatriz Naomi
// Versão onCall do calculateTokenPrice para rodar manualmente
// Usei apenas para poder atualizar o valor do token sem precisar esperar 
// a function "calculateTokenPrice"
import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import {
    getOfertas,
    getComprasDiretas,
    getStartups,
    atualizarPrecoToken,
} from "../repositories/historicoRepository";

export const calcularPrecoTokenManual = onCall(
    { region: "southamerica-east1" },
    async () => {
        // Pega dia atual
        const agora  = new Date();
        // Transforma em YYYY-MM-DD
        const dataId = agora.toISOString().split("T")[0];
        // Vamos pegar apenas transações a partir da meia noite do dia atual
        // até as 23:59
        const inicioDoDia = Timestamp.fromDate(new Date(dataId + "T00:00:00.000Z"));
        const fimDoDia    = Timestamp.fromDate(new Date(dataId + "T23:59:59.999Z"));
        // Busca as startups 
        const startupsSnapshot = await getStartups();
        const resultados: { startupId: string; precoAnterior: number; novoPreco: number }[] = [];
        // Percorremos cada startup e buscamos o total de tokens emitidos e o preço atual do token
        for (const startupDoc of startupsSnapshot.docs) {
            const startupId = startupDoc.id;
            const data = startupDoc.data() as any;
            const tokensEmitidos: number = data.TotalTokensEmitidos ?? data.totalTokensEmitidos ?? 0;
            const precoAtual:     number = data.PrecoAtualToken     ?? data.precoAtualToken     ?? 1.0;

            if (tokensEmitidos === 0) continue;

            // Pegamos as ofertas realizadas e as compras Diretas
            // é feito de forma separada nessa function por conta da arquivo "ofertasSeedData"
            const ofertasHoje = await getOfertas(startupId, inicioDoDia, fimDoDia);
            const comprasHoje = await getComprasDiretas(startupId, inicioDoDia, fimDoDia);

            // Caso não houve nenhuma transação hoje, mantém o preço mas atualiza a variavel precoAnterior
            // para que a variação do próximo dia seja calculada corretamente
            if (ofertasHoje.empty && comprasHoje.empty) {
                await atualizarPrecoToken(startupId, precoAtual, precoAtual, Timestamp.now());
                console.log(`Startup ${startupId}: sem transações, PrecoAnteriorToken sincronizado com R$${precoAtual}`);
                continue;
            }
            // Faremos um preço médio ponderado por volume
            // Somando preço x quantidade de todas as transições / total de tokens negociados
            let somaValor  = 0;
            let somaTokens = 0;
            // Percorremos cada oferta realizada no dia
            ofertasHoje.forEach(doc => {
                const { precoUnitario, quantidadeTokens } = doc.data();
                somaValor  += (precoUnitario  as number) * (quantidadeTokens as number);
                somaTokens += (quantidadeTokens as number);
            });
            // Percorremos cada compra realizada no dia 
            comprasHoje.forEach(doc => {
                const { precoUnitario, quantidadeTokens } = doc.data();
                somaValor  += (precoUnitario  as number) * (quantidadeTokens as number);
                somaTokens += (quantidadeTokens as number);
            });
            // 
            const vwapHoje = somaValor / somaTokens;
            
            const inicio = Timestamp.fromDate(new Date("2020-01-01T00:00:00.000Z"));
            const agora2 = Timestamp.fromDate(new Date());
            const todasCompras = await getComprasDiretas(startupId, inicio, agora2);

            let tokensCirculando = 0;
            todasCompras.forEach(doc => {
                tokensCirculando += (doc.data().quantidadeTokens as number) ?? 0;
            });

            const taxaCirculacao = Math.min(tokensCirculando / tokensEmitidos, 1.0);
            const novoPreco = parseFloat(
                Math.max(0.01, vwapHoje * (1 + taxaCirculacao * 0.10)).toFixed(2)
            );

            await atualizarPrecoToken(startupId, novoPreco, precoAtual, Timestamp.now());
            resultados.push({ startupId, precoAnterior: precoAtual, novoPreco });

            console.log(
                `Startup ${startupId}: VWAP=R$${vwapHoje.toFixed(2)} | ` +
                `circulação=${(taxaCirculacao * 100).toFixed(1)}% | ` +
                `preço: R$${precoAtual} → R$${novoPreco}`
            );
        }

        return {
            success: true,
            message: `${resultados.length} startups atualizadas`,
            resultados,
        };
    }
);