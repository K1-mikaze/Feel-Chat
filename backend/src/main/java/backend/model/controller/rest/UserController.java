package backend.model.controller.rest;

import java.util.Optional;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import backend.model.entity.Session;
import backend.model.entity.User;
import backend.model.repository.SessionRepository;
import backend.model.repository.UserRepository;
import backend.model.service.UserService;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

  private final UserService userService;

  public UserController(UserService userService) {
    this.userService = userService;
  }

  @PostMapping("/save")
  public ResponseEntity<String> createUser(@RequestBody User user) {
    if (user.isEmpty()) {
      return ResponseEntity.badRequest().build();
    }

    if (userService.emailAlreadyExists(user.getEmail()) || userService.usernameAlreadyExists(user.getUsername())) {
      return ResponseEntity.status(HttpStatus.CONFLICT).body("Email or User already exists");
    }

    userService.saveUser(user, user.getPassword());
    return ResponseEntity.status(HttpStatus.CREATED).body("User created");
  }

  @PostMapping("/signin")
  public ResponseEntity<User> signIn(@RequestBody User user) {
    if (user.isLoginCredentialsEmpty()) {
      return ResponseEntity.badRequest().build();
    }
    var sessionOptional = userService.findUser(user.getEmail(), user.getPassword());
    if (sessionOptional.isPresent()) {
      Session session = sessionOptional.get();
      User userGotten = session.getUser();

      if (userGotten.isDeleted()) {
        return ResponseEntity.status(401).build();
      }

      return ResponseEntity.accepted().header("session-Id", session.getId().toString()).body(session.getUser());
    }
    return ResponseEntity.status(404).build();
  }

  @PatchMapping("/logout")
  public ResponseEntity<String> logout(@RequestHeader("session-id") UUID sessionId, @RequestBody User user) {

    var sessionOptional = userService.findSession(sessionId, user.getId());
    if (sessionOptional.isPresent()) {
      Session session = sessionOptional.get();
      session.setExpired(true);
      userService.expiredSession(session);
      return ResponseEntity.ok().build();
    }
    return ResponseEntity.status(404).build();
  }

  @PutMapping("/update")
  public ResponseEntity<String> update(@RequestHeader("session-id") UUID sessionId, @RequestBody User user) {

    var sessionOptional = userService.findSession(sessionId, user.getId());
    if (sessionOptional.isPresent()) {
      Session session = sessionOptional.get();
      User oldUser = session.getUser();
      if (session.isExpired()) {
        return ResponseEntity.status(401).build();
      }
      userService.UpdateUser(oldUser, user);
      return ResponseEntity.status(201).build();
    }
    return ResponseEntity.status(404).build();
  }

}
