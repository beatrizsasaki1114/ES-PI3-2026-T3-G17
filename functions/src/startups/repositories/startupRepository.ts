//Bruno Machado, Sofia de Sousa

import { db } from "../../shared/firebase";
import { StartupDocument, StartupListItem } from "../types/startupTypes";
import { demoStartup } from "../utils/startupSeedData";

const startupsCollection = db.collection("startups");

function toListItem(id: string, startup: StartupDocument): StartupListItem {
    return {
        ID: id,
        NomeStartup: startup.NomeStartup,
        Estagio: startup.Estagio,
        DescricaoCurta: startup.DescricaoCurta,
        CapitalCaptadoCent: startup.CapitalCaptadoCent,
        TotalTokensEmitidos: startup.TotalTokensEmitidos,
        PrecoAtualToken: startup.PrecoAtualToken,
        tags: startup.tags
    };
}

export async function listStartupItems(): Promise<StartupListItem[]> {
    const snapshot = await startupsCollection.limit(100).get();
    return snapshot.docs.map((doc) => toListItem(doc.id, doc.data() as StartupDocument));
}

export async function getStartupById(startupId: string): Promise<StartupDocument | undefined> {
    const startupSnapshot = await startupsCollection.doc(startupId).get();
    return startupSnapshot.exists ? (startupSnapshot.data() as StartupDocument) : undefined;
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
        const docRef = startupsCollection.doc(startup.ID!); 
        batch.set(docRef, startup);
        ids.push(docRef.id);
    });

    await batch.commit();
    return ids;
}