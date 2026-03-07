package backend.model.service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;
import backend.model.entity.ChatMessage;
import backend.model.entity.ChatRoom;
import backend.model.entity.User;
import backend.model.entity.data.ChatRoomResponse;
import backend.model.repository.ChatMessageRepository;
import backend.model.repository.ChatRoomRepository;
import backend.model.repository.UserRepository;

@Service
public class ChatRoomService {

  final private ChatRoomRepository chatRoomRepository;
  final private UserRepository userRepository;
  final private ChatMessageRepository messageRepository;

  public ChatRoomService(ChatRoomRepository chatRoomRepository, UserRepository userRepository,
      ChatMessageRepository messageRepository, SimpMessagingTemplate messagingTemplate) {
    this.chatRoomRepository = chatRoomRepository;
    this.userRepository = userRepository;
    this.messageRepository = messageRepository;
  }

  public List<ChatRoomResponse> getChatRoomsWithLatestMessage(UUID userId) {
    List<ChatRoom> chatRooms = chatRoomRepository.findByUsers_Id(userId);
    List<ChatRoomResponse> responses = new ArrayList<>();

    for (ChatRoom chatRoom : chatRooms) {
      Set<User> users = chatRoom.getUsers();
      User otherParticipantUser = new User();
      for (User user : users) {
        if (!user.getId().equals(userId)) {
          otherParticipantUser = user;
          break;
        }
      }
      Optional<ChatMessage> latestMessage = messageRepository.findTopByChatRoomIdOrderByTimestampDesc(chatRoom.getId());
      if (latestMessage.isPresent()) {
        ChatMessage message = latestMessage.get();
        ChatRoomResponse response = new ChatRoomResponse(chatRoom.getId(), otherParticipantUser, message);
        responses.add(response);
      }
    }

    return responses;
  }

  @Transactional
  public ChatMessage saveMessage(UUID chatRoomId, UUID senderId, String content, String username) {
    ChatMessage message = new ChatMessage(chatRoomId, senderId, content);
    message = messageRepository.save(message);
    message.setTimestamp(LocalDateTime.now());

    return message;
  }

  @Transactional
  public void addUserToChatRoomIfNotExists(UUID chatId, UUID userId) {
    Optional<ChatRoom> chatRoomOpt = chatRoomRepository.findById(chatId);
    Optional<User> userOpt = userRepository.findById(userId);

    if (chatRoomOpt.isPresent() && userOpt.isPresent()) {
      ChatRoom chatRoom = chatRoomOpt.get();
      User user = userOpt.get();

      if (!chatRoom.getUsers().contains(user)) {
        chatRoom.getUsers().add(user);
        chatRoomRepository.save(chatRoom);
      }
    }
  }

  public Optional<UUID> createRoom(UUID userIdOne, UUID userIdTwo) {
    Optional<User> userOneOptional = userRepository.findById(userIdOne);
    Optional<User> userTwoOptional = userRepository.findById(userIdTwo);
    Optional<UUID> uuid = Optional.empty();

    if (userOneOptional.isPresent() && userTwoOptional.isPresent()) {
      User userOne = userOneOptional.get();
      User userTwo = userTwoOptional.get();

      HashSet<User> users = new HashSet<>();
      users.add(userOne);
      users.add(userTwo);
      ChatRoom chatRoom = new ChatRoom(users);
      uuid = Optional.of(chatRoom.getId());
    }

    return uuid;
  }

  @Transactional
  public UUID findOrCreateChatRoom(UUID userId, UUID contactId) {
    if (!userRepository.existsById(userId) || !userRepository.existsById(contactId)) {
      return null;
    }

    Optional<ChatRoom> existing = chatRoomRepository.findByParticipants(userId, contactId);
    if (existing.isPresent()) {
      return existing.get().getId();
    }

    Optional<User> userOne = userRepository.findById(userId);
    Optional<User> userTwo = userRepository.findById(contactId);

    if (userOne.isPresent() && userTwo.isPresent()) {
      HashSet<User> users = new HashSet<>();
      users.add(userOne.get());
      users.add(userTwo.get());
      ChatRoom chatRoom = new ChatRoom(users);
      chatRoomRepository.save(chatRoom);
      return chatRoom.getId();
    }

    return null;
  }

  @Transactional
  public boolean deleteChatRoom(UUID chatId, UUID userId) {
    Optional<ChatRoom> chatRoomOpt = chatRoomRepository.findById(chatId);

    if (chatRoomOpt.isEmpty()) {
      return false;
    }

    ChatRoom chatRoom = chatRoomOpt.get();
    if (!chatRoomRepository.isUserParticipant(chatId, userId)) {
      return false;
    }

    messageRepository.deleteByChatRoomId(chatId);
    chatRoomRepository.delete(chatRoom);

    return true;
  }
}
