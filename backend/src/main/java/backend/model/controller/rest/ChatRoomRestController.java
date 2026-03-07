package backend.model.controller.rest;

import java.util.List;
import java.util.UUID;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import backend.model.entity.Session;
import backend.model.entity.data.ChatRoomResponse;
import backend.model.repository.SessionRepository;
import backend.model.service.ChatRoomService;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/api/v1/chats")
public class ChatRoomRestController {

  private final ChatRoomService chatRoomService;
  private final SessionRepository sessionRepository;

  public ChatRoomRestController(ChatRoomService chatRoomService, SessionRepository sessionRepository) {
    this.chatRoomService = chatRoomService;
    this.sessionRepository = sessionRepository;
  }

  @GetMapping
  public ResponseEntity<List<ChatRoomResponse>> getUserChats(
      @RequestHeader("session-id") String sessionId) {
    try {
      UUID sessionUuid = UUID.fromString(sessionId);
      var sessionOptional = sessionRepository.findById(sessionUuid);

      if (sessionOptional.isEmpty()) {
        return ResponseEntity.status(401).build();
      }

      Session session = sessionOptional.get();
      if (session.isExpired()) {
        return ResponseEntity.status(401).build();
      }

      List<ChatRoomResponse> chats = chatRoomService.getChatRoomsWithLatestMessage(session.getUser().getId());
      return ResponseEntity.ok(chats);

    } catch (Exception e) {
      return ResponseEntity.badRequest().build();
    }
  }

  @PostMapping("/findchat")
  public ResponseEntity<UUID> findOrCreateChatRoom(@RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      UUID userId = UUID.fromString(jsonNode.get("user_id").asString());
      UUID contactId = UUID.fromString(jsonNode.get("contact_id").asString());

      UUID chatId = chatRoomService.findOrCreateChatRoom(userId, contactId);

      if (chatId == null) {
        return ResponseEntity.notFound().build();
      }
      return ResponseEntity.ok(chatId);

    } catch (Exception e) {
      System.out.println(e);
      return ResponseEntity.badRequest().build();
    }
  }

  @DeleteMapping
  public ResponseEntity<Void> deleteChat(
      @RequestHeader("session-id") String sessionId,
      @RequestBody String body) {
    try {
      UUID sessionUuid = UUID.fromString(sessionId);
      var sessionOptional = sessionRepository.findById(sessionUuid);

      if (sessionOptional.isEmpty()) {
        return ResponseEntity.status(401).build();
      }

      Session session = sessionOptional.get();
      if (session.isExpired()) {
        return ResponseEntity.status(401).build();
      }

      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);
      UUID chatId = UUID.fromString(jsonNode.get("chat_id").asString());

      UUID userId = session.getUser().getId();
      boolean deleted = chatRoomService.deleteChatRoom(chatId, userId);

      if (deleted) {
        return ResponseEntity.ok().build();
      }
      return ResponseEntity.notFound().build();

    } catch (Exception e) {
      return ResponseEntity.badRequest().build();
    }
  }
}
