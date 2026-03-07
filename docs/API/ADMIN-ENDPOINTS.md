# REST Endpoints for Administrator API

Path: `/api/v1/admin`

---

## Delete User

This endpoint allows an administrator to delete a user from the system.

**Endpoint:** `/users`
**Type:** DELETE
**Parameters:**
Header: **session-id** : e1e13e1dsfat3t2ge

| Type | Object     | Description     |
| ---- | ---------- | --------------- |
| UUID | user_id    | User ID to delete |
| UUID | delete_id  | ID performing the deletion |

- Returns 200 if user was deleted successfully
- Returns 404 if User or Session not found
- Returns 400 if bad request

---

## Update User

This endpoint allows an administrator to update a user's information.

**Endpoint:** `/users`
**Type:** PUT
**Parameters:**
Header: **session-id** : e1e13e1dsfat3t2ge

| Type   | Object   | Description       |
| ------ | -------- | ----------------- |
| UUID   | user_id  | User ID to update |
| UUID   | id       | New user ID       |
| String | email    | New email         |
| String | username | New username      |
| String | password | New password      |
| String | city     | New city          |
| String | country  | New country       |

- Returns 200 if user was updated successfully
- Returns 404 if User or Session not found
- Returns 400 if bad request

---

## Get All Users

This endpoint retrieves all users in the system. Administrator access required.

**Endpoint:** `/users`
**Type:** GET
**Parameters:**
Header: **session-id** : e1e13e1dsfat3t2ge

Query Param: **includeDeleted** : false (default)

| Type | Object  | Description           |
| ---- | ------- | --------------------- |
| UUID | user_id | Administrator's user ID |

```javascript
/* Example */
Header:
session-id : dafd23eaf

body:
{
  "user_id" : "fafsafaj22842",
}
```

- Returns 200 with List<User> if successful
- Returns 401 if unauthorized (session invalid)
- Returns 400 if bad request
