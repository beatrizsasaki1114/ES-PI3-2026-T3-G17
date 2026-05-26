// Beatriz Naomi
// Guardando o histórico de transações diária no banco
// usaremos essas transações para calcular o preço médio diário de cada token 
import { db } from "../../shared/firebase";
import {Timestamp} from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";



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
        const startupsSnapshot = await db.collection("startups").get();

        // Para cada startups, calcula o preço médio das ofertas vendidas no dia
        for (const startupDoc of startupsSnapshot.docs) {
            const startupId = startupDoc.id;

            let totalValor = 0;
            let totalTokens = 0;
            // Função para acumular o valor total e quantidade de tokens que foram comprados 
            function acumular(precoUnitario: number, quantidadeTokens: number) {
                totalValor += precoUnitario * quantidadeTokens;
                totalTokens += quantidadeTokens;
            }
            // Buscamos todas as ofertas que foram negociadas e vendidas hoje
            const ofertasSnapshot = await db.collection("ofertas_demo")
            .where("startupId","==", startupId)
            .where("status", "==", "vendida",)
            .where("dataVenda", ">=", inicioDoDia)
            .where("dataVenda", "<=", fimDoDia)
            .get();

            
            if(ofertasSnapshot.empty){
                console.log(`Nenhuma oferta vendida no dia ${dataId}. Nenhum histórico diário criado.`);
                // pula para proxima startup
                continue;
            }

            ofertasSnapshot.forEach((ofertaDoc)=>{
                const {precoUnitario, quantidadeTokens} = ofertaDoc.data();
                acumular( precoUnitario, quantidadeTokens);
            });      
            
            // Buscamos as compras de tokens que foram feitas diretas com a Startups hoje
            const comprasSnapshot = await db.collection("ComprasDiretas")
            .where("startupId","==", startupId)
            .where("status", "==", "concluida")
            .where("dataCompra", ">=", inicioDoDia)
            .where("dataCompra", "<=", fimDoDia)
            .get();

            
            comprasSnapshot.forEach((compraDoc)=>{
                const {precoUnitario, quantidadeTokens} = compraDoc.data();
                acumular( precoUnitario, quantidadeTokens);
            });
            
            // Calculamos o preço médio do dia
            const precoMedio = totalValor / totalTokens;

            // Guardamos o histórico diário no banco, dentro de cada startup
            const docRef = db
            .collection("startups")
            .doc(startupId)
            .collection("HistoricoDiario")
            .doc(dataId);
    
            await docRef.set({
                startupId,
                data: dataId,
                precoMedio: parseFloat(precoMedio.toFixed(2)),
                volumeNegociado: totalTokens,
                criadoEm: Timestamp.now() 
            });
        }     
    }
)