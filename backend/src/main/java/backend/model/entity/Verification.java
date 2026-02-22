package backend.model.entity;

import java.time.LocalDateTime;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "verifications")
public class Verification {

  @Id
  @Column(name = "id", nullable = false, columnDefinition = "UUID DEFAULT gen_random_uuid()")
  private UUID id = UUID.randomUUID();

  @ManyToOne
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  @Column(name = "code", nullable = false)
  private int code;

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false, columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP + INTERVAL '24 hours'")
  private LocalDateTime expire_at = LocalDateTime.now();

  @Column(name = "expired", nullable = false)
  private boolean expired = false;

  public Verification(User user, int code) {
    this.user = user;
    this.code = code;
  }

  public Verification() {
  }

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public User getUser() {
    return user;
  }

  public void setUser(User user) {
    this.user = user;
  }

  public int getCode() {
    return code;
  }

  public void setCode(int code) {
    this.code = code;
  }

  public LocalDateTime getExpire_at() {
    return expire_at;
  }

  public void setExpire_at(LocalDateTime expire_at) {
    this.expire_at = expire_at;
  }

  public boolean isExpired() {
    return expired;
  }

  public void setExpired(boolean expired) {
    this.expired = expired;
  }

}
