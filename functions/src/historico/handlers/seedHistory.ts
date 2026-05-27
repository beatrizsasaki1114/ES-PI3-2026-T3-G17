// Beatriz Naomi
// Popula o HistoricoDiario com base em toda a massa de dados de ofertas

import { db } from "../../shared/firebase";
import {Timestamp} from "firebase-admin/firestore";
import {onCall} from "firebase-functions/v2/https";

export const seedHistory = onCall(
    { region: "southamerica-east1" },
    async () => {
        
        const startupsSnapshot = await db.collection("startups").get();
        // Para cada startup, calcula o preço médio por dia 
        for (const startupDoc of startupsSnapshot.docs) {
            
            const startupId = startupDoc.id;
            // Busca todas as ofertas vendidas dessa startup
            const ofertasSnapshot = await db.collection("ofertas_demo")
                .where("startupId", "==", startupId)
                .where("status", "==", "vendida")
                .get();
          
            if(ofertasSnapshot.empty){
                // pula para proxima startup
                continue;
            }
            // Mapa para guardar valores e tokes totais de um cada dia
            // A chave será a data de cada transação
            const porData: Record<string, { somaValor: number; somaTokens: number }> = {};
            
            ofertasSnapshot.forEach((ofertaDoc)=>{
                const {precoUnitario, quantidadeTokens, dataVenda} = ofertaDoc.data();
                // Extrai apenas o YYYY-MM-DD da string data
                const data: string = typeof dataVenda === "string"
                    ? dataVenda.split("T")[0]
                    : (dataVenda as Timestamp).toDate().toISOString().split("T")[0];
                
                 // Inicializa o histórico das transações se ainda não tiver sido feito
                if (!porData[data]) {
                    porData[data] = { somaValor: 0, somaTokens: 0 };
                }
                
                // Soma valor do token comprado de cada cada transação realizada no dia e multiplicamos pela quantidade de tokens
                porData[data].somaValor += precoUnitario * quantidadeTokens;
                // Soma quantidade de tokens de cada transação realizada no dia
                porData[data].somaTokens += quantidadeTokens;
            });      

            
           const batch = db.batch();
            // Transforma o mapa porData em um array de pares para melhor acesso da chave e valores
            for (const [data, { somaValor, somaTokens }] of Object.entries(porData)) {
                // Calcula o preco medio das transações daquele dia
                const precoMedio = somaValor / somaTokens;
                
                // Informa onde será colocado o documento no FireStore
                const docRef = db
                    .collection("startups")
                    .doc(startupId)
                    .collection("HistoricoDiario")
                    .doc(data);
                
                // Inficializa os campos dentro de cada documento
                batch.set(docRef, {
                    startupId,
                    data,
                    precoMedio: parseFloat(precoMedio.toFixed(4)),
                    volumeNegociado: somaTokens,
                    criadoEm: Timestamp.now(),
                });
        }
        // Realiza commit no firestore
         await batch.commit();
   
    }
});