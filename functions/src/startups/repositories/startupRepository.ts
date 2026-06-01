// Bruno Machado, Sofia de Sousa

//Importações necessárias
import {db} from "../../shared/firebase";
import {StartupDocument, StartupListItem} from "../types/startupTypes";
import {demoStartup} from "../utils/startupSeedData"; //Importa as statups do banco

//Referência para a coleção de startups no Firestore
const startupsCollection = db.collection("startups");

//Função para converter um documento de startup em um item de lista
function toListItem(id: string, startup: StartupDocument): StartupListItem {
  return {
    ID: id,
    NomeStartup: startup.NomeStartup,
    Estagio: startup.Estagio,
    DescricaoCurta: startup.DescricaoCurta,
    CapitalCaptadoCent: startup.CapitalCaptadoCent,
    TotalTokensEmitidos: startup.TotalTokensEmitidos,
    PrecoAtualToken: (startup as any).PrecoAtualToken ?? 0,
    tags: startup.tags,
  } as unknown as StartupListItem; //Força o ts aceitar o objeto como uma StatupListItem
}

//Função para listar startups do banco de dados
export async function listStartupItems(): Promise<StartupListItem[]> {
  //Busca no banco 
  const snapshot = await startupsCollection.limit(100).get();
  //Pega os documentos do snapshot
  const docs = (snapshot.docs as any[]) || [];
  //Percorre cada documento 
  return docs.map((doc) => toListItem(doc.id, doc.data() as StartupDocument));
}

//Função para buscar uma startup especifica pelo ID
export async function getStartupById(startupId: string): Promise<StartupDocument | undefined> {
  const startupSnapshot = await startupsCollection.doc(startupId).get();
  
  //Se o documento não existir, irá retornar undefined
  if (!startupSnapshot.exists) {
    return undefined;
  }
  
  //Pega os dados da startup
  const data = startupSnapshot.data() as StartupDocument;
  
  //Adiciona o ID do documento aos dados da startup 
  data.ID = startupSnapshot.id; 
 
  //Retornar startup completa 
  return data;
}

 //Função que verifica se um usuário investiu na startup
export async function userIsInvestor(startupId: string, uid: string): Promise<boolean> {
  const investorSnapshot = await startupsCollection
    .doc(startupId)
    .collection("investidores")
    .doc(uid)
    .get();
  return investorSnapshot.exists;
}

//Função para popular o banco, vai criar startups de teste no banco
export async function seedDemoStartups(): Promise<string[]> {
  //Cria operação em lote para adicionar
  const batch = db.batch();
  //Guarda os IDs criados para retornar depois
  const ids: string[] = [];
  
  //Percorre startups de teste
  demoStartup.forEach((startup) => {
    //Cria documento com ID automático
    const docRef = startupsCollection.doc();
    //Prepara a gravação da startup no banco
    batch.set(docRef, startup);
    //Gurda os IDs criados para retornar depois
    ids.push(docRef.id);
  });
  
  //Salva tudo no banco 
  await batch.commit();
  //Retorna os IDs das srtatups criadas 
  return ids;
}

// Busca apenas os preços do token de uma startup, usado pelo getStartupPrices
export async function getStartupPrices(startupName: string): Promise<{ precoAtual: number; precoAnterior: number } | undefined> {
  const snap = await db.collection("startups")
            .where("NomeStartup", "==", startupName)
            .limit(1)
            .get();
 
  if (snap.empty) return undefined;
 
   const data = snap.docs[0].data() as any;
 
  return {
    precoAtual:    (data.PrecoAtualToken    as number) ?? 0,
    precoAnterior: (data.PrecoAnteriorToken as number) ?? 0,
  };
}