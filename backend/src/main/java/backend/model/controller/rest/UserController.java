package backend.model.controller.rest;

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
import backend.model.service.UserService;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

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

      return ResponseEntity.accepted().header("session-Id", session.getId().toString()).body(userGotten);
    }
    return ResponseEntity.status(404).build();
  }

  @PatchMapping("/logout")
  public ResponseEntity<String> logout(@RequestHeader("session-id") String sessionId, @RequestBody String user_id) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(user_id);
      if (userService.expiredSession(UUID.fromString(jsonNode.get("user_id").asString()),
          UUID.fromString(sessionId))) {
        return ResponseEntity.ok().build();
      }
      return ResponseEntity.status(404).build();
    } catch (Exception e) {
      return ResponseEntity.status(400).build();
    }
  }

  @PatchMapping("/delete")
  public ResponseEntity<String> delete(@RequestHeader("session-id") String sessionId, @RequestBody String user_id) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(user_id);

      if (userService.deleteUser(UUID.fromString(jsonNode.get("user_id").asString()), UUID.fromString(sessionId))) {
        return ResponseEntity.ok().build();
      } else {
        return ResponseEntity.status(404).build();
      }
    } catch (Exception e) {
      return ResponseEntity.status(400).build();
    }
  }

  @PatchMapping("/updatepassword")
  public ResponseEntity<String> updatePassword(@RequestHeader("session-id") String sessionId,
      @RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      switch (userService.updateUserPassword(UUID.fromString(jsonNode.get("user_id").asString()),
          UUID.fromString(sessionId), jsonNode.get("new_password").asString(),
          jsonNode.get("old_password").asString())) {
        case 0:
          return ResponseEntity.status(404).build();
        case 1:
          return ResponseEntity.status(201).build();
        case 2:
          return ResponseEntity.status(401).build();
        case 3:
          return ResponseEntity.status(409).build();
        default:
          return ResponseEntity.status(500).build();
      }
    } catch (Exception e) {
      return ResponseEntity.status(400).build();
    }
  }

  @PatchMapping("/forgotpassword")
  public ResponseEntity<String> forgotPassword(@RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      switch (userService.changePasswordWithVerificationCode(jsonNode.get("email").asString(),
          jsonNode.get("code").asInt(), jsonNode.get("password").asString())) {
        case 0:
          return ResponseEntity.status(404).build();
        case 1:
          return ResponseEntity.status(201).build();
        case 2:
          return ResponseEntity.status(409).build();
        default:
          return ResponseEntity.status(500).build();
      }
    } catch (Exception e) {
      return ResponseEntity.status(400).build();
    }
  }

  @PatchMapping("/updateusername")
  public ResponseEntity<String> updateUsername(@RequestHeader("session-id") String sessionId,
      @RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      switch (userService.updateUserUsername(UUID.fromString(jsonNode.get("user_id").asString()),
          UUID.fromString(sessionId), jsonNode.get("username").asString())) {
        case 0:
          return ResponseEntity.status(404).build();
        case 1:
          return ResponseEntity.status(201).build();
        case 2:
          return ResponseEntity.status(401).build();
        case 3:
          return ResponseEntity.status(409).build();
        default:
          return ResponseEntity.status(500).build();
      }
    } catch (Exception e) {
      return ResponseEntity.status(400).build();
    }
  }

  @PostMapping("/getuser")
  public ResponseEntity<User> updatedInfo(@RequestHeader("session-id") String sessionId, @RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      var userOptional = userService.getUser(UUID.fromString(sessionId),
          UUID.fromString(jsonNode.get("user_id").asString()));
      if (userOptional.isPresent()) {
        return ResponseEntity.status(200).body(userOptional.get());
      }
      return ResponseEntity.status(404).build();
    } catch (Exception e) {
      System.out.println("Exception:\n" + e);
      return ResponseEntity.status(400).build();
    }

  }

  @PostMapping("/sendemail")
  public ResponseEntity<Void> sendEmail(@RequestHeader("session-id") String sessionId, @RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      if (userService.createVerificationCodeBySessionAndUser(UUID.fromString(sessionId),
          UUID.fromString(jsonNode.get("user_id").asString()))) {
        return ResponseEntity.ok().build();
      }
      return ResponseEntity.status(400).build();

    } catch (Exception e) {
      System.out.println(e);
      return ResponseEntity.status(500).build();
    }

  }

  @PostMapping("/sendemail2")
  public ResponseEntity<Void> sendEmail(@RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      if (userService.createVerificationCodeByEmail(jsonNode.get("email").asString())) {
        return ResponseEntity.ok().build();
      }
      return ResponseEntity.status(400).build();

    } catch (Exception e) {
      System.out.println(e);
      return ResponseEntity.status(500).build();
    }

  }

  @PostMapping("/verifyemail")
  public ResponseEntity<Void> verifyEmail(@RequestHeader("session-id") String sessionId, @RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      if (userService.verifyUserEmail(UUID.fromString(sessionId),
          UUID.fromString(jsonNode.get("user_id").asString()), jsonNode.get("code").asInt())) {
        return ResponseEntity.ok().build();
      }
      return ResponseEntity.status(404).build();

    } catch (Exception e) {
      System.out.println(e);
      return ResponseEntity.status(500).build();
    }

  }

  @PutMapping("/updateinformation")
  public ResponseEntity<User> updateInformation(@RequestHeader("session-id") String sessionId,
      @RequestBody String body) {

    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      switch (userService.updateUserInformation(UUID.fromString(sessionId),
          UUID.fromString(jsonNode.get("user_id").asString()), jsonNode.get("city").asString(),
          jsonNode.get("country").asString(), jsonNode.get("mood").asString())) {
        case 0:
          return ResponseEntity.status(404).build();
        case 1:
          return ResponseEntity.status(201).build();
        case 2:
          return ResponseEntity.status(401).build();
        default:
          return ResponseEntity.status(500).build();
      }

    } catch (Exception e) {
      System.out.println("Exception:\n" + e);
      return ResponseEntity.status(400).build();
    }
  }

}
