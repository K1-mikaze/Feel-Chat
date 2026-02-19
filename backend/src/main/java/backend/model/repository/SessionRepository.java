package backend.model.repository;

import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import backend.model.entity.Session;

@Repository
public interface SessionRepository extends JpaRepository<Session, UUID> {

  Optional<Session> findByIdAndUserId(UUID id, UUID userId);

}
