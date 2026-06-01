// Beatriz Naomi
// Calcula e atualiza o preço do token de cada startup com base em:
// preço médio ponderado das transações executadas
//  quanto dos tokens emitidos já estão em circulação

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
        // Pega a data/hora atual
        const agora  = new Date();
        // Converte para YYYY-MM-DD para montar os timestamps do dia
        const dataId = agora.toISOString().split("T")[0];
     
        const inicioDoDia = Timestamp.fromDate(new Date(dataId + "T00:00:00.000Z"));
        const fimDoDia = Timestamp.fromDate(new Date(dataId + "T23:59:59.999Z"));

        // Busca todas as startups para processar uma por uma
        const startupsSnapshot = await getStartups();

        // Itera sobre cada startup
        for (const startupDoc of startupsSnapshot.docs) {
            // ID do documento da startup no Firestore
            const startupId = startupDoc.id;

            // Dados da startup
            const startup = startupDoc.data();

            // Total de tokens emitidos pela startup — usado para calcular tokens circulado
            // Tenta maiúsculo primeiro, depois minúsculo, e usa 0 como fallback
            const tokensEmitidos: number = startup.TotalTokensEmitidos ?? startup.totalTokensEmitidos ?? 0;

            // Preço atual do token — será salvo como PrecoAnteriorToken
            const precoAtual: number = startup.PrecoAtualToken ?? startup.precoAtualToken ?? 1.0;

            // Se não tem tokens emitidos, pula para evitar divisão por zero
            if (tokensEmitidos === 0) continue;

            const ofertasHoje = await getOfertas(startupId, inicioDoDia, fimDoDia);
            const comprasHoje = await getComprasDiretas(startupId, inicioDoDia, fimDoDia);
 
            // Se não houve nenhuma transação hoje, mantém o preço e pula
            if (ofertasHoje.empty && comprasHoje.empty) {
                console.log(`Startup ${startupId}: sem transações hoje, preço mantido em R$${precoAtual}`);
                continue;
            }

            let somaValor  = 0;  
            let somaTokens = 0; 

            // Soma os dados de cada oferta (venda entre usuários)
            ofertasHoje.forEach(doc => {
                const { precoUnitario, quantidadeTokens } = doc.data();
                somaValor  += (precoUnitario as number) * (quantidadeTokens as number);
                somaTokens += (quantidadeTokens as number);
            });

             // Soma os dados de cada compra direta (usuário compra da plataforma)
            comprasHoje.forEach(doc => {
                const { precoUnitario, quantidadeTokens } = doc.data();
                somaValor  += (precoUnitario as number) * (quantidadeTokens as number);
                somaTokens += (quantidadeTokens as number);
            });

            // VWAP = soma(preço × quantidade) / soma(quantidade)
            // Representa o preço médio real que o mercado pagou hoje
            const vwapHoje = somaValor / somaTokens;

            // Conta quantos tokens foram comprados diretamente hoje
            let tokensCirculando = 0;
            comprasHoje.forEach(doc => {
                tokensCirculando += (doc.data().quantidadeTokens as number) ?? 0;
            });

            // Taxa de circulação = tokens comprados hoje / total emitido
            // Ex: 400 tokens comprados hoje / 400000 emitidos = 0.1% de escassez
            const taxaCirculacao = Math.min(tokensCirculando / tokensEmitidos, 1.0);
            // Aplica o fator de escassez sobre o VWAP
            // Quanto mais tokens em circulação, maior o preço (lei da oferta e demanda)
            // Math.max(0.01) garante que o preço nunca vai a zero
            // toFixed(2) arredonda para 2 casas decimais
            const novoPreco = parseFloat(
                Math.max(0.01, vwapHoje * (1 + taxaCirculacao * 0.10)).toFixed(2)
            );

            // Salva o novo preço no Firestore
            // precoAtual vira PrecoAnteriorToken para calcular variação amanhã
            await atualizarPrecoToken(startupId, novoPreco, precoAtual, Timestamp.now());

            // Log para acompanhar o processamento
            console.log(
                `Startup ${startupId}: ` +
                `VWAP=R$${vwapHoje.toFixed(2)} | ` +
                `circulação=${(taxaCirculacao * 100).toFixed(1)}% | ` +
                `preço: R$${precoAtual} → R$${novoPreco}`
            );
        }
    }
);