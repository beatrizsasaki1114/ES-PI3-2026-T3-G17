import {onCall, HttpsError} from "firebase-functions/v2/https";
import {db} from "../../../shared/firebase";
import {ChatMessage} from "../types/message";

export const sendMessage = onCall(async (request) => {
  const {userId, startupId, text, isFromStartup} = request.data;

  // Validações
  if (!userId || !startupId || !text) {
    throw new HttpsError(
      "invalid-argument",
      "userId, startupId e text são obrigatórios"
    );
  }

  if (typeof text !== "string" || text.trim().length === 0) {
    throw new HttpsError("invalid-argument", "Mensagem não pode estar vazia");
  }

  try {

    // Criar a mensagem
    const message: ChatMessage = {
      userId,
      startupId,
      text: text.trim(),
      isFromStartup: isFromStartup || false,
      timestamp: Date.now(),
      read: false,
    };

    // Salvar mensagem na coleção de chats
    const messageRef = await db
      .collection("chats")
      .doc(`${userId}_${startupId}`)
      .collection("messages")
      .add(message);

    // Atualizar a conversa (última mensagem)
    const conversationRef = db
      .collection("chats")
      .doc(`${userId}_${startupId}`);

    const conversationSnapshot = await conversationRef.get();
    const startupSnapshot = await db
      .collection("Startups")
      .doc(startupId)
      .get();

    const startupData = startupSnapshot.data();
    const startupName = startupData?.name || "Startup";

    await conversationRef.set({
      userId,
      startupId,
      startupName,
      lastMessage: text.substring(0, 50), // Primeiros 50 caracteres
      lastMessageTimestamp: Date.now(),
      createdAt: conversationSnapshot.exists
        ? conversationSnapshot.data()?.createdAt
        : Date.now(),
    }, {merge: true});

    return {
      success: true,
      messageId: messageRef.id,
      message: "Mensagem enviada com sucesso",
    };
  } catch (error) {
    console.error("Erro ao enviar mensagem:", error);
    throw new HttpsError(
      "internal",
      "Erro ao enviar mensagem: " + (error as Error).message
    );
  }
});
