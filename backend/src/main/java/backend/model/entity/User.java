package backend.model.entity;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

@Entity
@Table(name = "users")
public class User {

  @Id
  @Column(name = "id", nullable = false, columnDefinition = "UUID DEFAULT gen_random_uuid()")
  private UUID id = UUID.randomUUID();

  @Column(name = "email", nullable = false, unique = true, length = 320)
  private String email = "";

  @Column(name = "username", nullable = false, unique = true, length = 80)
  private String username = "";

  @Column(name = "password", nullable = false, length = 60)
  private String password = "";

  @Column(name = "city", length = 100, nullable = false)
  private String city = "";

  @Column(name = "country", length = 60, nullable = false)
  private String country = "";

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false, columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
  private LocalDateTime created_at = LocalDateTime.now();

  @Column(name = "deleted", nullable = false, columnDefinition = "BOOLEAN DEFAULT FALSE")
  private boolean deleted = false;

  @Column(name = "verified", nullable = false, columnDefinition = "BOOLEAN DEFAULT FALSE")
  private boolean verified = false;

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
  private Set<Session> sessions = new HashSet<>();

  @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
  private Set<Session> verifications = new HashSet<>();

  public User() {
  }

  public User(UUID id, String email, String username, String password, String city, String country,
      LocalDateTime created_at, boolean deleted, boolean verified) {
    this.id = id;
    this.email = email;
    this.username = username;
    this.password = password;
    this.city = city;
    this.country = country;
    this.created_at = created_at;
    this.deleted = deleted;
    this.verified = verified;
  }

  public User(String email, String username, String password, String city, String country) {
    this.email = email;
    this.username = username;
    this.password = password;
    this.city = city;
    this.country = country;
  }

  public User(UUID id, String email, String username, String password, String city, String country) {
    this.id = id;
    this.email = email;
    this.username = username;
    this.password = password;
    this.city = city;
    this.country = country;
  }

  public User(String email, String password) {
    this.email = email;
    this.password = password;
  }

  public User(UUID id) {
    this.id = id;
  }

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public String getEmail() {
    return email;
  }

  public void setEmail(String email) {
    this.email = email;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public String getPassword() {
    return password;
  }

  public void setPassword(String password) {
    this.password = password;
  }

  public String getCity() {
    return city;
  }

  public void setCity(String city) {
    this.city = city;
  }

  public String getCountry() {
    return country;
  }

  public void setCountry(String country) {
    this.country = country;
  }

  public LocalDateTime getCreated_at() {
    return created_at;
  }

  public void setCreated_at(LocalDateTime created_at) {
    this.created_at = created_at;
  }

  public boolean isDeleted() {
    return deleted;
  }

  public void setDeleted(boolean deleted) {
    this.deleted = deleted;
  }

  // return false if any variable of the object is empty
  public boolean isEmpty() {
    return email.trim().isEmpty() &&
        password.trim().isEmpty() &&
        username.trim().isEmpty() &&
        city.trim().isEmpty() &&
        country.trim().isEmpty();
  }

  public boolean isLoginCredentialsEmpty() {
    return email.trim().isEmpty() && password.trim().isEmpty();
  }

  @Override
  public String toString() {
    return "User:\nId:" + id.toString() + "\nemail: " + email + "\npassword: " + password + "\nusername: " + username
        + "\ncity: " + city
        + "\ncountry: " + country;
  }

}
