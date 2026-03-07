package backend.model.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.model.entity.ChatMessage;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, UUID> {

  Optional<ChatMessage> findTopByChatRoomIdOrderByTimestampDesc(UUID chatRoomId);

  List<ChatMessage> findTop1ByChatRoomIdOrderByTimestampDesc(UUID chatRoomId);

  List<ChatMessage> findByChatRoomIdOrderByTimestampDesc(UUID chatRoomId);

  List<ChatMessage> findByChatRoomIdOrderByTimestampAsc(UUID chatRoomId);

  void deleteByChatRoomId(UUID chatRoomId);
}
