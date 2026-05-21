import {onCall, HttpsError} from "firebase-functions/v2/https";
import {db} from "../../../shared/firebase";
import {ChatConversation} from "../types/message";

export const getConversations = onCall(async (request) => {
  const {userId} = request.data;

  if (!userId) {
    throw new HttpsError("invalid-argument", "userId é obrigatório");
  }

  try {

    // Buscar todas as conversas do usuário
    const conversationsSnapshot = await db
      .collectionGroup("chats")
      .where("userId", "==", userId)
      .orderBy("lastMessageTimestamp", "desc")
      .get();

    const conversations: ChatConversation[] = [];

    conversationsSnapshot.forEach((doc) => {
      conversations.push({
        id: doc.id,
        ...doc.data(),
      } as ChatConversation);
    });

    return {
      success: true,
      conversations,
      count: conversations.length,
    };
  } catch (error) {
    console.error("Erro ao buscar conversas:", error);
    throw new HttpsError(
      "internal",
      "Erro ao buscar conversas: " + (error as Error).message
    );
  }
});
