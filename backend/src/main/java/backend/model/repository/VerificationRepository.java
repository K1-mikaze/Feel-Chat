package backend.model.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.model.entity.Verification;

@Repository
public interface VerificationRepository extends JpaRepository<Verification, UUID> {

  Optional<Verification> findByCodeAndUserId(int code, UUID userId);

}
