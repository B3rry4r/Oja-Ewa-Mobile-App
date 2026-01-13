# Authentication API Documentation

## Overview
All authentication endpoints for user registration, login, password management, and OAuth authentication.

---

## User Authentication

### 1. User Registration
**Endpoint:** `POST /api/register`  
**Controller:** `UserAuthController@register`  
**Middleware:** None (Public)  
**Description:** Register a new user account

#### Request Body
```json
{
  "firstname": "string (required, max:255)",
  "lastname": "string (required, max:255)",
  "email": "string (required, email, unique)",
  "phone": "string (optional, max:30)",
  "password": "string (required, min:8)"
}
```

#### Validation Rules
- `firstname`: required|string|max:255
- `lastname`: required|string|max:255
- `email`: required|email|unique:users,email
- `phone`: nullable|string|max:30
- `password`: required|string|min:8

#### Success Response (201)
```json
{
  "token": "1|aBcDeFgHiJkLmNoPqRsTuVwXyZ",
  "user": {
    "id": 1,
    "firstname": "John",
    "lastname": "Doe",
    "email": "john.doe@example.com",
    "phone": "+2348012345678",
    "email_verified_at": null,
    "created_at": "2024-01-15T10:30:00.000000Z",
    "updated_at": "2024-01-15T10:30:00.000000Z"
  }
}
```

#### Error Response (422)
```json
{
  "message": "The email has already been taken.",
  "errors": {
    "email": ["The email has already been taken."]
  }
}
```

---

### 2. User Login
**Endpoint:** `POST /api/login`  
**Controller:** `UserAuthController@login`  
**Middleware:** None (Public)  
**Description:** Login user and receive authentication token

#### Request Body
```json
{
  "email": "string (required, email)",
  "password": "string (required)"
}
```

#### Validation Rules
- `email`: required|email
- `password`: required|string

#### Success Response (200)
```json
{
  "token": "2|xYzAbCdEfGhIjKlMnOpQrStUvW",
  "user": {
    "id": 1,
    "firstname": "John",
    "lastname": "Doe",
    "email": "john.doe@example.com",
    "phone": "+2348012345678",
    "email_verified_at": null,
    "created_at": "2024-01-15T10:30:00.000000Z",
    "updated_at": "2024-01-15T10:30:00.000000Z"
  }
}
```

#### Error Response (422)
```json
{
  "message": "The provided credentials are incorrect.",
  "errors": {
    "email": ["The provided credentials are incorrect."]
  }
}
```

---

### 3. Forgot Password
**Endpoint:** `POST /api/password/forgot`  
**Controller:** `UserAuthController@forgot`  
**Middleware:** None (Public)  
**Description:** Send password reset link to user's email

#### Request Body
```json
{
  "email": "string (required, email)"
}
```

#### Validation Rules
- `email`: required|email

#### Success Response (200)
```json
{
  "message": "We have emailed your password reset link!"
}
```

#### Error Response (400)
```json
{
  "message": "We can't find a user with that email address."
}
```

---

### 4. Reset Password
**Endpoint:** `POST /api/password/reset`  
**Controller:** `UserAuthController@reset`  
**Middleware:** None (Public)  
**Description:** Reset user password using token from email

#### Request Body
```json
{
  "token": "string (required)",
  "email": "string (required, email)",
  "password": "string (required, min:8, confirmed)",
  "password_confirmation": "string (required)"
}
```

#### Validation Rules
- `token`: required
- `email`: required|email
- `password`: required|string|min:8|confirmed
- `password_confirmation`: required (must match password)

#### Success Response (200)
```json
{
  "message": "Your password has been reset!"
}
```

#### Error Response (400)
```json
{
  "message": "This password reset token is invalid."
}
```

---

### 5. Google OAuth Login
**Endpoint:** `POST /api/oauth/google`  
**Controller:** `GoogleAuthController@handle`  
**Middleware:** None (Public)  
**Description:** Authenticate user via Google OAuth

#### Request Body
```json
{
  "token": "string (required, Google ID token from frontend)"
}
```

#### Validation Rules
- `token`: required|string

#### Success Response (200)
```json
{
  "token": "3|pQrStUvWxYzAbCdEfGhIjKlMnO",
  "user": {
    "id": 2,
    "firstname": "Jane",
    "lastname": "Smith",
    "email": "jane.smith@gmail.com",
    "phone": null,
    "email_verified_at": "2024-01-15T11:00:00.000000Z",
    "created_at": "2024-01-15T11:00:00.000000Z",
    "updated_at": "2024-01-15T11:00:00.000000Z"
  },
  "need_phone": true
}
```

#### Response Fields
- `token`: Authentication token for API access
- `user`: User object with profile information
- `need_phone`: Boolean indicating if phone number needs to be provided

#### Error Response (422)
```json
{
  "message": "Invalid Google token.",
  "errors": {
    "token": ["Invalid Google token."]
  }
}
```

#### Business Logic Notes
- If user doesn't exist, creates new account using Google profile data
- Sets random password that must be changed later
- Returns `need_phone: true` if phone number is missing from profile
- Email from Google is automatically verified

---

## Admin Authentication

### 6. Admin Login
**Endpoint:** `POST /api/admin/login`  
**Controller:** `AdminAuthController@login`  
**Middleware:** None (Public)  
**Description:** Admin login endpoint

#### Request Body
```json
{
  "email": "string (required, email)",
  "password": "string (required)"
}
```

#### Validation Rules
- `email`: required|email
- `password`: required|string

#### Success Response (200)
```json
{
  "token": "4|aBcDeFgHiJkLmNoPqRsTuVwXyZ",
  "admin": {
    "id": 1,
    "firstname": "Admin",
    "lastname": "User",
    "email": "admin@ojaewa.com",
    "is_super_admin": true,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

#### Error Response (422)
```json
{
  "message": "The provided credentials are incorrect.",
  "errors": {
    "email": ["The provided credentials are incorrect."]
  }
}
```

#### Business Logic Notes
- Uses Sanctum token with 'admin' ability
- Token must be included in subsequent admin requests

---

### 7. Create Admin
**Endpoint:** `POST /api/admin/create`  
**Controller:** `AdminAuthController@create`  
**Middleware:** None (Should be protected in production)  
**Description:** Create a new admin user

#### Request Body
```json
{
  "firstname": "string (required, max:255)",
  "lastname": "string (required, max:255)",
  "email": "string (required, email, unique)",
  "password": "string (required, min:8, confirmed)",
  "password_confirmation": "string (required)",
  "is_super_admin": "boolean (optional, default: false)"
}
```

#### Validation Rules
- `firstname`: required|string|max:255
- `lastname`: required|string|max:255
- `email`: required|email|unique:admins,email
- `password`: required|string|min:8|confirmed
- `is_super_admin`: boolean

#### Success Response (201)
```json
{
  "message": "Admin created successfully",
  "token": "5|xYzAbCdEfGhIjKlMnOpQrStUvW",
  "admin": {
    "id": 2,
    "firstname": "Support",
    "lastname": "Admin",
    "email": "support@ojaewa.com",
    "is_super_admin": false,
    "created_at": "2024-01-15T12:00:00.000000Z",
    "updated_at": "2024-01-15T12:00:00.000000Z"
  }
}
```

#### Business Logic Notes
- This endpoint should be protected or used only for initial setup
- Creates admin with specified privileges
- Returns authentication token immediately

---

### 8. Get Admin Profile
**Endpoint:** `GET /api/admin/profile`  
**Controller:** `AdminAuthController@profile`  
**Middleware:** `auth:sanctum`, `admin`  
**Description:** Get current admin user profile

#### Headers
```
Authorization: Bearer {admin_token}
```

#### Success Response (200)
```json
{
  "admin": {
    "id": 1,
    "firstname": "Admin",
    "lastname": "User",
    "email": "admin@ojaewa.com",
    "is_super_admin": true,
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

---

### 9. Admin Logout
**Endpoint:** `POST /api/admin/logout`  
**Controller:** `AdminAuthController@logout`  
**Middleware:** `auth:sanctum`, `admin`  
**Description:** Logout admin and revoke current token

#### Headers
```
Authorization: Bearer {admin_token}
```

#### Success Response (200)
```json
{
  "message": "Logged out successfully"
}
```

#### Business Logic Notes
- Deletes current access token only
- Other tokens remain valid if admin has multiple sessions

---

## Authentication Notes

### Token Usage
- All authenticated endpoints require `Authorization: Bearer {token}` header
- Tokens are created using Laravel Sanctum
- Admin tokens have 'admin' ability
- User tokens have default abilities

### Security Considerations
- Passwords are hashed using bcrypt
- Email uniqueness is enforced at database level
- Password reset tokens expire after configured time
- Failed login attempts should be rate-limited (implement in production)

### Error Codes
- `200`: Success
- `201`: Resource created
- `400`: Bad request
- `401`: Unauthorized
- `422`: Validation error
