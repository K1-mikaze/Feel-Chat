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

### Update User Password

This endpoints is use for updating users information

**Endpoint:** `/updatepassword`
**Type:** PATCH
**Parameters:**
Header: **session-id** : e1e13e1dsfat3t2ge

| Type   | Object       | Lenght          |
| ------ | ------------ | --------------- |
| String | id           | => 7 and <= 320 |
| String | new_password | => 6            |
| String | old_password | => 6            |

- Returns 201 if everything Ok and something was updated
- Returns 401 if session is Expired
- Returns 404 if User and Session not found
- Returns 409 if Password doesn't match
- Returns 400 if bad Request

### Update User Password

This endpoints is use for updating users information

**Endpoint:** `/updatepassword`
**Type:** PATCH
**Parameters:**
Header: **session-id** : e1e13e1dsfat3t2ge

| Type   | Object       | Lenght          |
| ------ | ------------ | --------------- |
| String | id           | => 7 and <= 320 |
| String | new_password | => 6            |
| String | old_password | => 6            |

- Returns 201 if everything Ok and something was updated
- Returns 401 if session is Expired
- Returns 404 if User and Session not found
- Returns 409 if oldPassword doesn't match
- Returns 400 if bad Request

### Update User Information

This endpoints is use for updating users information

**Endpoint:** `/getuser`
**Type:** PUT
**Parameters:**
Header: **session-id** : e1e13e1dsfat3t2ge

| Type   | Object  | Lenght          |
| ------ | ------- | --------------- |
| String | user_id | => 7 and <= 320 |
| String | country | > 5 and < 60    |
| String | city    | > 3 and < 100   |

- Returns 200 if ok
- Returns 404 if User and Session not found

### Update User Information

This endpoints is use for updating users information

**Endpoint:** `/updateinformation`
**Type:** PUT
**Parameters:**
Header: **session-id** : e1e13e1dsfat3t2ge

| Type   | Object  | Lenght          |
| ------ | ------- | --------------- |
| String | user_id | => 7 and <= 320 |
| String | country | > 5 and < 60    |
| String | city    | > 3 and < 100   |

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

**Endpoint:** `/logout`
Header: **session-id** : e1e13e1dsfat3t2ge
**Type:** Patch
**Parameters: **

| Type | Object |
| ---- | ------ |
| UUID | userId |

```javascript
Header:
session-id : dafd23eaf

body:
{
 "user_id" : "fafsafaj22842",
}
```

Returns 200 if logout
Returns 404 if Session not found

---

### Delete an Account

This endpoint will let the user log out his account

**Endpoint:** `/delete`
Header: **session-id** : e1e13e1dsfat3t2ge
**Type:** Patch
**Parameters: **

| Type   | Object      |
| ------ | ----------- |
| UUID   | userId      |
| String | oldPassword |
| String | newPassword |

```javascript
Header:
session-id : dafd23eaf

body:
{
 "user_id" : "fafsafaj22842",
}
```

Returns 200 if deleted
Returns 404 if Session not found

## Not Implemented Yet

### Get Chats

This endpoint will return you the chats use for the user.

**Endpoint:** `/getcurrentchats`
**Type:** POST
**Parameters: **
**Headers:** session-id

| Type   | Object | Lenght  |
| ------ | ------ | ------- |
| String | userId | unknown |

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

if everything good returns 200 and the objects
if SessionId or userId are bad returns 401

### Get Chat Messages

This endpoint will return you the messages of a specific chat

**Type:** POST
**Parameters: **
**Headers:** session-id

| Type   | Object | Lenght  |
| ------ | ------ | ------- |
| String | userId | unknown |

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

**Endpoint:** `/getsuggestionschats`
**Type:** POST
**Parameters: **
**Headers:** session-id

| Type   | Object | Lenght  |
| ------ | ------ | ------- |
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
