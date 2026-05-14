// Feito por Heloisa

import { criarPergunta, isInvestidor } from "../repositories/questionRepository";
// conjunto de funções que acessam o banco

// motores do firebase
import {CallableRequest, onCall, HttpsError} from "firebase-functions/v2/https";

// importando esqueletos que serão utilizados
import type {Question} from "../types/question";

// Function para criação do da pergunta
export const createQuestion = onCall(
  {region: "southamerica-east1"},
  async (request: CallableRequest<Question>) => {

    try {
    // verifica se o usuário está autenticado
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Usuário não autenticado");
    }

    // verifica se o campo é o Id real do usuário logado
    const data = request.data;
    const user = request.auth.uid; 
    
    // validar se é uma pergunta válida
    if (!data.pergunta || data.pergunta.length <  15) {
      throw new HttpsError("invalid-argument", "O texto deve conter no minímo 15 caracteres.");
    }

    //validar a regra de negócio para perguntas privadas, se ele é investidor
    // se a pergunta for privada, verificamos se ele é investidor
      if (data.isPrivada) {
        const verificar = await isInvestidor(user, data.startupId);
        if(!verificar){
          throw new HttpsError("permission-denied", "Apenas investidores podem enviar perguntas privadas.");
        }
      }
        // enviar para que o repositories salve no banco 
        // montagem do objeto Question a função resposável por criar a pergunta
      await criarPergunta({
          autorId: user, 
          startupId: data.startupId,
          pergunta: data.pergunta,
          isPrivada: data.isPrivada,
          dataCriacao: new Date(), // pega a data e hora atual do servidor
          resposta: "",
          respostaEnviada: false
      });

      // retornar sucesso para o aplicativo
      return { sucesso: true, mensagem: "Pergunta enviada com sucesso!" };
    }
    catch (error){
      console.error("Erro ao enviar pergunta:", error);
      if (error instanceof HttpsError) {
        throw error;
      }
      // se for um erro genérico
      throw new HttpsError("internal", "Ocorreu um erro interno no servidor.");
    } 
  }
);