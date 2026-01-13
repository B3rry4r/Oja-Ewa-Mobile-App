# Notifications API Documentation

## Overview
Endpoints for managing user notifications and notification preferences.

---

## Notification Management

### 1. Get User Notifications
**Endpoint:** `GET /api/notifications`  
**Controller:** `NotificationController@index`  
**Middleware:** `auth:sanctum`  
**Description:** Get all notifications for authenticated user

#### Headers
```
Authorization: Bearer {token}
```

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "title": "Order Confirmed!",
        "message": "Your order #5 has been confirmed and is being processed.",
        "type": "push",
        "event": "order_created",
        "data": {
          "order_id": 5,
          "deep_link": "/orders/5"
        },
        "read_at": null,
        "created_at": "2024-01-17T11:00:00.000000Z",
        "updated_at": "2024-01-17T11:00:00.000000Z"
      },
      {
        "id": 2,
        "user_id": 1,
        "title": "Order Status Updated",
        "message": "Your order #5 status has been updated to shipped.",
        "type": "email",
        "event": "order_status_updated",
        "data": {
          "order_id": 5,
          "status": "shipped",
          "deep_link": "/orders/5"
        },
        "read_at": "2024-01-17T12:00:00.000000Z",
        "created_at": "2024-01-17T10:30:00.000000Z",
        "updated_at": "2024-01-17T12:00:00.000000Z"
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 20,
      "total": 15
    }
  }
}
```

#### Business Logic Notes
- Returns all notifications for authenticated user
- Includes both read and unread notifications
- Ordered by creation date (newest first)
- Paginated with 20 per page
- `read_at` is null for unread notifications

---

### 2. Get Unread Count
**Endpoint:** `GET /api/notifications/unread-count`  
**Controller:** `NotificationController@unreadCount`  
**Middleware:** `auth:sanctum`  
**Description:** Get count of unread notifications

#### Headers
```
Authorization: Bearer {token}
```

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "unread_count": 5
  }
}
```

#### Business Logic Notes
- Returns count of notifications where read_at is null
- Useful for notification badges/indicators
- Fast query (count only, no data fetched)

---

### 3. Filter Notifications
**Endpoint:** `GET /api/notifications/filter`  
**Controller:** `NotificationController@filter`  
**Middleware:** `auth:sanctum`  
**Description:** Filter notifications by type, event, or read status

#### Headers
```
Authorization: Bearer {token}
```

#### Query Parameters
```
type: string (optional, enum: push|email)
event: string (optional)
read: boolean (optional)
page: integer (optional, default: 1)
```

#### Validation Rules
- `type`: nullable|in:push,email
- `event`: nullable|string
- `read`: nullable|boolean

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "data": [
      {
        "id": 3,
        "user_id": 1,
        "title": "Business Approved!",
        "message": "Congratulations! Your Glam Beauty Studio profile has been approved.",
        "type": "email",
        "event": "business_approved",
        "data": {
          "business_id": 1,
          "status": "approved",
          "deep_link": "/business/1"
        },
        "read_at": null,
        "created_at": "2024-01-17T09:00:00.000000Z"
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 20,
      "total": 3
    }
  }
}
```

#### Filter Examples
- **Unread notifications**: `?read=false`
- **Email notifications only**: `?type=email`
- **Order-related notifications**: `?event=order_created`
- **Read push notifications**: `?type=push&read=true`

#### Business Logic Notes
- All filters are optional
- Multiple filters can be combined
- Returns empty array if no matches
- Maintains pagination

---

### 4. Mark Notification as Read
**Endpoint:** `PATCH /api/notifications/{id}/read`  
**Controller:** `NotificationController@markAsRead`  
**Middleware:** `auth:sanctum`  
**Description:** Mark a specific notification as read

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `id`: Notification ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Notification marked as read",
  "data": {
    "id": 1,
    "user_id": 1,
    "title": "Order Confirmed!",
    "message": "Your order #5 has been confirmed and is being processed.",
    "type": "push",
    "event": "order_created",
    "read_at": "2024-01-17T14:30:00.000000Z",
    "created_at": "2024-01-17T11:00:00.000000Z",
    "updated_at": "2024-01-17T14:30:00.000000Z"
  }
}
```

#### Error Response (404)
```json
{
  "status": "error",
  "message": "Notification not found"
}
```

#### Business Logic Notes
- Sets `read_at` timestamp to current time
- User can only mark their own notifications
- Returns updated notification data
- Idempotent (can mark already-read notification)

---

### 5. Mark All Notifications as Read
**Endpoint:** `PATCH /api/notifications/mark-all-read`  
**Controller:** `NotificationController@markAllAsRead`  
**Middleware:** `auth:sanctum`  
**Description:** Mark all unread notifications as read

#### Headers
```
Authorization: Bearer {token}
```

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Marked 5 notifications as read"
}
```

#### Business Logic Notes
- Updates all unread notifications for user
- Sets `read_at` to current timestamp
- Returns count of updated notifications
- Useful for "mark all as read" button

---

### 6. Delete Notification
**Endpoint:** `DELETE /api/notifications/{id}`  
**Controller:** `NotificationController@destroy`  
**Middleware:** `auth:sanctum`  
**Description:** Delete a specific notification

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `id`: Notification ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Notification deleted"
}
```

#### Error Response (404)
```json
{
  "status": "error",
  "message": "Notification not found"
}
```

#### Business Logic Notes
- Permanently deletes notification
- User can only delete their own notifications
- Useful for clearing notification history

---

## Notification Types

### System Notification Events

#### Order Events
- **order_created**: Order confirmation
- **order_status_updated**: Order status changes
- **order_delivered**: Order delivered

#### Business Events
- **business_approved**: Business profile approved
- **business_rejected**: Business profile needs updates

#### Product Events
- **product_approved**: Product approved for sale
- **product_rejected**: Product rejected

#### Seller Events
- **seller_approved**: Seller profile approved
- **seller_rejected**: Seller profile rejected

#### Blog Events
- **blog_published**: New blog post published

#### Subscription Events
- **subscription_reminder**: Subscription expiring soon
- **subscription_expired**: Subscription expired

---

## Notification Structure

### Notification Fields
```json
{
  "id": "integer - Unique identifier",
  "user_id": "integer - Recipient user ID",
  "title": "string - Notification title",
  "message": "string - Notification message",
  "type": "string - Delivery type (push/email)",
  "event": "string - Event that triggered notification",
  "data": "json - Additional data (deep_link, IDs, etc)",
  "read_at": "timestamp - When marked as read (null if unread)",
  "created_at": "timestamp - When created",
  "updated_at": "timestamp - Last updated"
}
```

### Data Field Structure
The `data` field contains event-specific information:

**Order Notifications:**
```json
{
  "order_id": 5,
  "status": "shipped",
  "deep_link": "/orders/5"
}
```

**Business Notifications:**
```json
{
  "business_id": 1,
  "status": "approved",
  "deep_link": "/business/1"
}
```

**Blog Notifications:**
```json
{
  "blog_id": 3,
  "blog_slug": "new-post-title",
  "deep_link": "/blogs/new-post-title"
}
```

---

## Notification Preferences

### 7. Get Notification Preferences
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
- Returns default values if not set:
  - `email_notifications`: true
  - `push_notifications`: true
  - `sms_notifications`: false
  - `order_updates`: true
  - `promotional_emails`: true
  - `security_alerts`: true

---

### 8. Update Notification Preferences
**Endpoint:** `PUT /api/notifications/preferences`  
**Controller:** `NotificationPreferenceController@update`  
**Middleware:** `auth:sanctum`  
**Description:** Update notification preferences

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
All fields are optional:
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
- Partial updates supported
- Only provided fields are updated
- Returns only the fields that were updated
- Preferences stored in users table columns

---

## Preference Types

### Email Notifications
- **email_notifications**: Master toggle for all email notifications
- **promotional_emails**: Marketing and promotional content
- **order_updates**: Order status and shipping updates via email

### Push Notifications
- **push_notifications**: Master toggle for push notifications
- In-app and mobile push notifications

### SMS Notifications
- **sms_notifications**: SMS text message notifications
- Currently not implemented (reserved for future)

### Security Alerts
- **security_alerts**: Important account security notifications
- Cannot be fully disabled (critical alerts still sent)

---

## Notification Delivery

### Email Notifications
Sent via `NotificationService@sendEmailAndPush()`:
- Uses Laravel Mail with email templates
- Templates located in `resources/views/emails/`
- Templates:
  - `order_created.blade.php`
  - `order_status_updated.blade.php`
  - `business_approved.blade.php`
  - `subscription_reminder.blade.php`
  - `subscription_status.blade.php`

### Push Notifications
Stored in database via `NotificationService`:
- Created in `notifications` table
- Accessible via API endpoints
- Can be marked as read/deleted

### Notification Service
Located at `app/Services/NotificationService.php`:

**Methods:**
- `sendEmailAndPush($user, $subject, $view, $title, $message, $emailData, $pushData)`
- `sendPushToAllUsers($title, $message, $data)`

---

## Business Logic Summary

1. **User Isolation**: Users only see their own notifications
2. **Read Status**: Tracked via `read_at` timestamp
3. **Dual Delivery**: Email + Push via NotificationService
4. **Preferences**: Stored in user table columns
5. **Event-Based**: Triggered by specific application events
6. **Deep Links**: Notifications include app navigation links
7. **Filtering**: Support for type, event, and read status
8. **Batch Operations**: Mark all as read in one request
9. **Deletion**: Permanent removal from database
10. **Default Settings**: Sensible defaults for new users

---

## Integration Notes

### Triggering Notifications
Notifications are created automatically when:
- Orders are created or status changes
- Business/seller profiles approved/rejected
- Products approved/rejected
- Blog posts published
- Subscriptions expire or need renewal

### Email Templates
Email views follow consistent structure:
- Use `layout.blade.php` as base
- Include user name and action details
- Provide action buttons/links
- Respect user preferences

### Push Data Format
Push notifications should include:
```json
{
  "title": "Short title",
  "message": "Detailed message",
  "data": {
    "deep_link": "/path/to/content",
    "entity_id": 123,
    "entity_type": "order/product/business"
  }
}
```

### Preference Checking
Before sending notifications:
1. Check master toggles (email_notifications, push_notifications)
2. Check specific preferences (order_updates, promotional_emails)
3. Always send security_alerts regardless

---

## Common Scenarios

### New Order Flow
1. User creates order → `order_created` notification
2. Admin updates status → `order_status_updated` notification
3. Order delivered → System marks as delivered

### Seller Approval Flow
1. User creates seller profile → Pending status
2. Admin approves → `seller_approved` notification
3. User can now create products

### Business Approval Flow
1. User creates business → Pending status
2. Admin reviews and approves → `business_approved` notification
3. Business appears in marketplace

### Subscription Reminders
1. 7 days before expiry → `subscription_reminder` email
2. On expiry → `subscription_expired` notification
3. User prompted to renew
