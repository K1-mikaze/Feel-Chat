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

  public boolean expiredSession(UUID userId, UUID sessionId) {
    Optional<Session> sessionOptional = sessionRepository.findByIdAndUserId(sessionId, userId);

    if (sessionOptional.isPresent()) {
      Session session = sessionOptional.get();
      session.setExpired(true);
      sessionRepository.save(session);
      return true;
    }
    return false;
  }

  public boolean deleteUser(UUID userId, UUID sessionId) {
    Optional<Session> sessionOptional = sessionRepository.findByIdAndUserId(sessionId, userId);
    if (sessionOptional.isPresent()) {
      Session session = sessionOptional.get();
      User user = session.getUser();
      user.setDeleted(true);
      userRepository.save(user);
      return true;
    }
    return false;
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

  public int updateUserInformation(UUID sessionId, UUID userId, String city,
      String country) {
    Optional<Session> sessionOptional = sessionRepository.findByIdAndUserId(sessionId, userId);
    if (sessionOptional.isPresent()) {
      Session session = sessionOptional.get();
      if (!session.isExpired()) {
        User user = session.getUser();
        user.setCountry(country);
        user.setCity(city);
        userRepository.save(user);
        return 1;
      } else {
        return 2;
      }
    }
    return 0;
  }

  public int updateUserPassword(UUID userId, UUID sessionId, String newPassword, String oldPassword) {
    Optional<Session> sessionOptional = sessionRepository.findByIdAndUserId(sessionId, userId);
    if (sessionOptional.isPresent()) {
      Session session = sessionOptional.get();
      if (!session.isExpired()) {
        User user = session.getUser();
        if (passwordEncoder.matches(oldPassword, user.getPassword())) {
          user.setPassword(passwordEncoder.encode(newPassword));
          userRepository.save(user);
          return 1;
        } else {
          return 3;
        }
      } else {
        return 2;
      }
    }
    return 0;
  }

  public int updateUserUsername(UUID userId, UUID sessionId, String username) {
    Optional<Session> sessionOptional = sessionRepository.findByIdAndUserId(sessionId, userId);
    if (sessionOptional.isPresent()) {
      Session session = sessionOptional.get();
      if (!session.isExpired()) {
        User user = session.getUser();
        if (!usernameAlreadyExists(username)) {
          user.setUsername(username);
          userRepository.save(user);
          return 1;
        } else {
          return 3;
        }
      } else {
        return 2;
      }
    }
    return 0;
  }

  public Optional<User> getUser(UUID sessionId, UUID userId) {
    Optional<Session> sessionOptional = sessionRepository.findByIdAndUserId(sessionId, userId);
    Optional<User> userOptional = Optional.empty();
    if (sessionOptional.isPresent()) {
      userOptional = Optional.of(sessionOptional.get().getUser());

    }
    return userOptional;
  }

}
