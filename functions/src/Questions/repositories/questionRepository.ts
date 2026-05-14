// Feito por Heloisa

import { Question } from "../types/question"; 
// importando o esqueleto da pergunta do types

//import { models } from  "../lib/models/wallet";
// importando o modelo de carteira criado

import { db } from "../../shared/firebase";
// Importa a conexão configurada com o Firebase

// definição da coleção usada
const perguntasColletion = db.collection("Perguntas");

// function para criar a pergunta
export async function criarPergunta(data: Question) {
    await perguntasColletion.doc().set({
            autorId: data.autorId, 
            startupId: data.startupId,
            pergunta: data.pergunta,
            isPrivada: data.isPrivada,
            dataCriacao: data.dataCriacao,
            resposta: data.resposta,
            respostaEnviada: data.respostaEnviada,
    });
}
// o usuário só pode enviar perguntas privadas para a startup da qual ele tiver tokens
// function para verificar se o usuário tem tokens da startup
export async function isInvestidor(autorId: string, startupId: string): Promise<boolean > {
    // caminho no banco: vai no 'usuário' -> entra na coleção 'carteira' -> busca o documento com o ID da startup
    const investimentoRef = db.collection("Usuários").doc(autorId)
    db.collection("Wallet").doc(startupId);  // criado pela sofia
        
    const investimentoDoc = await investimentoRef.get();
    // aguarda o banco retornar o doc da startup (get)
    // se o documento da startup existir na carteira do usuário
    if (investimentoDoc.exists) {
        const dados = investimentoDoc.data();
        
        // pega a quantidade de tokens e faz a verificação (se não existir o campo, assume 0) e checa se é maior que zero
        const quantidadeTokens = dados?.tokens || dados?.quantity || 0; 
        
        return quantidadeTokens > 0; // se sim, retorna como true (sucesso)

    }
    // se não encontrou o documento, ele não tem investimentos nesta startup
    return false;
}
