# Admin API Documentation

## Overview
Administrative endpoints for managing users, sellers, products, orders, businesses, content, and system settings.

**All admin endpoints require:**
- Authentication: `Bearer {admin_token}`
- Middleware: `auth:sanctum`, `admin`

---

## Dashboard & Overview

### 1. Get Dashboard Overview
**Endpoint:** `GET /api/admin/dashboard/overview`  
**Controller:** `AdminOverviewController@index`  
**Middleware:** `auth:sanctum`, `admin`  
**Description:** Get dashboard statistics and metrics

#### Headers
```
Authorization: Bearer {admin_token}
```

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "total_users": 1250,
    "total_revenue": 4500000.50,
    "total_businesses": 85,
    "total_sellers": 120,
    "market_revenue": 3200000.00
  }
}
```

#### Business Logic Notes
- `total_users`: Count of all registered users
- `total_revenue`: Sum of all paid orders
- `total_businesses`: Count of all business profiles
- `total_sellers`: Count of all seller profiles
- `market_revenue`: Revenue from product orders only

---

## User Management

### 2. List All Users
**Endpoint:** `GET /api/admin/users`  
**Controller:** `AdminUserController@index`  
**Middleware:** `auth:sanctum`, `admin`  
**Description:** Get paginated list of all users with search

#### Headers
```
Authorization: Bearer {admin_token}
```

#### Query Parameters
```
search: string (optional) - Search in firstname, lastname, email, phone
page: integer (optional, default: 1)
```

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Users retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "firstname": "John",
        "lastname": "Doe",
        "email": "john.doe@example.com",
        "phone": "+2348012345678",
        "email_verified_at": "2024-01-15T10:30:00.000000Z",
        "created_at": "2024-01-15T10:30:00.000000Z",
        "seller_profile_count": 1,
        "business_profiles_count": 2,
        "orders_count": 5,
        "name": "John Doe"
      }
    ],
    "links": {
      "first": "http://api.example.com/api/admin/users?page=1",
      "last": "http://api.example.com/api/admin/users?page=84",
      "prev": null,
      "next": "http://api.example.com/api/admin/users?page=2"
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 84,
      "per_page": 15,
      "to": 15,
      "total": 1250
    }
  }
}
```

#### Business Logic Notes
- Includes relationship counts (seller_profile, business_profiles, orders)
- Search across multiple fields simultaneously
- Paginated with 15 users per page
- Ordered by creation date (newest first)

---

## Seller Management

### 3. List Pending Sellers
**Endpoint:** `GET /api/admin/pending/sellers`  
**Controller:** `AdminSellerController@pendingSellers`  
**Middleware:** `auth:sanctum`, `admin`  
**Description:** Get all pending seller profile applications

#### Headers
```
Authorization: Bearer {admin_token}
```

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Pending seller profiles retrieved successfully",
  "data": {
    "data": [
      {
        "id": 5,
        "user_id": 25,
        "business_name": "New Seller Business",
        "business_email": "seller@example.com",
        "business_phone_number": "+2348098765432",
        "registration_status": "pending",
        "created_at": "2024-01-17T08:00:00.000000Z",
        "user": {
          "id": 25,
          "firstname": "Jane",
          "lastname": "Smith",
          "email": "jane.smith@example.com"
        }
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 15,
      "total": 12
    }
  }
}
```

#### Business Logic Notes
- Only shows profiles with 'pending' status
- Ordered by creation date (oldest first - FIFO)
- Includes user information
- Paginated with 15 per page

---

### 4. List All Sellers
**Endpoint:** `GET /api/admin/market/sellers`  
**Controller:** `AdminSellerController@index`  
**Middleware:** `auth:sanctum`, `admin`  
**Description:** Get all seller profiles with optional status filter

#### Headers
```
Authorization: Bearer {admin_token}
```

#### Query Parameters
```
status: string (optional, enum: pending|approved|rejected)
page: integer (optional, default: 1)
```

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Seller profiles retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 10,
        "business_name": "Adire Creations",
        "registration_status": "approved",
        "active": true,
        "created_at": "2024-01-10T08:00:00.000000Z",
        "user": {
          "id": 10,
          "firstname": "Ade",
          "lastname": "Williams",
          "email": "ade@example.com"
        }
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 15,
      "total": 120
    }
  }
}
```

---

### 5. Get Seller Details
**Endpoint:** `GET /api/admin/sellers/{id}`  
**Controller:** `AdminSellerController@show`  
**Middleware:** `auth:sanctum`, `admin`  
**Description:** Get detailed seller profile information

#### Headers
```
Authorization: Bearer {admin_token}
```

#### URL Parameters
- `id`: Seller Profile ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Seller details retrieved successfully",
  "data": {
    "seller": {
      "id": 1,
      "user": {
        "firstname": "Ade",
        "lastname": "Williams",
        "email": "ade@example.com",
        "phone": "+2348012345678"
      },
      "business_name": "Adire Creations",
      "business_email": "business@example.com",
      "business_phone_number": "+2348012345678",
      "country": "Nigeria",
      "state": "Lagos",
      "city": "Ikeja",
      "address": "123 Business Street",
      "instagram": "@adire_creations",
      "facebook": "facebook.com/adire",
      "business_registration_number": "BN123456",
      "bank_name": "GTBank",
      "account_number": "0123456789",
      "registration_status": "approved",
      "documents": {
        "identity_document": "spaces/identity/doc123.pdf",
        "business_certificate": "spaces/certificate/cert456.pdf",
        "business_logo": "spaces/logos/logo789.png"
      },
      "created_at": "2024-01-10T08:00:00.000000Z",
      "products_count": 15,
      "products": [
        {
          "id": 1,
          "name": "Ankara Agbada Set",
          "price": 25000.00,
          "status": "approved",
          "created_at": "2024-01-15T10:00:00.000000Z"
        }
      ]
    }
  }
}
```

---

### 6. Approve/Reject Seller
**Endpoint:** `PATCH /api/admin/seller/{id}/approve`  
**Controller:** `AdminSellerController@approveSeller`  
**Middleware:** `auth:sanctum`, `admin`  
**Description:** Approve or reject seller application

#### Headers
```
Authorization: Bearer {admin_token}
```

#### URL Parameters
- `id`: Seller Profile ID (integer)

#### Request Body
```json
{
  "status": "string (required, enum: approved|rejected)",
  "rejection_reason": "string (required if status=rejected)"
}
```

#### Validation Rules
- `status`: required|in:approved,rejected
- `rejection_reason`: required_if:status,rejected|string|nullable

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Seller profile approved successfully",
  "data": {
    "id": 5,
    "registration_status": "approved",
    "rejection_reason": null,
    "updated_at": "2024-01-17T15:00:00.000000Z"
  }
}
```

---

### 7. Update Seller Active Status
**Endpoint:** `PATCH /api/admin/market/seller/{id}/status`  
**Controller:** `AdminSellerController@updateStatus`  
**Middleware:** `auth:sanctum`, `admin`  
**Description:** Activate or deactivate seller profile

#### Headers
```
Authorization: Bearer {admin_token}
```

#### URL Parameters
- `id`: Seller Profile ID (integer)

#### Request Body
```json
{
  "active": "boolean (required)"
}
```

#### Validation Rules
- `active`: required|boolean

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Seller profile activated successfully",
  "data": {
    "id": 1,
    "active": true,
    "updated_at": "2024-01-17T16:00:00.000000Z"
  }
}
```

---

## Product Management

### 8. List Pending Products
**Endpoint:** `GET /api/admin/pending/products`  
**Controller:** `AdminProductController@pendingProducts`  
**Middleware:** `auth:sanctum`, `admin`

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Pending products retrieved successfully",
  "data": {
    "data": [
      {
        "id": 10,
        "name": "New Ankara Design",
        "price": 20000.00,
        "status": "pending",
        "created_at": "2024-01-17T09:00:00.000000Z",
        "seller_profile": {
          "id": 3,
          "business_name": "Fashion House",
          "user": {
            "firstname": "Mary",
            "lastname": "Johnson",
            "email": "mary@example.com"
          }
        }
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 15,
      "total": 8
    }
  }
}
```

---

### 9. List All Products
**Endpoint:** `GET /api/admin/market/products`  
**Controller:** `AdminProductController@index`  
**Middleware:** `auth:sanctum`, `admin`

#### Query Parameters
```
status: string (optional, enum: pending|approved|rejected)
```

---

### 10. Get Product Details
**Endpoint:** `GET /api/admin/products/{id}`  
**Controller:** `AdminProductController@show`  
**Middleware:** `auth:sanctum`, `admin`

---

### 11. Approve/Reject Product
**Endpoint:** `PATCH /api/admin/product/{id}/approve`  
**Controller:** `AdminProductController@approveProduct`  
**Middleware:** `auth:sanctum`, `admin`

#### Request Body
```json
{
  "status": "string (required, enum: approved|rejected)",
  "rejection_reason": "string (required if status=rejected)"
}
```

---

### 12. Update Product Status
**Endpoint:** `PATCH /api/admin/market/product/{id}/status`  
**Controller:** `AdminProductController@updateStatus`  
**Middleware:** `auth:sanctum`, `admin`

#### Request Body
```json
{
  "status": "string (required, enum: pending|approved|rejected)"
}
```

---

## Order Management

### 13. List All Orders
**Endpoint:** `GET /api/admin/orders`  
**Controller:** `AdminOrderController@index`  
**Middleware:** `auth:sanctum`, `admin`

#### Query Parameters
```
status: string (optional, enum: pending|processing|shipped|delivered|canceled|paid)
```

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Orders retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 5,
        "total_price": 45000.00,
        "status": "shipped",
        "tracking_number": "TRK123456",
        "created_at": "2024-01-17T10:00:00.000000Z",
        "user": {
          "id": 5,
          "firstname": "John",
          "lastname": "Doe",
          "email": "john@example.com"
        },
        "order_items": [
          {
            "id": 1,
            "product_id": 3,
            "quantity": 2,
            "unit_price": 18000.00,
            "product": {
              "id": 3,
              "name": "Ankara Dress",
              "image": "https://example.com/product3.jpg"
            }
          }
        ]
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 15,
      "total": 450
    }
  }
}
```

---

### 14. Get Order Details
**Endpoint:** `GET /api/admin/order/{id}`  
**Controller:** `AdminOrderController@show`  
**Middleware:** `auth:sanctum`, `admin`

---

### 15. Update Order Status
**Endpoint:** `PATCH /api/admin/order/{id}/status`  
**Controller:** `AdminOrderController@updateStatus`  
**Middleware:** `auth:sanctum`, `admin`

#### Request Body
```json
{
  "status": "string (required, enum: pending|processing|shipped|delivered|canceled|paid)",
  "tracking_number": "string (optional)",
  "cancellation_reason": "string (optional)"
}
```

#### Validation Rules
- `status`: required|in:pending,processing,shipped,delivered,canceled,paid
- `tracking_number`: nullable|string
- `cancellation_reason`: nullable|string

#### Business Logic Notes
- Sends notification to user when status changes
- Sets `delivered_at` timestamp when status is 'delivered'
- Email and push notification sent via NotificationService

---

## Business Profile Management

### 16. List Businesses by Category
**Endpoint:** `GET /api/admin/business/{category}`  
**Controller:** `AdminBusinessController@index`  
**Middleware:** `auth:sanctum`, `admin`

#### URL Parameters
- `category`: string (enum: beauty|brand|school|music)

#### Query Parameters
```
store_status: string (optional, enum: pending|approved|deactivated)
```

---

### 17. Get Business Details
**Endpoint:** `GET /api/admin/business/{category}/{id}`  
**Controller:** `AdminBusinessController@show`  
**Middleware:** `auth:sanctum`, `admin`

---

### 18. Update Business Status
**Endpoint:** `PATCH /api/admin/business/{category}/{id}/status`  
**Controller:** `AdminBusinessController@updateStatus`  
**Middleware:** `auth:sanctum`, `admin`

#### Request Body
```json
{
  "store_status": "string (required, enum: pending|approved|deactivated)",
  "rejection_reason": "string (required if store_status=rejected)"
}
```

#### Business Logic Notes
- Sends notification to business owner
- Notification includes approval status and rejection reason if applicable

---

## Content Management

### 19. List All Blogs (Admin)
**Endpoint:** `GET /api/admin/blogs`  
**Controller:** `AdminBlogController@index`  
**Middleware:** `auth:sanctum`, `admin`

#### Query Parameters
```
published: string (optional, enum: true|false)
```

---

### 20. Create Blog
**Endpoint:** `POST /api/admin/blogs`  
**Controller:** `AdminBlogController@store`  
**Middleware:** `auth:sanctum`, `admin`

#### Request Body
```json
{
  "title": "string (required, max:255)",
  "body": "string (required)",
  "featured_image": "string (optional, url)",
  "published": "boolean (optional)"
}
```

#### Business Logic Notes
- Slug auto-generated from title
- If published=true, sends push notification to all users
- Associates blog with authenticated admin

---

### 21. Update Blog
**Endpoint:** `PUT /api/admin/blogs/{id}`  
**Controller:** `AdminBlogController@update`  
**Middleware:** `auth:sanctum`, `admin`

---

### 22. Delete Blog
**Endpoint:** `DELETE /api/admin/blogs/{id}`  
**Controller:** `AdminBlogController@destroy`  
**Middleware:** `auth:sanctum`, `admin`

---

### 23. Toggle Blog Publish Status
**Endpoint:** `PATCH /api/admin/blogs/{id}/toggle-publish`  
**Controller:** `AdminBlogController@togglePublish`  
**Middleware:** `auth:sanctum`, `admin`

#### Business Logic Notes
- Toggles published_at between null and current timestamp
- Sends push notification to all users when newly published

---

## Advertisement Management

### 24. List Adverts
**Endpoint:** `GET /api/admin/adverts`  
**Controller:** `AdvertController@index`  
**Middleware:** `auth:sanctum`, `admin`

#### Query Parameters
```
status: string (optional, enum: active|inactive|scheduled)
position: string (optional, enum: banner|sidebar|footer|popup)
per_page: integer (optional, default: 10)
```

---

### 25. Create Advert
**Endpoint:** `POST /api/admin/adverts`  
**Controller:** `AdvertController@store`  
**Middleware:** `auth:sanctum`, `admin`

#### Request Body
```json
{
  "title": "string (required, max:255)",
  "description": "string (required)",
  "image_url": "string (required, url)",
  "action_url": "string (optional, url)",
  "position": "string (required, enum: banner|sidebar|footer|popup)",
  "status": "string (required, enum: active|inactive|scheduled)",
  "priority": "integer (optional, min:0, max:100)",
  "start_date": "date (optional, after_or_equal:today)",
  "end_date": "date (optional, after:start_date)"
}
```

---

### 26. Update Advert
**Endpoint:** `PUT /api/admin/adverts/{advert}`  
**Controller:** `AdvertController@update`  
**Middleware:** `auth:sanctum`, `admin`

---

### 27. Delete Advert
**Endpoint:** `DELETE /api/admin/adverts/{advert}`  
**Controller:** `AdvertController@destroy`  
**Middleware:** `auth:sanctum`, `admin`

---

## School Registration Management

### 28. List School Registrations
**Endpoint:** `GET /api/admin/school-registrations`  
**Controller:** `SchoolRegistrationController@index`  
**Middleware:** `auth:sanctum`, `admin`

#### Query Parameters
```
status: string (optional, enum: pending|processing|approved|rejected)
per_page: integer (optional, default: 10)
```

---

### 29. Get School Registration
**Endpoint:** `GET /api/admin/school-registrations/{schoolRegistration}`  
**Controller:** `SchoolRegistrationController@show`  
**Middleware:** `auth:sanctum`, `admin`

---

### 30. Update School Registration Status
**Endpoint:** `PUT /api/admin/school-registrations/{schoolRegistration}`  
**Controller:** `SchoolRegistrationController@update`  
**Middleware:** `auth:sanctum`, `admin`

#### Request Body
```json
{
  "status": "string (required, enum: pending|processing|approved|rejected)"
}
```

---

### 31. Delete School Registration
**Endpoint:** `DELETE /api/admin/school-registrations/{schoolRegistration}`  
**Controller:** `SchoolRegistrationController@destroy`  
**Middleware:** `auth:sanctum`, `admin`

---

## Sustainability Initiatives

### 32. List Sustainability Initiatives
**Endpoint:** `GET /api/admin/sustainability`  
**Controller:** `SustainabilityController@index`  
**Middleware:** `auth:sanctum`, `admin`

#### Query Parameters
```
category: string (optional, enum: environmental|social|economic|governance)
status: string (optional, enum: active|completed|planned|cancelled)
per_page: integer (optional, default: 10)
```

---

### 33. Create Sustainability Initiative
**Endpoint:** `POST /api/admin/sustainability`  
**Controller:** `SustainabilityController@store`  
**Middleware:** `auth:sanctum`, `admin`

#### Request Body
```json
{
  "title": "string (required, max:255)",
  "description": "string (required)",
  "image_url": "string (optional, url)",
  "category": "string (required, enum: environmental|social|economic|governance)",
  "status": "string (required, enum: active|completed|planned|cancelled)",
  "target_amount": "decimal (optional, min:0)",
  "current_amount": "decimal (optional, min:0)",
  "impact_metrics": "string (optional)",
  "start_date": "date (optional)",
  "end_date": "date (optional, after_or_equal:start_date)",
  "partners": "array (optional)",
  "participant_count": "integer (optional, min:0)",
  "progress_notes": "string (optional)"
}
```

---

### 34. Update Sustainability Initiative
**Endpoint:** `PUT /api/admin/sustainability/{sustainabilityInitiative}`  
**Controller:** `SustainabilityController@update`  
**Middleware:** `auth:sanctum`, `admin`

---

### 35. Delete Sustainability Initiative
**Endpoint:** `DELETE /api/admin/sustainability/{sustainabilityInitiative}`  
**Controller:** `SustainabilityController@destroy`  
**Middleware:** `auth:sanctum`, `admin`

---

## Notification Management

### 36. Send Notification
**Endpoint:** `POST /api/admin/notifications/send`  
**Controller:** `AdminNotificationController@send`  
**Middleware:** `auth:sanctum`, `admin`

#### Request Body
```json
{
  "title": "string (required, max:255)",
  "message": "string (required)",
  "type": "string (required, enum: general|promotion|system|security)",
  "recipient_type": "string (required, enum: all|specific|sellers)",
  "user_ids": "array (required if recipient_type=specific)",
  "user_ids.*": "integer (exists:users,id)",
  "action_url": "string (optional, url)",
  "send_immediately": "boolean (optional)"
}
```

#### Success Response (201)
```json
{
  "status": "success",
  "message": "Notification sent successfully to 150 users",
  "data": {
    "recipients_count": 150,
    "notification": {
      "title": "New Feature Available",
      "message": "Check out our new marketplace features!",
      "type": "general",
      "recipient_type": "all"
    }
  }
}
```

#### Recipient Types
- `all`: All registered users
- `sellers`: Only users with seller profiles
- `specific`: Specific user IDs in user_ids array

---

## Settings Management

### 37. Get Application Settings
**Endpoint:** `GET /api/admin/settings`  
**Controller:** `AdminSettingsController@show`  
**Middleware:** `auth:sanctum`, `admin`

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Application settings retrieved successfully",
  "data": {
    "maintenance_mode": false,
    "maintenance_message": "System is under maintenance",
    "allow_registrations": true,
    "allow_seller_registrations": true,
    "max_products_per_seller": 100,
    "commission_rate": 5.0,
    "default_currency": "NGN",
    "email_notifications_enabled": true,
    "sms_notifications_enabled": false,
    "auto_approve_products": false,
    "auto_approve_sellers": false,
    "min_order_amount": 1000,
    "max_order_amount": 1000000,
    "featured_products_limit": 20,
    "support_email": "support@example.com",
    "support_phone": "+234XXXXXXXXXX"
  }
}
```

---

### 38. Update Application Settings
**Endpoint:** `PUT /api/admin/settings`  
**Controller:** `AdminSettingsController@update`  
**Middleware:** `auth:sanctum`, `admin`

#### Request Body (All Optional)
```json
{
  "maintenance_mode": "boolean",
  "maintenance_message": "string (max:500)",
  "allow_registrations": "boolean",
  "allow_seller_registrations": "boolean",
  "max_products_per_seller": "integer (min:1, max:1000)",
  "commission_rate": "decimal (min:0, max:100)",
  "default_currency": "string (enum: NGN|USD|EUR|GBP)",
  "email_notifications_enabled": "boolean",
  "sms_notifications_enabled": "boolean",
  "auto_approve_products": "boolean",
  "auto_approve_sellers": "boolean",
  "min_order_amount": "decimal (min:0)",
  "max_order_amount": "decimal (min:1000)",
  "featured_products_limit": "integer (min:1, max:100)",
  "support_email": "email",
  "support_phone": "string (max:20)"
}
```

#### Business Logic Notes
- Settings stored in cache permanently
- Partial updates supported
- Returns only updated settings

---

## Summary

### Total Admin Endpoints: 38

**Breakdown by Category:**
- Dashboard: 1 endpoint
- Users: 1 endpoint
- Sellers: 5 endpoints
- Products: 5 endpoints
- Orders: 3 endpoints
- Businesses: 3 endpoints
- Blogs: 5 endpoints
- Adverts: 4 endpoints
- School Registrations: 4 endpoints
- Sustainability: 4 endpoints
- Notifications: 1 endpoint
- Settings: 2 endpoints

### Authorization
All endpoints require admin authentication via Sanctum token with 'admin' ability.

### Common Response Codes
- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden (not admin)
- 404: Not Found
- 422: Validation Error

### Pagination
Most list endpoints use pagination:
- Default: 15 items per page
- Configurable via query params
- Includes links and meta information
