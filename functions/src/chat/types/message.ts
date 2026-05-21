export interface ChatMessage {
  id?: string;
  userId: string;
  startupId: string;
  text: string;
  isFromStartup: boolean;
  timestamp: number; // Timestamp em milissegundos
  read?: boolean;
}

export interface ChatConversation {
  id?: string;
  userId: string;
  startupId: string;
  startupName: string;
  lastMessage: string;
  lastMessageTimestamp: number;
  unreadCount: number;
  createdAt: number;
}
