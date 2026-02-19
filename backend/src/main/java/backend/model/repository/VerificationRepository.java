package backend.model.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import backend.model.entity.Verification;

@Repository
public interface VerificationRepository extends JpaRepository<Verification, Long> {

}
