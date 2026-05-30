// Beatriz Naomi
import { db } from "../../shared/firebase";
import { Timestamp } from "firebase-admin/firestore";

export async function getOfertas(startupId: string, inicioDoDia: Timestamp, fimDoDia: Timestamp){
    return await db.collection("Ofertas")
            .where("startupId", "==", startupId)
            .where("status", "==", "vendida")
            .where("dataVenda", ">=", inicioDoDia)
            .where("dataVenda", "<=", fimDoDia)
            .get();
}

export async function getComprasDiretas(startupId: string, inicioDoDia: Timestamp, fimDoDia: Timestamp){
    return await db.collection("ComprasDiretas")
        .where("startupId", "==", startupId)
        .where("status", "==", "concluida")
        .where("dataCompra", ">=", inicioDoDia)
        .where("dataCompra", "<=", fimDoDia)
        .get();
}


//Guardando o histórico de transações diária no banco
export async function processarHistoricoDiarioNoBanco(dataId: string, inicioDoDia: Timestamp, fimDoDia: Timestamp) {
    const startupsSnapshot = await db.collection("startups").get();

    // Para cada startup, calcula o preço médio das ofertas e compras vendidas no dia
    for (const startupDoc of startupsSnapshot.docs) {
        const startupId = startupDoc.id;

        let totalValor = 0;
        let totalTokens = 0;

        // Função interna para acumular o valor total e quantidade de tokens
        function acumular(precoUnitario: number, quantidadeTokens: number) {
            totalValor += precoUnitario * quantidadeTokens;
            totalTokens += quantidadeTokens;
        }

        // Buscamos todas as ofertas que foram negociadas e vendidas hoje
         const ofertasSnapshot = await getOfertas(startupId, inicioDoDia, fimDoDia);
        // Buscamos as compras de tokens que foram feitas diretas com a Startup hoje
        const comprasSnapshot = await getComprasDiretas(startupId, inicioDoDia, fimDoDia);

        // Verifica se ambas estão vazias antes de pular a startup
        if (ofertasSnapshot.empty && comprasSnapshot.empty) {
            console.log(`Nenhuma transação no dia ${dataId} para a startup ${startupId}.`);
            continue;
        }

        // Processa as ofertas
        ofertasSnapshot.forEach((ofertaDoc) => {
            const { precoUnitario, quantidadeTokens } = ofertaDoc.data();
            acumular(precoUnitario, quantidadeTokens);
        });      
        
        // Processa as compras diretas
        comprasSnapshot.forEach((compraDoc) => {
            const { precoUnitario, quantidadeTokens } = compraDoc.data();
            acumular(precoUnitario, quantidadeTokens);
        });
        
        // Segurança extra para evitar divisão por zero
        if (totalTokens > 0) {
            // Calculamos o preço médio de cada dia 
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
}

// Popula o HistoricoDiario com base em toda a massa de dados de ofertas
export async function seedHistoricoDiarioNoBanco() {
    const startupsSnapshot = await db.collection("startups").get();
    
    // Para cada startup, calcula o preço médio por dia 
    for (const startupDoc of startupsSnapshot.docs) {
        const startupId = startupDoc.id;
        
        // Busca todas as ofertas vendidas dessa startup na coleção demo
        const ofertasSnapshot = await db.collection("Ofertas")
            .where("startupId", "==", startupId)
            .where("status", "==", "vendida")
            .get();
      
         console.log(`Startup ${startupId}: ${ofertasSnapshot.size} ofertas encontradas`);

        if(ofertasSnapshot.empty){
            // pula para proxima startup
             console.log(`Startup ${startupId}: nenhuma oferta, pulando...`);
            continue;
        }

        // Mapa para guardar valores e tokes totais de cada dia
        const porData: Record<string, { somaValor: number; somaTokens: number }> = {};
        
        ofertasSnapshot.forEach((ofertaDoc) => {
            const { precoUnitario, quantidadeTokens, dataVenda } = ofertaDoc.data();
            
            // Extrai apenas o YYYY-MM-DD da string data
            const data: string = typeof dataVenda === "string"
                ? dataVenda.split("T")[0]
                : (dataVenda as Timestamp).toDate().toISOString().split("T")[0];
            
             // Inicializa o histórico das transações se ainda não tiver sido feito
            if (!porData[data]) {
                porData[data] = { somaValor: 0, somaTokens: 0 };
            }
            
            // Soma valor do token comprado de cada transação realizada no dia
            porData[data].somaValor += precoUnitario * quantidadeTokens;
            // Soma quantidade de tokens de cada transação realizada no dia
            porData[data].somaTokens += quantidadeTokens;
        });      

        const batch = db.batch();
        
        // Transforma o mapa porData em um array de pares
        for (const [data, { somaValor, somaTokens }] of Object.entries(porData)) {
            // Calcula o preco medio das transações daquele dia
            const precoMedio = somaValor / somaTokens;
            
            // Informa onde será colocado o documento no FireStore
            const docRef = db
                .collection("startups")
                .doc(startupId)
                .collection("HistoricoDiario")
                .doc(data);
            
            // Inicializa os campos dentro de cada documento no batch
            batch.set(docRef, {
                startupId,
                data,
                precoMedio: parseFloat(precoMedio.toFixed(4)),
                volumeNegociado: somaTokens,
                criadoEm: Timestamp.now(),
            });
        }
        
        // Realiza commit no firestore (por startup)
        await batch.commit();
    }
}


export async function getHistoricoPorPeriodo(
    startupId: string,
    periodo: "semana" | "mes" | "seisMeses" | "ano"
): Promise<{ data: string; precoMedio: number; volumeNegociado: number }[]> {
 
    const diasPorPeriodo: Record<string, number> = {
        semana:     7,
        mes:        30,
        seisMeses:  180,
        ano:        365,
    };
 
    const dias = diasPorPeriodo[periodo];
    if (!dias) throw new Error(`Período inválido: ${periodo}`);
 
    // Calcula a data de corte (YYYY-MM-DD) para filtrar no Firestore
    const hoje     = new Date();
    const corte    = new Date(hoje);
    corte.setDate(hoje.getDate() - dias);
    const dataCorte = corte.toISOString().split("T")[0];
 
    const snapshot = await db
        .collection("startups")
        .doc(startupId)
        .collection("HistoricoDiario")
        .where("data", ">=", dataCorte)
        .orderBy("data", "asc")
        .get();
 
    // Se não houver dados no período, retorna tudo disponível
    if (snapshot.empty) {
        const tudo = await db
            .collection("startups")
            .doc(startupId)
            .collection("HistoricoDiario")
            .orderBy("data", "asc")
            .get();
 
        return tudo.docs.map(doc => {
            const d = doc.data();
            return {
                data:             d.data as string,
                precoMedio:       d.precoMedio as number,
                volumeNegociado:  d.volumeNegociado as number,
            };
        });
    }
 
    return snapshot.docs.map(doc => {
        const d = doc.data();
        return {
            data:             d.data as string,
            precoMedio:       d.precoMedio as number,
            volumeNegociado:  d.volumeNegociado as number,
        };
    });
}

// Busca todas as startups
export async function getStartups() {
    return await db.collection("startups").get();
}
 
// Busca o último dia do HistoricoDiario de uma startup
export async function getUltimoDiaHistorico(startupId: string) {
    return await db
        .collection("startups")
        .doc(startupId)
        .collection("HistoricoDiario")
        .orderBy("data", "desc")
        .limit(1)
        .get();
}
 
// Atualiza o preço do token da startup
export async function atualizarPrecoToken(
    startupId: string,
    novoPreco: number,
    precoAnterior: number,
    criadoEm: Timestamp
) {
    await db.collection("startups").doc(startupId).update({
        PrecoAtualToken:        novoPreco,
        PrecoAnteriorToken:     precoAnterior,
        ultimaAtualizacaoPreco: criadoEm,
    });
}