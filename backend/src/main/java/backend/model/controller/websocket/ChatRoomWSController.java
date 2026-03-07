package backend.model.controller.websocket;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.annotation.SubscribeMapping;
import org.springframework.stereotype.Controller;

import backend.model.entity.ChatMessage;
import backend.model.entity.Session;
import backend.model.repository.ChatMessageRepository;
import backend.model.repository.ChatRoomRepository;
import backend.model.repository.SessionRepository;
import backend.model.service.ChatRoomService;

@Controller
public class ChatRoomWSController {

  private final ChatRoomService chatRoomService;
  private final SessionRepository sessionRepository;
  private final ChatRoomRepository chatRoomRepository;
  private final ChatMessageRepository messageRepository;

  public ChatRoomWSController(ChatRoomService chatRoomService, SessionRepository sessionRepository,
      ChatRoomRepository chatRoomRepository, ChatMessageRepository messageRepository) {
    this.chatRoomService = chatRoomService;
    this.sessionRepository = sessionRepository;
    this.chatRoomRepository = chatRoomRepository;
    this.messageRepository = messageRepository;
  }

  @SubscribeMapping("chats/{chatId}")
  public List<ChatMessage> onSubscribe(@DestinationVariable String chatId,
      @Header("session-id") String sessionId) {
    if (sessionId == null || !validateSession(sessionId)) {
      return List.of();
    }

    UUID sessionUuid = UUID.fromString(sessionId);
    Session session = sessionRepository.findById(sessionUuid).get();
    UUID userId = session.getUser().getId();
    UUID chatUuid = UUID.fromString(chatId);

    if (!chatRoomRepository.isUserParticipant(chatUuid, userId)) {
      return List.of();
    }

    List<ChatMessage> messages = messageRepository.findByChatRoomIdOrderByTimestampAsc(chatUuid);
    return messages.stream()
        .map(msg -> {
          ChatMessage chatMsg = new ChatMessage();
          chatMsg.setSenderId(msg.getSenderId());
          chatMsg.setContent(msg.getContent());
          chatMsg.setTimestamp(msg.getTimestamp());
          return chatMsg;
        })
        .collect(Collectors.toList());
  }

  @MessageMapping("chats/{chatId}")
  @SendTo("/topic/chats/{chatId}")
  public ChatMessage onMessage(@DestinationVariable String chatId,
      @Payload ChatMessage message,
      @Header("session-id") String sessionId) {

    if (sessionId == null || !validateSession(sessionId)) {
      return null;
    }

    UUID sessionUuid = UUID.fromString(sessionId);
    Session session = sessionRepository.findById(sessionUuid).get();
    UUID userId = session.getUser().getId();
    String username = session.getUser().getUsername();
    UUID chatUuid = UUID.fromString(chatId);

    if (!chatRoomRepository.isUserParticipant(chatUuid, userId)) {
      return null;
    }

    chatRoomService.saveMessage(chatUuid, userId, message.getContent(), username);

    ChatMessage response = new ChatMessage();
    response.setSenderId(userId);
    response.setContent(message.getContent());
    return response;
  }

  private boolean validateSession(String sessionId) {
    try {
      UUID sessionUuid = UUID.fromString(sessionId);
      var sessionOpt = sessionRepository.findById(sessionUuid);
      if (sessionOpt.isEmpty()) {
        return false;
      }
      Session session = sessionOpt.get();
      return !session.isExpired();
    } catch (Exception e) {
      return false;
    }
  }
}
