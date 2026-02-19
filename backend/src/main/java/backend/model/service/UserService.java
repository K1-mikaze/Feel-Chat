package backend.model.service;

import org.springframework.stereotype.Service;

import backend.model.entity.Session;
import backend.model.entity.User;

import java.util.Optional;
import java.util.UUID;

import org.springframework.security.crypto.password.PasswordEncoder;

import backend.model.repository.SessionRepository;
import backend.model.repository.UserRepository;
import jakarta.transaction.Transactional;

@Service
public class UserService {

  private final PasswordEncoder passwordEncoder;

  private final UserRepository userRepository;
  private final SessionRepository sessionRepository;

  public UserService(UserRepository userRepository, SessionRepository sessionRepository,
      PasswordEncoder passwordEncoder) {
    this.userRepository = userRepository;
    this.sessionRepository = sessionRepository;
    this.passwordEncoder = passwordEncoder;
  }

  @Transactional
  public void saveUser(User user, String rawPassword) {
    String hashedPassword = passwordEncoder.encode(rawPassword);
    user.setPassword(hashedPassword);
    userRepository.save(user);
  }

  public boolean emailAlreadyExists(String email) {
    return userRepository.existsByEmail(email);
  }

  public boolean usernameAlreadyExists(String username) {
    return userRepository.existsByUsername(username);
  }

  public Session expiredSession(Session session) {
    return sessionRepository.save(session);
  }

  public Optional<Session> findUser(String email, String rawPassword) {
    Optional<User> userOptional = userRepository.findByEmail(email);
    Optional<Session> sessionOptional = Optional.empty();
    if (userOptional.isPresent()) {
      User user = userOptional.get();
      if (passwordEncoder.matches(rawPassword, user.getPassword())) {

        Session session = new Session(user);

        sessionRepository.save(session);
        sessionOptional = Optional.of(session);
      }
    }
    return sessionOptional;
  }

  public Optional<Session> findSession(UUID sessionId, UUID userId) {
    return sessionRepository.findByIdAndUserId(sessionId, userId);
  }

  public User UpdateUser(User OldUser, User newUser) {
    if (!OldUser.getPassword().equals(newUser.getPassword())) {
      OldUser.setPassword(passwordEncoder.encode(newUser.getPassword()));
    }
    if (!OldUser.getUsername().equalsIgnoreCase(newUser.getUsername())) {
      String newUsername = newUser.getUsername();
      if (!userRepository.existsByUsername(newUsername)) {
        OldUser.setUsername(newUsername);
      }
    }
    OldUser.setDeleted(newUser.isDeleted());
    OldUser.setCountry(newUser.getCountry());
    OldUser.setCity(newUser.getCity());

    return userRepository.save(OldUser);
  }
}
