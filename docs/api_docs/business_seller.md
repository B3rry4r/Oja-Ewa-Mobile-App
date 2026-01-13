# Business & Seller Profiles API Documentation

## Overview
Endpoints for managing seller profiles, business profiles, subscriptions, and related operations.

---

## Seller Profile Management

### 1. Get Seller Profile
**Endpoint:** `GET /api/seller/profile`  
**Controller:** `SellerProfileController@show`  
**Middleware:** `auth:sanctum`  
**Description:** Get authenticated user's seller profile with statistics

#### Headers
```
Authorization: Bearer {token}
```

#### Success Response (200)
```json
{
  "id": 1,
  "user_id": 1,
  "country": "Nigeria",
  "state": "Lagos",
  "city": "Ikeja",
  "address": "123 Business Street, Ikeja",
  "business_email": "business@example.com",
  "business_phone_number": "+2348012345678",
  "instagram": "@mybusiness",
  "facebook": "facebook.com/mybusiness",
  "identity_document": "spaces/identity_document/abc123.pdf",
  "business_name": "Adire Creations",
  "business_registration_number": "BN123456",
  "business_certificate": "spaces/business_certificate/xyz789.pdf",
  "business_logo": "spaces/logos/logo123.png",
  "bank_name": "GTBank",
  "account_number": "0123456789",
  "registration_status": "approved",
  "rejection_reason": null,
  "active": true,
  "created_at": "2024-01-10T08:00:00.000000Z",
  "updated_at": "2024-01-10T08:00:00.000000Z",
  "selling_since": "2024-01-10T08:00:00.000000Z",
  "total_sales": 450000.50,
  "avg_rating": 4.5
}
```

#### Error Response (404)
```json
{
  "message": "Seller profile not found"
}
```

#### Business Logic Notes
- `total_sales`: Sum of all paid orders containing seller's products
- `avg_rating`: Average rating from all product reviews
- `selling_since`: Seller profile creation date
- Only authenticated user can view their own seller profile

---

### 2. Create Seller Profile
**Endpoint:** `POST /api/seller/profile`  
**Controller:** `SellerProfileController@store`  
**Middleware:** `auth:sanctum`  
**Description:** Create a new seller profile

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "country": "string (required, max:255)",
  "state": "string (required, max:255)",
  "city": "string (required, max:255)",
  "address": "string (required)",
  "business_email": "string (required, email, max:255)",
  "business_phone_number": "string (required, max:255)",
  "instagram": "string (optional, max:255)",
  "facebook": "string (optional, max:255)",
  "identity_document": "string (optional, max:255)",
  "business_name": "string (required, max:255)",
  "business_registration_number": "string (required, max:255)",
  "business_certificate": "string (optional, max:255)",
  "business_logo": "string (optional, max:255)",
  "bank_name": "string (required, max:255)",
  "account_number": "string (required, max:255)"
}
```

#### Validation Rules
- `country`: required|string|max:255
- `state`: required|string|max:255
- `city`: required|string|max:255
- `address`: required|string
- `business_email`: required|email|max:255
- `business_phone_number`: required|string|max:255
- `instagram`: nullable|string|max:255
- `facebook`: nullable|string|max:255
- `identity_document`: nullable|string|max:255
- `business_name`: required|string|max:255
- `business_registration_number`: required|string|max:255
- `business_certificate`: nullable|string|max:255
- `business_logo`: nullable|string|max:255
- `bank_name`: required|string|max:255
- `account_number`: required|string|max:255

#### Success Response (201)
```json
{
  "id": 1,
  "user_id": 1,
  "country": "Nigeria",
  "state": "Lagos",
  "city": "Ikeja",
  "address": "123 Business Street, Ikeja",
  "business_email": "business@example.com",
  "business_phone_number": "+2348012345678",
  "business_name": "Adire Creations",
  "business_registration_number": "BN123456",
  "bank_name": "GTBank",
  "account_number": "0123456789",
  "registration_status": "pending",
  "active": true,
  "created_at": "2024-01-17T15:00:00.000000Z",
  "updated_at": "2024-01-17T15:00:00.000000Z"
}
```

#### Error Response (409)
```json
{
  "message": "User already has a seller profile"
}
```

#### Business Logic Notes
- User can only have one seller profile
- Default status is 'pending' (requires admin approval)
- Automatically associates with authenticated user
- Bank account details required for payments

---

### 3. Update Seller Profile
**Endpoint:** `PUT /api/seller/profile`  
**Controller:** `SellerProfileController@update`  
**Middleware:** `auth:sanctum`  
**Description:** Update existing seller profile

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
All fields are optional (partial update supported):
```json
{
  "country": "string (optional, max:255)",
  "state": "string (optional, max:255)",
  "city": "string (optional, max:255)",
  "address": "string (optional)",
  "business_email": "string (optional, email, max:255)",
  "business_phone_number": "string (optional, max:255)",
  "instagram": "string (optional, max:255)",
  "facebook": "string (optional, max:255)",
  "business_name": "string (optional, max:255)",
  "bank_name": "string (optional, max:255)",
  "account_number": "string (optional, max:255)"
}
```

#### Validation Rules
- All fields use 'sometimes|required' pattern
- Same validation as create, but all optional

#### Success Response (200)
```json
{
  "id": 1,
  "user_id": 1,
  "business_name": "Adire Creations Ltd",
  "business_email": "newemail@example.com",
  "updated_at": "2024-01-17T16:00:00.000000Z"
}
```

#### Error Response (404)
```json
{
  "message": "Seller profile not found"
}
```

---

### 4. Delete Seller Profile
**Endpoint:** `DELETE /api/seller/profile`  
**Controller:** `SellerProfileController@destroy`  
**Middleware:** `auth:sanctum`  
**Description:** Soft delete seller profile

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body (Optional)
```json
{
  "reason": "string (optional)"
}
```

#### Success Response (200)
```json
{
  "message": "Seller profile deleted successfully"
}
```

#### Business Logic Notes
- Soft delete (sets deleted_at timestamp)
- Optional reason field for tracking
- Products remain but cannot be edited
- Can be restored by admin if needed

---

### 5. Upload Seller Profile File
**Endpoint:** `POST /api/seller/profile/upload`  
**Controller:** `SellerProfileController@uploadFile`  
**Middleware:** `auth:sanctum`  
**Description:** Upload documents for seller profile

#### Headers
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

#### Request Body (Form Data)
```
file: file (required, max:10MB)
type: string (required, enum: identity_document|business_certificate|business_logo)
```

#### Validation Rules
- `file`: required|file|max:10240 (10MB)
- `type`: required|in:identity_document,business_certificate,business_logo

#### Success Response (200)
```json
{
  "message": "File uploaded successfully",
  "file_path": "spaces/identity_document/abc123xyz.pdf",
  "type": "identity_document"
}
```

#### Error Response (404)
```json
{
  "message": "Seller profile not found"
}
```

#### Business Logic Notes
- Files stored with unique ID prefix
- Updates corresponding field in seller profile
- File types: identity_document, business_certificate, business_logo
- Maximum file size: 10MB
- TODO: Actual upload to DigitalOcean Spaces

---

## Business Profile Management

### 6. List Business Profiles
**Endpoint:** `GET /api/business`  
**Controller:** `BusinessProfileController@index`  
**Middleware:** `auth:sanctum`  
**Description:** Get all business profiles for authenticated user

#### Headers
```
Authorization: Bearer {token}
```

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Business profiles retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "category": "beauty",
      "country": "Nigeria",
      "state": "Lagos",
      "city": "Lekki",
      "address": "456 Beauty Lane, Lekki",
      "business_email": "beauty@example.com",
      "business_phone_number": "+2348098765432",
      "business_name": "Glam Beauty Studio",
      "business_description": "Professional beauty services",
      "business_logo": "storage/logos/beauty_logo.png",
      "offering_type": "providing_service",
      "service_list": "[\"Makeup\", \"Hair Styling\", \"Nails\"]",
      "professional_title": "Professional Makeup Artist",
      "store_status": "approved",
      "subscription_status": "active",
      "subscription_ends_at": "2024-12-31",
      "created_at": "2024-01-10T09:00:00.000000Z",
      "updated_at": "2024-01-10T09:00:00.000000Z"
    }
  ]
}
```

#### Business Logic Notes
- Returns all business profiles for authenticated user
- User can have multiple business profiles (one per category)

---

### 7. Create Business Profile
**Endpoint:** `POST /api/business`  
**Controller:** `BusinessProfileController@store`  
**Middleware:** `auth:sanctum`  
**Description:** Create a new business profile

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body (from StoreBusinessProfileRequest)
```json
{
  "category": "string (required, enum: beauty|brand|school|music)",
  "country": "string (required, max:100)",
  "state": "string (required, max:100)",
  "city": "string (required, max:100)",
  "address": "string (required, max:255)",
  "business_email": "string (required, email, max:100)",
  "business_phone_number": "string (required, max:20)",
  "website_url": "string (optional, url, max:255)",
  "instagram": "string (optional, max:100)",
  "facebook": "string (optional, max:100)",
  "identity_document": "string (optional, max:255)",
  "business_name": "string (required, max:100)",
  "business_description": "string (required, max:1000)",
  "business_logo": "string (optional, max:255)",
  "offering_type": "string (optional, enum: selling_product|providing_service)",
  "product_list": "json (optional, required if offering_type=selling_product)",
  "service_list": "json (optional, required if offering_type=providing_service)",
  "business_certificates": "json (optional, required if offering_type=selling_product)",
  "professional_title": "string (optional, required if offering_type=providing_service, max:100)",
  "school_type": "string (optional, required if category=school, enum: fashion|music|catering|beauty)",
  "school_biography": "string (optional, required if category=school, max:1000)",
  "classes_offered": "json (optional, required if category=school)",
  "music_category": "string (optional, required if category=music, enum: dj|artist|producer)",
  "youtube": "string (optional, max:255)",
  "spotify": "string (optional, max:255)"
}
```

#### Conditional Validation Rules

**For `offering_type: providing_service`:**
- `service_list`: required|json
- `professional_title`: required|string|max:100

**For `offering_type: selling_product`:**
- `product_list`: required|json
- `business_certificates`: required|json

**For `category: school`:**
- `school_type`: required|in:fashion,music,catering,beauty
- `school_biography`: required|string|max:1000
- `classes_offered`: required|json

**For `category: music`:**
- `music_category`: required|in:dj,artist,producer
- `identity_document`: required|string|max:255
- `youtube` OR `spotify`: At least one required

#### Success Response (201)
```json
{
  "status": "success",
  "message": "Business profile created successfully",
  "data": {
    "id": 2,
    "user_id": 1,
    "category": "music",
    "business_name": "DJ Vibes Entertainment",
    "music_category": "dj",
    "youtube": "youtube.com/@djvibes",
    "spotify": "spotify.com/artist/djvibes",
    "store_status": "pending",
    "created_at": "2024-01-17T17:00:00.000000Z"
  }
}
```

#### Error Response (422)
```json
{
  "message": "You already have a business in this category."
}
```

#### Custom Validation Messages
- "At least one music platform link (YouTube or Spotify) is required for music businesses."

#### Business Logic Notes
- User cannot have multiple businesses in same category
- Different validation rules based on category and offering_type
- Default status is 'pending' (requires admin approval)
- File uploads handled via separate upload endpoint

---

### 8. Get Business Profile
**Endpoint:** `GET /api/business/{id}`  
**Controller:** `BusinessProfileController@show`  
**Middleware:** `auth:sanctum`  
**Description:** Get specific business profile details

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `id`: Business Profile ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Business profile retrieved successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "category": "beauty",
    "business_name": "Glam Beauty Studio",
    "business_description": "Professional beauty services including makeup, hair styling, and nail care",
    "offering_type": "providing_service",
    "service_list": "[\"Makeup\", \"Hair Styling\", \"Nails\", \"Spa Services\"]",
    "professional_title": "Professional Makeup Artist",
    "store_status": "approved",
    "subscription_status": "active"
  }
}
```

#### Error Response (403)
```json
{
  "message": "Unauthorized access to this business profile"
}
```

#### Business Logic Notes
- User can only view their own business profiles
- Authorization checked in controller

---

### 9. Update Business Profile
**Endpoint:** `PUT /api/business/{id}`  
**Controller:** `BusinessProfileController@update`  
**Middleware:** `auth:sanctum`  
**Description:** Update existing business profile

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `id`: Business Profile ID (integer)

#### Request Body (from UpdateBusinessProfileRequest)
All fields optional (partial update):
```json
{
  "category": "string (optional, enum: beauty|brand|school|music)",
  "business_name": "string (optional, max:100)",
  "business_description": "string (optional, max:1000)",
  "business_email": "string (optional, email, max:100)",
  "business_phone_number": "string (optional, max:20)",
  "website_url": "string (optional, url, max:255)",
  "instagram": "string (optional, max:100)",
  "facebook": "string (optional, max:100)"
}
```

#### Validation Rules
- All fields use 'sometimes|required' pattern
- Conditional validations apply based on category and offering_type
- Fetches existing business profile to determine context

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Business profile updated successfully",
  "data": {
    "id": 1,
    "business_name": "Glam Beauty Studio - Updated",
    "business_description": "New updated description",
    "updated_at": "2024-01-17T18:00:00.000000Z"
  }
}
```

#### Error Response (403)
```json
{
  "message": "Unauthorized access to this business profile"
}
```

---

### 10. Delete Business Profile
**Endpoint:** `DELETE /api/business/{id}`  
**Controller:** `BusinessProfileController@destroy`  
**Middleware:** `auth:sanctum`  
**Description:** Soft delete business profile

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `id`: Business Profile ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Business profile deleted successfully"
}
```

#### Business Logic Notes
- Soft delete (sets deleted_at timestamp)
- User can only delete their own profiles

---

### 11. Deactivate Business Profile
**Endpoint:** `PATCH /api/business/{id}/deactivate`  
**Controller:** `BusinessProfileController@deactivate`  
**Middleware:** `auth:sanctum`  
**Description:** Temporarily deactivate business profile

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `id`: Business Profile ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Business profile deactivated successfully",
  "data": {
    "id": 1,
    "store_status": "deactivated",
    "updated_at": "2024-01-17T18:30:00.000000Z"
  }
}
```

#### Business Logic Notes
- Sets store_status to 'deactivated'
- Profile remains in database
- Can be reactivated by admin

---

### 12. Upload Business Profile File
**Endpoint:** `POST /api/business/{id}/upload`  
**Controller:** `BusinessProfileController@upload`  
**Middleware:** `auth:sanctum`  
**Description:** Upload files for business profile

#### Headers
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

#### URL Parameters
- `id`: Business Profile ID (integer)

#### Request Body (Form Data)
```
file: file (required, max:10MB)
file_type: string (required, enum: business_logo|business_certificates|identity_document)
```

#### Validation Rules
- `file`: required|file|max:10240 (10MB)
- `file_type`: required|in:business_logo,business_certificates,identity_document

#### Success Response (200)
```json
{
  "status": "success",
  "message": "File uploaded successfully",
  "data": {
    "file_path": "storage/business_logos/xyz789.png",
    "file_type": "business_logo"
  }
}
```

#### Business Logic Notes
- Files stored in public storage
- Path format varies by file type
- Certificates stored as JSON array
- Updates corresponding field in business profile

---

## Subscription Management

### 13. Update Business Subscription
**Endpoint:** `PUT /api/business/subscription`  
**Controller:** `SubscriptionController@update`  
**Middleware:** `auth:sanctum`  
**Description:** Manage business subscription plans

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "business_id": "integer (required, exists:business_profiles,id)",
  "subscription_type": "string (required, enum: basic|premium|enterprise)",
  "billing_cycle": "string (required, enum: monthly|quarterly|yearly)"
}
```

#### Validation Rules
- `business_id`: required|integer|exists:business_profiles,id
- `subscription_type`: required|in:basic,premium,enterprise
- `billing_cycle`: required|in:monthly,quarterly,yearly

#### Subscription Pricing (NGN)

**Basic Plan:**
- Monthly: ₦50.00 (5,000 kobo)
- Quarterly: ₦135.00 (10% discount)
- Yearly: ₦480.00 (20% discount)

**Premium Plan:**
- Monthly: ₦100.00
- Quarterly: ₦270.00 (10% discount)
- Yearly: ₦960.00 (20% discount)

**Enterprise Plan:**
- Monthly: ₦200.00
- Quarterly: ₦540.00 (10% discount)
- Yearly: ₦1,920.00 (20% discount)

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Business subscription updated successfully",
  "data": {
    "business_id": 1,
    "subscription_type": "premium",
    "subscription_status": "active",
    "billing_cycle": "yearly",
    "amount": 96000,
    "currency": "NGN",
    "next_billing_date": "2025-01-17",
    "features": {
      "max_products": 200,
      "max_photos_per_product": 10,
      "analytics_access": true,
      "priority_support": true,
      "advanced_promotion": true
    }
  }
}
```

#### Subscription Features

**Basic:**
- Max Products: 50
- Photos per Product: 5
- Analytics: No
- Priority Support: No
- Advanced Promotion: No

**Premium:**
- Max Products: 200
- Photos per Product: 10
- Analytics: Yes
- Priority Support: Yes
- Advanced Promotion: Yes

**Enterprise:**
- Max Products: 1000
- Photos per Product: 20
- Analytics: Yes
- Priority Support: Yes
- Advanced Promotion: Yes
- Custom Branding: Yes
- API Access: Yes

#### Business Logic Notes
- Business must belong to authenticated user
- Calculates next billing date based on cycle
- Updates subscription_status to 'active'
- Subscription amount stored in kobo
- Returns feature list for selected plan

---

## Status Values

### Seller Registration Status
- `pending`: Awaiting admin approval
- `approved`: Active seller
- `rejected`: Application denied

### Business Store Status
- `pending`: Awaiting admin approval
- `approved`: Active business
- `deactivated`: Temporarily inactive

### Subscription Status
- `active`: Subscription active
- `expired`: Subscription expired

### Business Categories
- `beauty`: Beauty services/products
- `brand`: Fashion brands
- `school`: Educational institutions
- `music`: Music entertainment

### Offering Types
- `selling_product`: Selling physical products
- `providing_service`: Providing services

---

## Business Logic Summary

1. **One Seller Profile Per User**: Users can only create one seller profile
2. **Multiple Business Profiles**: Users can have one business per category
3. **Admin Approval Required**: Both seller and business profiles require approval
4. **Conditional Validation**: Rules vary by category and offering type
5. **Soft Deletes**: Profiles can be deleted but data preserved
6. **File Upload Limits**: 10MB maximum file size
7. **Subscription Tiers**: Three tiers with increasing features
8. **Discount Structure**: 10% quarterly, 20% yearly
9. **Bank Details Required**: For seller payments
10. **Status Management**: Active/inactive toggles for profiles
