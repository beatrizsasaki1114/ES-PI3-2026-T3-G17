import {onCall, HttpsError} from "firebase-functions/v2/https";
import {db} from "../../../shared/firebase";
import {ChatMessage} from "../types/message";

export const getMessages = onCall(async (request) => {
  const {userId, startupId, limit = 50} = request.data;

  // Validações
  if (!userId || !startupId) {
    throw new HttpsError(
      "invalid-argument",
      "userId e startupId são obrigatórios"
    );
  }

  try {

    // Buscar mensagens ordenadas por timestamp (decrescente - mais recentes primeiro)
    const messagesSnapshot = await db
      .collection("chats")
      .doc(`${userId}_${startupId}`)
      .collection("messages")
      .orderBy("timestamp", "desc")
      .limit(limit)
      .get();

    const messages: ChatMessage[] = [];

    messagesSnapshot.forEach((doc) => {
      messages.push({
        id: doc.id,
        ...doc.data(),
      } as ChatMessage);
    });

    // Retornar em ordem cronológica (mais antigas primeiro)
    return {
      success: true,
      messages: messages.reverse(),
      count: messages.length,
    };
  } catch (error) {
    console.error("Erro ao buscar mensagens:", error);
    throw new HttpsError(
      "internal",
      "Erro ao buscar mensagens: " + (error as Error).message
    );
  }
});
