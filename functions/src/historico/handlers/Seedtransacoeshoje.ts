// Beatriz Naomi
// Cria transações automaticamas no dia atual para todas as startups
// para que o calculateTokenPrice consiga calcular o VWAP

import { onCall } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db } from "../../shared/firebase";
import { getStartups } from "../repositories/historicoRepository";

// Usuários de teste para simular compradores/vendedores
const COMPRADORES = [
    "55AMDMJd9eTix7MAk7znFBlam1m2",
    "TfcqwrycdPPDJ3DbB9eI87aDdIs2",
    "9wZCBiQ9NrMdR4VlOAmGAdFBAFO2",
    "xxQQHo9mLUMOuVOTYeaIABNS3ti2",
];

const VENDEDORES = [
    "NbrnTP3fAbnFbmOHnKYaXRvj7uff",
    "0LYTH8xIZM1JRcoreogrNwwmq6OL",
    "kTkx9NIQ0Wobtqn62tOy4CqpIqK3",
];

function randomBetween(min: number, max: number): number {
    return Math.random() * (max - min) + min;
}

function randomInt(min: number, max: number): number {
    return Math.floor(randomBetween(min, max));
}

export const seedTransacoesHoje = onCall(
    { region: "southamerica-east1" },
    async () => {
        const agora  = new Date();
        const dataId = agora.toISOString().split("T")[0];

        const startupsSnapshot = await getStartups();
        let totalTransacoes = 0;

        for (const startupDoc of startupsSnapshot.docs) {
            const startupId = startupDoc.id;
            const startupData = startupDoc.data() as any;
            const precoAtual: number = startupData.PrecoAtualToken ?? startupData.precoAtualToken ?? 1.0;

            const batch = db.batch();

            // Gera 5 transações distribuídas ao longo do dia (08:00-17:00)
            for (let i = 0; i < 5; i++) {
                const hora = 8 + i * 2; // 08, 10, 12, 14, 16
                const minuto = randomInt(0, 59);

                // Preço com ruído ±2% em torno do preço atual
                // Ruído ±1% para simular variação real de mercado
                const ruido = (Math.random() * 0.02) - 0.01;
                const precoTransacao = parseFloat(
                    Math.max(0.01, precoAtual * (1 + ruido)).toFixed(4)
                );

                const quantidade = randomInt(10, 50);

                const horaStr   = hora.toString().padStart(2, '0');
                const minutoStr = minuto.toString().padStart(2, '0');
                const dataTransacao = new Date(`${dataId}T${horaStr}:${minutoStr}:00.000Z`);

                const compradorId = COMPRADORES[randomInt(0, COMPRADORES.length)];
                const vendedorId  = VENDEDORES[randomInt(0, VENDEDORES.length)];

                const ofertaRef = db.collection("Ofertas").doc();
                batch.set(ofertaRef, {
                    startupId,
                    startupNome:      startupData.NomeStartup ?? "",
                    precoUnitario:    precoTransacao,
                    quantidadeTokens: quantidade,
                    valorTotal:       parseFloat((precoTransacao * quantidade).toFixed(2)),
                    status:           "vendida",
                    vendedorId,
                    compradorId,
                    dataCriacao:      Timestamp.fromDate(dataTransacao),
                    dataVenda:        Timestamp.fromDate(dataTransacao),
                    investmentDate:   dataId,
                });
            }

            await batch.commit();
            totalTransacoes += 5;

            console.log(`Startup ${startupId}: 5 transações criadas para ${dataId}`);
        }

        return {
            success: true,
            message: `${totalTransacoes} transações criadas para ${dataId}`,
        };
    }
);