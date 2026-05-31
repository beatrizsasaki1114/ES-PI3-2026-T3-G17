// Beatriz Naomi
import {db} from "../../shared/firebase";
import{demoOfertas} from "../utils/ofertasSeedData";
import {Timestamp} from "firebase-admin/firestore";

// guardando as transações do documento na coleção de oferta
const ofertasCollection = db.collection("Ofertas");

export async function seedDemoOfertas(): Promise<string[]>{
    const batch = db.batch();
    const ids: string[]=[];
    demoOfertas.forEach((oferta)=>{
        const docRef = ofertasCollection.doc();
        // transformando os campos de data de string para Timestamp do Firestore
         const data: Record<string, any> = {
                ...oferta,
                dataCriacao: Timestamp.fromDate(new Date(oferta.dataCriacao)),
                investmentDate: Timestamp.fromDate(new Date(oferta.investmentDate)),
            };

          if (oferta.dataVenda) {
            data.dataVenda = Timestamp.fromDate(new Date(oferta.dataVenda));
            }
        batch.set(docRef, data);
        ids.push(docRef.id);
    });

    await batch.commit();
    return ids;
}