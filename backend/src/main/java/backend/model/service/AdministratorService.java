package backend.model.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import backend.model.entity.Session;
import backend.model.entity.User;
import backend.model.repository.SessionRepository;
import backend.model.repository.UserRepository;
import jakarta.transaction.Transactional;

@Service
public class AdministratorService {

  private final PasswordEncoder passwordEncoder;
  private final SessionRepository sessionRepository;
  private final UserRepository userRepository;

  public AdministratorService(SessionRepository sessionRepository, UserRepository userRepository,
      PasswordEncoder passwordEncoder) {
    this.sessionRepository = sessionRepository;
    this.userRepository = userRepository;
    this.passwordEncoder = passwordEncoder;
  }

  private boolean isAdminWithValidSession(UUID sessionId, UUID userId) {
    Optional<Session> sessionOptional = sessionRepository.findByIdAndUserId(sessionId, userId);
    if (sessionOptional.isEmpty()) {
      return false;
    }
    Session session = sessionOptional.get();
    if (session.isExpired()) {
      return false;
    }
    User user = session.getUser();
    return user.isAdministrator();
  }

  @Transactional
  public boolean deleteUser(UUID sessionId, UUID userId, UUID deleteId) {
    if (!isAdminWithValidSession(sessionId, userId)) {
      return false;
    }
    Optional<User> userOptional = userRepository.findById(deleteId);
    if (userOptional.isEmpty()) {
      return false;
    }
    User userToDelete = userOptional.get();
    if (userToDelete.isDeleted()) {
      return false;
    }
    userToDelete.setDeleted(true);
    userRepository.save(userToDelete);
    return true;
  }

  @Transactional
  public boolean updateUser(UUID sessionId, UUID userId, User updatedUser) {
    if (!isAdminWithValidSession(sessionId, userId)) {
      return false;
    }
    Optional<User> userOptional = userRepository.findById(updatedUser.getId());
    if (userOptional.isEmpty()) {
      return false;
    }
    User existingUser = userOptional.get();
    existingUser.setEmail(updatedUser.getEmail());
    existingUser.setUsername(updatedUser.getUsername());
    existingUser.setPassword(passwordEncoder.encode(updatedUser.getPassword()));
    existingUser.setCity(updatedUser.getCity());
    existingUser.setCountry(updatedUser.getCountry());
    userRepository.save(existingUser);
    return true;
  }

  public List<User> getAllUsers(UUID sessionId, UUID userId, boolean includeDeleted) {
    if (!isAdminWithValidSession(sessionId, userId)) {
      return null;
    }
    List<User> users = userRepository.findAll();
    if (!includeDeleted) {
      return users.stream()
          .filter(user -> !user.isDeleted())
          .toList();
    }
    return users;
  }

}
