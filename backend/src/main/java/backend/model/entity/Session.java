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
@Table(name = "user_sessions")
public class Session {

  @Id
  @Column(name = "id", nullable = false, columnDefinition = "UUID DEFAULT gen_random_uuid()")
  private UUID id = UUID.randomUUID();

  @Column(name = "expire_at", nullable = false, updatable = false, insertable = false, columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP + INTERVAL '30 days'")
  private LocalDateTime expire_at;

  @Column(name = "expired", nullable = false, columnDefinition = "BOOLEAN DEFAULT false")
  private boolean expired = false;

  @ManyToOne
  @JoinColumn(name = "user_id", nullable = false)
  private User user;

  public Session() {
  }

  public Session(UUID id, LocalDateTime expire_at, boolean expired, User user) {
    this.id = id;
    this.expire_at = expire_at;
    this.expired = expired;
    this.user = user;
  }

  public Session(User user) {
    this.user = user;
  }

  public UUID getId() {
    return id;
  }

  public void setId(UUID id) {
    this.id = id;
  }

  public LocalDateTime getExpire_at() {
    return expire_at;
  }

  public void setExpire_at(LocalDateTime expire_at) {
    this.expire_at = expire_at;
  }

  public User getUser() {
    return user;
  }

  public void setUser(User user) {
    this.user = user;
  }

  public boolean isExpired() {
    return expired;
  }

  public void setExpired(boolean expired) {
    this.expired = expired;
  }

}
