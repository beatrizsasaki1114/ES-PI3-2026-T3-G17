// Bruno Machado, Sofia de Sousa

import {db} from "../../shared/firebase";
import {StartupDocument, StartupListItem} from "../types/startupTypes";
import {demoStartup} from "../utils/startupSeedData";

const startupsCollection = db.collection("startups");

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
  } as unknown as StartupListItem;
}

export async function listStartupItems(): Promise<StartupListItem[]> {
  const snapshot = await startupsCollection.limit(100).get();

  const docs = (snapshot.docs as any[]) || [];

  return docs.map((doc) => toListItem(doc.id, doc.data() as StartupDocument));
}

export async function getStartupById(startupId: string): Promise<StartupDocument | undefined> {
  const startupSnapshot = await startupsCollection.doc(startupId).get();

  if (!startupSnapshot.exists) {
    return undefined;
  }

  const data = startupSnapshot.data() as StartupDocument;

  data.ID = startupSnapshot.id; 

  return data;
}

export async function userIsInvestor(startupId: string, uid: string): Promise<boolean> {
  const investorSnapshot = await startupsCollection
    .doc(startupId)
    .collection("investidores")
    .doc(uid)
    .get();
  return investorSnapshot.exists;
}

export async function seedDemoStartups(): Promise<string[]> {
  const batch = db.batch();
  const ids: string[] = [];

  demoStartup.forEach((startup) => {
    const docRef = startupsCollection.doc(startup.ID);
    batch.set(docRef, startup);
    ids.push(docRef.id);
  });

  await batch.commit();
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