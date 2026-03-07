# WebSocket API Documentation

## Overview

Real-time chat messaging using STOMP over WebSocket.

## Connection

- **Endpoint**: `http://localhost:8080/ws`
- **Protocol**: STOMP over SockJS (with fallback to raw WebSocket)
- **Authentication**: All messages require `session-id` header

---

## REST API - Chat Rooms

### Find or Create Chat

- **URL**: `POST /api/v1/chats/findchat`
- **Header**: `session-id: uuid`
- **Body**:

```json
{
  "user_id": "uuid-of-current-user",
  "contact_id": "uuid-of-other-user"
}
```

- **Response**: `200 OK` with chatId

### Get User Chats

- **URL**: `GET /api/v1/chats`
- **Header**: `session-id: uuid`
- **Response**:

```json
[
  {
    "chatId": "uuid-1",
    "otherParticipant": { "id": "uuid-2", "username": "john" },
    "latestMessage": {
      "content": "Hey!",
      "timestamp": "2024-01-15T10:30:00",
      "senderId": "uuid-2"
    }
  }
]
```

---

## WebSocket Connection & Usage

### Step 1: Connect to WebSocket

```javascript
const socket = new SockJS("/ws");
const stompClient = Stomp.over(socket);

const sessionId = "your-session-uuid"; // Get this from login

stompClient.connect(
  {},  // headers (empty for connect)
  () => {
    console.log("Connected to WebSocket!");
    
    // Step 2: Subscribe to chat topics
  },
  (error) => console.error("Connection error:", error)
);
```

### Step 2: Subscribe to Chat Messages

Subscribe to receive chat history and new messages:

```
SUBSCRIBE
destination: /app/chats/{chatId}
```

**Headers:**
- `session-id`: User's session UUID (required)

**What happens:**
1. Server returns chat history (previous messages)
2. Client is auto-subscribed to `/topic/chats/{chatId}` for new messages

Example (JavaScript):

```javascript
const chatId = "chat-uuid-here";

stompClient.subscribe(
  `/app/chats/${chatId}`,
  (message) => {
    const msg = JSON.parse(message.body);
    console.log("Received:", msg);
    // First call: array of previous messages
    // Subsequent calls: new messages
    // { senderId, username, content, timestamp }
  },
  { "session-id": sessionId }
);
```

### Step 3: Send Message

```
SEND
destination: /app/chats/{chatId}
```

**Headers:**
- `session-id`: User's session UUID (required)

**Body:**

```json
{
  "content": "Hello!"
}
```

Example (JavaScript):

```javascript
stompClient.send(
  `/app/chats/${chatId}`,
  { "session-id": sessionId },
  JSON.stringify({ content: "Hello!" })
);
```

The server validates:
1. Session exists and is not expired
2. User is a participant in the chat room

---

## How Subscription Works

### Subscribe to `/app/chats/{chatId}`

When you subscribe to `/app/chats/{chatId}`:

1. **Chat History**: Server returns previous messages for that chat (via `@SubscribeMapping`)
2. **New Messages**: When you send a message, it's broadcast back to the same subscription (via `@SendTo`)

### Response Format

**First message (Chat History):**
```json
[
  { "senderId": "...", "username": "john", "content": "Hi!", "timestamp": "..." },
  { "senderId": "...", "username": "jane", "content": "Hello!", "timestamp": "..." }
]
```

**After sending a message (Broadcast):**
```json
{ "senderId": "...", "username": "john", "content": "My message", "timestamp": "..." }
```

### Single Subscription Flow

```
Client SUBSCRIBE /app/chats/{chatId}
         <-- Chat History

Client SEND /app/chats/{chatId} (with content)
         <-- Message broadcasted back (includes senderId, username, content, timestamp)
```

---

## Message Format

### Outgoing (to server)

```json
{
  "content": "message text"
}
```

### Incoming (from server)

```json
{
  "senderId": "uuid-string",
  "username": "john",
  "content": "message text",
  "timestamp": "2024-01-15T10:30:00"
}
```

---

## WhatsApp-Style Chat List Flow

### Step 1: Login (get session-id)

```javascript
// Login via REST API to get session-id
fetch("/api/v1/auth/login", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    email: "user@example.com",
    password: "password"
  })
})
  .then((res) => res.json())
  .then((data) => {
    const sessionId = data.sessionId; // Save this!
  });
```

### Step 2: Find or Create Chat

```javascript
fetch("/api/v1/chats/findchat", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "session-id": sessionId,
  },
  body: JSON.stringify({
    user_id: "my-user-uuid",
    contact_id: "contact-user-uuid",
  }),
})
  .then((res) => res.json())
  .then((chatId) => {
    console.log("Chat ID:", chatId);
  });
```

### Step 3: Get Chat List

```javascript
fetch("/api/v1/chats", {
  headers: { "session-id": sessionId },
})
  .then((res) => res.json())
  .then((chats) => {
    console.log(chats);
    // [
    //   {
    //     chatId: "uuid-1",
    //     otherParticipant: { id: "uuid-2", username: "john" },
    //     latestMessage: { content: "Hey!", timestamp: "...", senderId: "uuid-2" }
    //   }
    // ]
  });
```

### Step 4: Connect to WebSocket & Subscribe

```javascript
const socket = new SockJS("/ws");
const stompClient = Stomp.over(socket);

stompClient.connect({}, () => {
  console.log("Connected to WebSocket");

  // Subscribe to each chat
  chats.forEach((chat) => {
    stompClient.subscribe(
      `/app/chats/${chat.chatId}`,
      (msg) => {
        const message = JSON.parse(msg.body);
        console.log("Received:", message);
        // First call: array of previous messages (may be single object or array)
        // Subsequent calls: new message objects
        // { senderId, username, content, timestamp }
      },
      { "session-id": sessionId }
    );
  });
}, (error) => {
  console.error("WebSocket connection error:", error);
});
```

### Step 5: Send Messages

```javascript
const chatId = "chat-uuid";

stompClient.send(
  `/app/chats/${chatId}`,
  { "session-id": sessionId },
  JSON.stringify({ content: "Hello!" })
);
```

---

## Full Client Example

```javascript
// Configuration
const sessionId = "your-session-uuid"; // From login
const socket = new SockJS("/ws");
const stompClient = Stomp.over(socket);

// Connect
stompClient.connect({}, () => {
  console.log("Connected to WebSocket");

  // Get chat list via REST
  fetch("/api/v1/chats", {
    headers: { "session-id": sessionId },
  })
    .then((res) => res.json())
    .then((chats) => {
      // Subscribe to each chat
      chats.forEach((chat) => {
        // Receive chat history and new messages
        stompClient.subscribe(
          `/app/chats/${chat.chatId}`,
          (msg) => {
            const message = JSON.parse(msg.body);
            console.log("Received:", message);
            // First call: array of previous messages (may be single object or array)
            // Subsequent calls: new message objects
            // { senderId, username, content, timestamp }
          },
          { "session-id": sessionId }
        );
      });
    });

  // Send message function
  function sendMessage(chatId, content) {
    stompClient.send(
      `/app/chats/${chatId}`,
      { "session-id": sessionId },
      JSON.stringify({ content: content })
    );
  }

  // Example: Send message
  // sendMessage("chat-uuid", "Hello!");

}, (error) => {
  console.error("WebSocket connection error:", error);
});
```

---

## Validation

The WebSocket endpoint validates:

1. **Session exists**: The `session-id` must correspond to an existing session
2. **Session not expired**: The session must not be marked as expired
3. **User is participant**: The user must be a member of the chat room

If any validation fails, the message is ignored.

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Invalid session-id | Message ignored |
| Expired session | Message ignored |
| User not in chat | Message ignored |
| Invalid chatId | Message ignored |

