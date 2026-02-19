# REST Endpoints for the API

## User Management

Path: `/api/v1/users`

### Create User

This endpoint must create a new user in the Database.

Mapping: `/save`
**Type:** POST
**Parameters:**
| Type | Object | Lenght |
|--------------- | --------------- |--------------- |
| String | Email | => 7 and <= 320 |
| String | Password | => 6 |
| String | Username | => 3 and <= 50 |
| String | Country | > 5 and < 60 |
| String | City | > 3 and < 100|

- If user created returns 201
- If email or username already exist returns 409
- If bad request like not all the requirements meet return 400

### Update User Information

This endpoints is use for updating users information

**Type:** PUT
**Parameters:**

Header: **session-id** : e1e13e1dsfat3t2ge

| Type    | Object   | Lenght          |
| ------- | -------- | --------------- |
| String  | id       | => 7 and <= 320 |
| String  | email    | => 7 and <= 320 |
| String  | password | => 6            |
| String  | username | => 3 and <= 50  |
| String  | country  | > 5 and < 60    |
| String  | city     | > 3 and < 100   |
| boolean | deleted  |                 |

- Returns 201 if everything Ok and something was updated
- Returns 401 if session is Expired
- Returns 404 if User and Session not found

### Log Into an Account

This endpoint will let the user log into his account

**Type:** POST
**Parameters: **

| Type   | Object   | Lenght          |
| ------ | -------- | --------------- |
| String | Email    | => 7 and <= 320 |
| String | Password | => 6            |

- Returns 202 if accepted
- Returns 400 if not arguments given
- Returns 401 if users is deleted
- Returns 404 if user nos found

```javascript
/* Example */
Header:
session-id : dafd23eaf

body:
 user_id : fafsafaj22842,
 created_at: "2026-02 19T10:37:42"
 email: "sergioda@example.com"
 user_name : juancho,
 country: colombia,
 city: bogota
 password: "",
```

Returns 404 not Found if user not found or email or password incorrect

Returns 401 Unautorized if User was deleted

### Log out an Account

This endpoint will let the user log out his account

Header: **session-id** : e1e13e1dsfat3t2ge
**Type:** Patch
**Parameters: **

| Type | Object |
| ---- | ------ |
| UUID | id     |

```javascript
Header:
session-id : dafd23eaf

body:
{
 "id" : "fafsafaj22842",
}
```

Returns 200 if logout
Returns 404 if Session not found

---

## Not Implemented Yet

### Get Chats

This endpoint will return you the chats use for the user.

**Type:** GET
**Parameters: **

| Type   | Object | Lenght  |
| ------ | ------ | ------- |
| String | Token  | unknown |
| String | UserId | unknown |

This will return a List will the chats that the user is using

```javascript
/*Example*/
[
    { chat_id: 425232dad,
      users: [
        { user_id: 1245, username : juancho },
        { user_id 14353,  username : paco }
      ]
    },
    { chat_id: 45da67777,
      users: [
        { user_id: fad, username : rodolfo },
        { user_id 14353,  username : pepe }
      ]
    },
];
```

### Get Chat Messages

This endpoint will return you the messages of a specific chat

**Type:** GET
**Parameters: **

| Type   | Object | Lenght  |
| ------ | ------ | ------- |
| String | Token  | unknown |
| String | ChatId | unknown |

This endpoint should return if everything ok a status 200 and JSON object

```javascript
[
  {
    username: "apolo",
    message: "Hola, Como estas?",
  },
];
```

### Get Chat Suggestions

This endpoint will return you the messages of a specific chat

**Type:** GET
**Parameters: **

| Type   | Object | Lenght  |
| ------ | ------ | ------- |
| String | Token  | unknown |
| String | userId | unknown |

This endpoint should return if everything ok a status 200 and a JSON object

```javascript
[
  {
    user_id: "dadasdasjj1442",
    username: "apolo",
    country: "ecuador",
    city: "quito",
  },
];
```
