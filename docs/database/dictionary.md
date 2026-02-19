# Feel Chat Database's Dictionary

## Tables

### Users

```sql
CREATE TABLE  users(
    id UUID PRIMARY KEY,
    email VARCHAR(320) UNIQUE,
    username VARCHAR(80) UNIQUE,
    password TEXT,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(60) NOT NULL,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL default FALSE
    verified BOOLEAN NOT NULL default FALSE
);
```

### User Sessions

```sql
CREATE TABLE user_sessions(
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    expire_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP + INTERVAL '30 days',

    FOREIGN KEY(user_id) REFERENCES users(id)
);
```

### Verifications

```sql
CREATE TABLE verifications(
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    code VARCHAR(6) NOT NULL,
    expire_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '15 minutes')

    FOREIGN KEY(user_id) REFERENCES users(id)
    )
```

### User Sessions

```sql
CREATE TABLE user_sessions(
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    session_id TEXT NOT NULL,
    expire TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL '30 days'),

    FOREIGN KEY(user_id) REFERENCES users(id)
)
```

### Chat Rooms

```sql
CREATE TABLE chat_rooms(
    id SERIAL PRIMARY KEY,
)
```

### User Chats

```sql
CREATE TABLE user_chats(
    user_id INT NOT NULL,
    chat_id INT NOT NULL,

    PRIMARY KEY(user_id,chat_id),

    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(chat_id) REFERENCES chat_rooms(id)
);
```

### Reports

```sql
CREATE TYPE report_type AS ENUM('spam','harassment','unkind')

CREATE TABLE reports(
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    chat_id INT NOT NULL,
    type report_type NOT NULL,
    description TEXT NOT NULL,

    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(chat_id) REFERENCES chat_rooms(id)
)
```
