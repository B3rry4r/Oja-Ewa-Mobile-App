# User Management API Documentation

## Overview
Endpoints for managing user profiles, addresses, and notification preferences.

---

## User Profile Management

### 1. Get User Profile
**Endpoint:** `GET /api/profile`  
**Controller:** `UserController@profile`  
**Middleware:** `auth:sanctum`  
**Description:** Get authenticated user's profile information

#### Headers
```
Authorization: Bearer {token}
```

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "firstname": "John",
    "lastname": "Doe",
    "email": "john.doe@example.com",
    "phone": "+2348012345678",
    "email_verified_at": "2024-01-15T10:30:00.000000Z",
    "created_at": "2024-01-15T10:30:00.000000Z",
    "updated_at": "2024-01-15T10:30:00.000000Z"
  }
}
```

---

### 2. Update User Profile
**Endpoint:** `PUT /api/profile`  
**Controller:** `UserController@updateProfile`  
**Middleware:** `auth:sanctum`  
**Description:** Update user profile information

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "firstname": "string (required, max:255)",
  "lastname": "string (required, max:255)",
  "email": "string (required, email, unique)",
  "phone": "string (optional, max:30)"
}
```

#### Validation Rules
- `firstname`: required|string|max:255
- `lastname`: required|string|max:255
- `email`: required|email|unique:users,email,{current_user_id}
- `phone`: nullable|string|max:30

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "firstname": "John",
    "lastname": "Doe",
    "email": "john.doe@example.com",
    "phone": "+2348012345678",
    "updated_at": "2024-01-15T14:30:00.000000Z"
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

### 3. Update Password
**Endpoint:** `PUT /api/password`  
**Controller:** `UserController@updatePassword`  
**Middleware:** `auth:sanctum`  
**Description:** Change user password

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "current_password": "string (required)",
  "password": "string (required, min:8, confirmed)",
  "password_confirmation": "string (required)"
}
```

#### Validation Rules
- `current_password`: required|string
- `password`: required|string|min:8|confirmed
- `password_confirmation`: required (must match password)

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Password updated successfully"
}
```

#### Error Response (422)
```json
{
  "message": "The current password is incorrect.",
  "errors": {
    "current_password": ["The current password is incorrect."]
  }
}
```

#### Business Logic Notes
- Current password must be verified before allowing change
- New password is hashed using bcrypt
- Password must be different from current password (recommended)

---

## Address Management

### 4. Get All Addresses
**Endpoint:** `GET /api/addresses`  
**Controller:** `AddressController@index`  
**Middleware:** `auth:sanctum`  
**Description:** Get all saved addresses for authenticated user

#### Headers
```
Authorization: Bearer {token}
```

#### Success Response (200)
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "country": "Nigeria",
      "full_name": "John Doe",
      "phone_number": "+2348012345678",
      "state": "Lagos",
      "city": "Ikeja",
      "zip_code": "100001",
      "address": "123 Main Street, GRA",
      "is_default": true,
      "created_at": "2024-01-15T10:30:00.000000Z",
      "updated_at": "2024-01-15T10:30:00.000000Z"
    },
    {
      "id": 2,
      "user_id": 1,
      "country": "Nigeria",
      "full_name": "John Doe",
      "phone_number": "+2348012345678",
      "state": "Abuja",
      "city": "Wuse",
      "zip_code": "900001",
      "address": "45 Office Complex, Wuse II",
      "is_default": false,
      "created_at": "2024-01-16T09:00:00.000000Z",
      "updated_at": "2024-01-16T09:00:00.000000Z"
    }
  ]
}
```

#### Business Logic Notes
- Addresses are ordered by `is_default` DESC (default address first)
- Only returns addresses belonging to authenticated user

---

### 5. Create Address
**Endpoint:** `POST /api/addresses`  
**Controller:** `AddressController@store`  
**Middleware:** `auth:sanctum`  
**Description:** Create a new address

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "country": "string (required, max:255)",
  "full_name": "string (required, max:255)",
  "phone_number": "string (required, max:30)",
  "state": "string (required, max:255)",
  "city": "string (required, max:255)",
  "zip_code": "string (required, max:20)",
  "address": "string (required)",
  "is_default": "boolean (optional, default: false)"
}
```

#### Validation Rules
- `country`: required|string|max:255
- `full_name`: required|string|max:255
- `phone_number`: required|string|max:30
- `state`: required|string|max:255
- `city`: required|string|max:255
- `zip_code`: required|string|max:20
- `address`: required|string
- `is_default`: boolean

#### Success Response (201)
```json
{
  "status": "success",
  "message": "Address created successfully",
  "data": {
    "id": 3,
    "user_id": 1,
    "country": "Nigeria",
    "full_name": "John Doe",
    "phone_number": "+2348012345678",
    "state": "Rivers",
    "city": "Port Harcourt",
    "zip_code": "500001",
    "address": "10 Garden Avenue",
    "is_default": false,
    "created_at": "2024-01-17T11:00:00.000000Z",
    "updated_at": "2024-01-17T11:00:00.000000Z"
  }
}
```

#### Business Logic Notes
- If `is_default` is true, all other user addresses are set to non-default
- Automatically associates address with authenticated user

---

### 6. Get Single Address
**Endpoint:** `GET /api/addresses/{id}`  
**Controller:** `AddressController@show`  
**Middleware:** `auth:sanctum`  
**Description:** Get specific address details

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `id`: Address ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "user_id": 1,
    "country": "Nigeria",
    "full_name": "John Doe",
    "phone_number": "+2348012345678",
    "state": "Lagos",
    "city": "Ikeja",
    "zip_code": "100001",
    "address": "123 Main Street, GRA",
    "is_default": true,
    "created_at": "2024-01-15T10:30:00.000000Z",
    "updated_at": "2024-01-15T10:30:00.000000Z"
  }
}
```

#### Error Response (404)
```json
{
  "message": "No query results for model [App\\Models\\Address] {id}"
}
```

---

### 7. Update Address
**Endpoint:** `PUT /api/addresses/{id}`  
**Controller:** `AddressController@update`  
**Middleware:** `auth:sanctum`  
**Description:** Update existing address

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `id`: Address ID (integer)

#### Request Body
```json
{
  "country": "string (required, max:255)",
  "full_name": "string (required, max:255)",
  "phone_number": "string (required, max:30)",
  "state": "string (required, max:255)",
  "city": "string (required, max:255)",
  "zip_code": "string (required, max:20)",
  "address": "string (required)",
  "is_default": "boolean (optional)"
}
```

#### Validation Rules
- Same as Create Address

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Address updated successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "country": "Nigeria",
    "full_name": "John Doe",
    "phone_number": "+2348012345678",
    "state": "Lagos",
    "city": "Victoria Island",
    "zip_code": "100001",
    "address": "456 New Street, VI",
    "is_default": true,
    "created_at": "2024-01-15T10:30:00.000000Z",
    "updated_at": "2024-01-17T12:00:00.000000Z"
  }
}
```

#### Business Logic Notes
- If setting as default, unsets all other addresses as default (excluding current one)
- User can only update their own addresses

---

### 8. Delete Address
**Endpoint:** `DELETE /api/addresses/{id}`  
**Controller:** `AddressController@destroy`  
**Middleware:** `auth:sanctum`  
**Description:** Delete an address

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `id`: Address ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Address deleted successfully"
}
```

#### Error Response (404)
```json
{
  "message": "No query results for model [App\\Models\\Address] {id}"
}
```

#### Business Logic Notes
- Permanently deletes address from database
- User can only delete their own addresses

---

## Notification Preferences

### 9. Get Notification Preferences
**Endpoint:** `GET /api/notifications/preferences`  
**Controller:** `NotificationPreferenceController@show`  
**Middleware:** `auth:sanctum`  
**Description:** Get user's notification preferences

#### Headers
```
Authorization: Bearer {token}
```

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Notification preferences retrieved successfully",
  "data": {
    "email_notifications": true,
    "push_notifications": true,
    "sms_notifications": false,
    "order_updates": true,
    "promotional_emails": true,
    "security_alerts": true
  }
}
```

#### Business Logic Notes
- Returns default values if preferences not set
- All notification types default to enabled except SMS

---

### 10. Update Notification Preferences
**Endpoint:** `PUT /api/notifications/preferences`  
**Controller:** `NotificationPreferenceController@update`  
**Middleware:** `auth:sanctum`  
**Description:** Update notification preferences

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "email_notifications": "boolean (optional)",
  "push_notifications": "boolean (optional)",
  "sms_notifications": "boolean (optional)",
  "order_updates": "boolean (optional)",
  "promotional_emails": "boolean (optional)",
  "security_alerts": "boolean (optional)"
}
```

#### Validation Rules
- `email_notifications`: sometimes|boolean
- `push_notifications`: sometimes|boolean
- `sms_notifications`: sometimes|boolean
- `order_updates`: sometimes|boolean
- `promotional_emails`: sometimes|boolean
- `security_alerts`: sometimes|boolean

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Notification preferences updated successfully",
  "data": {
    "email_notifications": false,
    "push_notifications": true,
    "promotional_emails": false
  }
}
```

#### Business Logic Notes
- Only provided fields are updated
- Missing fields retain current values
- All fields are optional in update request

---

## Common Error Responses

### 401 Unauthorized
```json
{
  "message": "Unauthenticated."
}
```

### 403 Forbidden
```json
{
  "message": "This action is unauthorized."
}
```

### 404 Not Found
```json
{
  "message": "Resource not found."
}
```

### 422 Validation Error
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "field_name": ["Error message"]
  }
}
```
