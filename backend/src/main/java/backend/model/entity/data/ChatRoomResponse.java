package backend.model.entity.data;

import java.util.UUID;

import backend.model.entity.ChatMessage;
import backend.model.entity.User;

public class ChatRoomResponse {

  private UUID chatId;
  private User otherParticipant;
  private ChatMessage latestMessage;

  public ChatRoomResponse(UUID chatId, User otherParticipant, ChatMessage latestMessage) {
    this.chatId = chatId;
    this.otherParticipant = otherParticipant;
    this.latestMessage = latestMessage;
  }

  public UUID getChatId() {
    return chatId;
  }

  public void setChatId(UUID chatId) {
    this.chatId = chatId;
  }

  public User getOtherParticipant() {
    return otherParticipant;
  }

  public void setOtherParticipant(User otherParticipant) {
    this.otherParticipant = otherParticipant;
  }

  public ChatMessage getLatestMessage() {
    return latestMessage;
  }

  public void setLatestMessage(ChatMessage latestMessage) {
    this.latestMessage = latestMessage;
  }
}
