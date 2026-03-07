package backend.model.controller.rest;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import backend.model.entity.User;
import backend.model.service.AdministratorService;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/api/v1/admin")
public class AdministratorController {

  private final AdministratorService administratorService;

  public AdministratorController(AdministratorService administratorService) {
    this.administratorService = administratorService;
  }

  @DeleteMapping("/users")
  public ResponseEntity<String> deleteUser(@RequestHeader("session-id") String sessionId, @RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      UUID userId = UUID.fromString(jsonNode.get("user_id").asString());
      UUID deleteId = UUID.fromString(jsonNode.get("delete_id").asString());
      UUID sessionUUID = UUID.fromString(sessionId);

      if (administratorService.deleteUser(sessionUUID, userId, deleteId)) {
        return ResponseEntity.ok().build();
      }
      return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    } catch (Exception e) {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
    }
  }

  @PutMapping("/users")
  public ResponseEntity<String> updateUser(@RequestHeader("session-id") String sessionId, @RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      UUID userId = UUID.fromString(jsonNode.get("user_id").asString());
      UUID sessionUUID = UUID.fromString(sessionId);

      User updatedUser = new User();

      updatedUser.setPassword(jsonNode.get("password").asString());
      updatedUser.setId(UUID.fromString(jsonNode.get("id").asString()));
      updatedUser.setUsername(jsonNode.get("username").asString());
      updatedUser.setCity(jsonNode.get("city").asString());
      updatedUser.setCountry(jsonNode.get("country").asString());
      updatedUser.setDeleted(jsonNode.get("deleted").asBoolean());
      updatedUser.setVerified(jsonNode.get("verified").asBoolean());

      if (administratorService.updateUser(sessionUUID, userId, updatedUser)) {
        return ResponseEntity.ok().build();
      }
      return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    } catch (Exception e) {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
    }
  }

  @PostMapping("/users")
  public ResponseEntity<List<User>> getAllUsers(
      @RequestHeader("session-id") String sessionId,
      @RequestParam(value = "includeDeleted", defaultValue = "false") boolean includeDeleted,
      @RequestBody String body) {
    try {
      ObjectMapper mapper = new ObjectMapper();
      JsonNode jsonNode = mapper.readTree(body);

      UUID userId = UUID.fromString(jsonNode.get("user_id").asString());
      UUID sessionUUID = UUID.fromString(sessionId);

      List<User> users = administratorService.getAllUsers(sessionUUID, userId, includeDeleted);
      if (users == null) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
      }
      return ResponseEntity.ok().body(users);
    } catch (Exception e) {
      return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
    }
  }

}
