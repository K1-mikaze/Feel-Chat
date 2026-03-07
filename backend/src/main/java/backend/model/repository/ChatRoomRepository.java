package backend.model.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import backend.model.entity.ChatRoom;

@Repository
public interface ChatRoomRepository extends JpaRepository<ChatRoom, UUID> {

  List<ChatRoom> findByUsers_Id(UUID userId);

  boolean existsByUsers_Id(UUID userId);

  @Query("SELECT cr FROM ChatRoom cr JOIN cr.users u1 JOIN cr.users u2 WHERE u1.id = :userId AND u2.id = :contactId")
  Optional<ChatRoom> findByParticipants(@Param("userId") UUID userId, @Param("contactId") UUID contactId);

  @Query("SELECT CASE WHEN COUNT(cr) > 0 THEN true ELSE false END FROM ChatRoom cr JOIN cr.users u WHERE cr.id = :chatRoomId AND u.id = :userId")
  boolean isUserParticipant(@Param("chatRoomId") UUID chatRoomId, @Param("userId") UUID userId);
}
