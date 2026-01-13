# Complete Guide - 16 New Endpoints

## Overview
This document provides detailed request/response examples for all 16 newly implemented endpoints.

**Date Added:** January 2024  
**Total Endpoints:** 16 (9 public + 7 authenticated)

---

# Part 1: Public Business Profiles

## 1. Browse All Businesses (Public)

### Endpoint Details
- **Method:** GET
- **URL:** `/api/business/public`
- **Authentication:** None (Public)
- **Description:** List all approved business profiles with optional filters

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| category | string | No | Filter by: beauty, brand, school, music |
| offering_type | string | No | Filter by: selling_product, providing_service |
| per_page | integer | No | Items per page (default: 15, max: 50) |
| page | integer | No | Page number (default: 1) |

### Request Example
```http
GET /api/business/public?category=beauty&offering_type=providing_service&per_page=10 HTTP/1.1
Host: your-api.com
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Public business profiles retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 25,
        "category": "beauty",
        "country": "Nigeria",
        "state": "Lagos",
        "city": "Lekki",
        "address": "45 Beauty Lane, Lekki Phase 1",
        "business_email": "glambeauty@example.com",
        "business_phone_number": "+2348012345678",
        "website_url": "https://glambeauty.com",
        "instagram": "@glambeautystudio",
        "facebook": "facebook.com/glambeauty",
        "business_name": "Glam Beauty Studio",
        "business_description": "Professional beauty services including hair, makeup, and spa treatments",
        "business_logo": "storage/logos/glam_logo.png",
        "offering_type": "providing_service",
        "service_list": "[\"Hair Styling\", \"Makeup Application\", \"Spa Services\"]",
        "professional_title": "Licensed Cosmetologist & Makeup Artist",
        "store_status": "approved",
        "subscription_status": "active",
        "subscription_ends_at": "2024-12-31",
        "created_at": "2024-01-10T09:00:00.000000Z",
        "updated_at": "2024-01-10T09:00:00.000000Z",
        "user": {
          "id": 25,
          "firstname": "Jane",
          "lastname": "Doe"
        }
      }
    ],
    "links": {
      "first": "https://api.example.com/api/business/public?page=1",
      "last": "https://api.example.com/api/business/public?page=5",
      "prev": null,
      "next": "https://api.example.com/api/business/public?page=2"
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 5,
      "path": "https://api.example.com/api/business/public",
      "per_page": 10,
      "to": 10,
      "total": 47
    }
  }
}
```

### Empty Response (200 OK)
```json
{
  "status": "success",
  "message": "Public business profiles retrieved successfully",
  "data": {
    "data": [],
    "links": {...},
    "meta": {
      "current_page": 1,
      "per_page": 10,
      "total": 0
    }
  }
}
```

### Error Response (422 Validation Error)
```json
{
  "message": "The category field must be one of: beauty, brand, school, music.",
  "errors": {
    "category": ["The category field must be one of: beauty, brand, school, music."]
  }
}
```

---

## 2. View Single Business (Public)

### Endpoint Details
- **Method:** GET
- **URL:** `/api/business/public/{id}`
- **Authentication:** None (Public)
- **Description:** View detailed information about a specific approved business

### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | Business Profile ID |

### Request Example
```http
GET /api/business/public/1 HTTP/1.1
Host: your-api.com
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Business profile retrieved successfully",
  "data": {
    "id": 1,
    "user_id": 25,
    "category": "beauty",
    "country": "Nigeria",
    "state": "Lagos",
    "city": "Lekki",
    "address": "45 Beauty Lane, Lekki Phase 1",
    "business_email": "glambeauty@example.com",
    "business_phone_number": "+2348012345678",
    "website_url": "https://glambeauty.com",
    "instagram": "@glambeautystudio",
    "facebook": "facebook.com/glambeauty",
    "business_name": "Glam Beauty Studio",
    "business_description": "Professional beauty services including hair, makeup, and spa treatments",
    "business_logo": "storage/logos/glam_logo.png",
    "offering_type": "providing_service",
    "service_list": "[\"Hair Styling\",\"Makeup Application\",\"Spa Services\",\"Nail Services\"]",
    "professional_title": "Licensed Cosmetologist & Makeup Artist",
    "store_status": "approved",
    "subscription_status": "active",
    "subscription_ends_at": "2024-12-31",
    "created_at": "2024-01-10T09:00:00.000000Z",
    "updated_at": "2024-01-10T09:00:00.000000Z",
    "user": {
      "id": 25,
      "firstname": "Jane",
      "lastname": "Doe"
    }
  }
}
```

### Error Response (404 Not Found)
```json
{
  "message": "No query results for model [App\\Models\\BusinessProfile] 999"
}
```

**Note:** Only businesses with `store_status: approved` can be viewed publicly.

---

**End of Part 1**
**Continue to Part 2 for Product endpoints...**

# Part 2: Public Product Browsing

## 3. Browse Products (Public)

### Endpoint Details
- **Method:** GET
- **URL:** `/api/products/browse`
- **Authentication:** None (Public)
- **Description:** Search, filter, and sort approved products

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| q | string | No | Search in name and description |
| gender | string | No | Filter by: male, female, unisex |
| style | string | No | Filter by style (partial match) |
| tribe | string | No | Filter by tribe (partial match) |
| price_min | decimal | No | Minimum price |
| price_max | decimal | No | Maximum price |
| sort | string | No | Sort by: price_asc, price_desc, newest, popular |
| per_page | integer | No | Items per page (default: 10, max: 50) |
| page | integer | No | Page number (default: 1) |

### Request Example
```http
GET /api/products/browse?q=ankara&gender=female&price_min=10000&price_max=30000&sort=price_asc&per_page=20 HTTP/1.1
Host: your-api.com
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "data": {
    "data": [
      {
        "id": 3,
        "seller_profile_id": 2,
        "name": "Ankara Print Dress",
        "gender": "female",
        "style": "Modern",
        "tribe": "Yoruba",
        "description": "Beautiful Ankara print dress perfect for special occasions",
        "image": "https://example.com/images/ankara-dress.jpg",
        "size": "S, M, L, XL",
        "processing_time_type": "normal",
        "processing_days": 7,
        "price": 18000.00,
        "status": "approved",
        "created_at": "2024-01-16T11:00:00.000000Z",
        "updated_at": "2024-01-16T11:00:00.000000Z",
        "seller_profile": {
          "id": 2,
          "business_name": "Fashion House Lagos"
        }
      },
      {
        "id": 7,
        "seller_profile_id": 3,
        "name": "Ankara Kaftan",
        "gender": "unisex",
        "style": "Traditional",
        "tribe": "Mixed",
        "description": "Elegant Ankara kaftan for men and women",
        "image": "https://example.com/images/kaftan.jpg",
        "size": "One Size Fits All",
        "processing_time_type": "quick_quick",
        "processing_days": 3,
        "price": 22000.00,
        "status": "approved",
        "created_at": "2024-01-14T08:00:00.000000Z",
        "updated_at": "2024-01-14T08:00:00.000000Z",
        "seller_profile": {
          "id": 3,
          "business_name": "Adire Creations"
        }
      }
    ],
    "links": {
      "first": "https://api.example.com/api/products/browse?page=1",
      "last": "https://api.example.com/api/products/browse?page=8",
      "prev": null,
      "next": "https://api.example.com/api/products/browse?page=2"
    },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 8,
      "path": "https://api.example.com/api/products/browse",
      "per_page": 20,
      "to": 20,
      "total": 156
    }
  }
}
```

### Error Response (422 Validation Error)
```json
{
  "message": "The gender field must be one of: male, female, unisex.",
  "errors": {
    "gender": ["The gender field must be one of: male, female, unisex."]
  }
}
```

---

## 4. Get Product Filters (Public)

### Endpoint Details
- **Method:** GET
- **URL:** `/api/products/filters`
- **Authentication:** None (Public)
- **Description:** Get all available filter values for building UI filters

### Request Example
```http
GET /api/products/filters HTTP/1.1
Host: your-api.com
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "data": {
    "genders": [
      "male",
      "female",
      "unisex"
    ],
    "styles": [
      "Traditional",
      "Modern",
      "Casual",
      "Formal",
      "Contemporary"
    ],
    "tribes": [
      "Yoruba",
      "Igbo",
      "Hausa",
      "Mixed",
      "Pan-African"
    ],
    "price_range": {
      "min": 5000.00,
      "max": 150000.00
    },
    "sort_options": [
      {
        "value": "newest",
        "label": "Newest First"
      },
      {
        "value": "price_asc",
        "label": "Price: Low to High"
      },
      {
        "value": "price_desc",
        "label": "Price: High to Low"
      },
      {
        "value": "popular",
        "label": "Most Popular"
      }
    ]
  }
}
```

---

## 5. View Single Product (Public)

### Endpoint Details
- **Method:** GET
- **URL:** `/api/products/public/{id}`
- **Authentication:** None (Public)
- **Description:** View detailed product information with suggestions

### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | Product ID |

### Request Example
```http
GET /api/products/public/3 HTTP/1.1
Host: your-api.com
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "data": {
    "product": {
      "id": 3,
      "seller_profile_id": 2,
      "name": "Ankara Print Dress",
      "gender": "female",
      "style": "Modern",
      "tribe": "Yoruba",
      "description": "Beautiful Ankara print dress perfect for special occasions. Made with high-quality fabric and excellent tailoring.",
      "image": "https://example.com/images/ankara-dress.jpg",
      "size": "S, M, L, XL",
      "processing_time_type": "normal",
      "processing_days": 7,
      "price": 18000.00,
      "status": "approved",
      "created_at": "2024-01-16T11:00:00.000000Z",
      "updated_at": "2024-01-16T11:00:00.000000Z",
      "avg_rating": 4.5,
      "seller_profile": {
        "id": 2,
        "business_name": "Fashion House Lagos",
        "business_email": "fashion@example.com",
        "city": "Lagos",
        "state": "Lagos"
      },
      "reviews": [
        {
          "id": 1,
          "user_id": 10,
          "reviewable_id": 3,
          "reviewable_type": "App\\Models\\Product",
          "rating": 5,
          "headline": "Excellent Quality!",
          "body": "The fabric quality is superb and the tailoring is perfect. Highly recommend!",
          "created_at": "2024-01-17T09:00:00.000000Z",
          "user": {
            "id": 10,
            "firstname": "Mary",
            "lastname": "Johnson"
          }
        },
        {
          "id": 2,
          "user_id": 15,
          "reviewable_id": 3,
          "reviewable_type": "App\\Models\\Product",
          "rating": 4,
          "headline": "Beautiful dress",
          "body": "Love the design and colors. Fits perfectly!",
          "created_at": "2024-01-18T14:00:00.000000Z",
          "user": {
            "id": 15,
            "firstname": "Sarah",
            "lastname": "Williams"
          }
        }
      ]
    },
    "suggestions": [
      {
        "id": 5,
        "seller_profile_id": 2,
        "name": "Ankara Skirt and Blouse",
        "gender": "female",
        "style": "Modern",
        "tribe": "Yoruba",
        "price": 20000.00,
        "image": "https://example.com/images/skirt-blouse.jpg",
        "status": "approved",
        "seller_profile": {
          "id": 2,
          "business_name": "Fashion House Lagos"
        }
      },
      {
        "id": 9,
        "seller_profile_id": 4,
        "name": "Traditional Yoruba Dress",
        "gender": "female",
        "style": "Traditional",
        "tribe": "Yoruba",
        "price": 25000.00,
        "image": "https://example.com/images/trad-dress.jpg",
        "status": "approved",
        "seller_profile": {
          "id": 4,
          "business_name": "Aso Oke Boutique"
        }
      }
    ]
  }
}
```

### Error Response (404 Not Found)
```json
{
  "message": "No query results for model [App\\Models\\Product] 999"
}
```

---


# Part 3: Public Sustainability & Adverts

## 6. List Sustainability Initiatives (Public)

### Endpoint Details
- **Method:** GET
- **URL:** `/api/sustainability`
- **Authentication:** None (Public)
- **Description:** List all active sustainability initiatives

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| category | string | No | Filter by: environmental, social, economic, governance |
| per_page | integer | No | Items per page (default: 10, max: 50) |
| page | integer | No | Page number (default: 1) |

### Request Example
```http
GET /api/sustainability?category=environmental&per_page=5 HTTP/1.1
Host: your-api.com
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Sustainability initiatives retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "title": "Zero Waste Fashion Initiative",
        "description": "Promoting sustainable fashion practices and reducing textile waste through education and partnerships with local artisans.",
        "image_url": "https://example.com/sustainability/zero-waste.jpg",
        "category": "environmental",
        "status": "active",
        "target_amount": 1000000.00,
        "current_amount": 350000.00,
        "impact_metrics": "200 artisans trained, 50 tons CO2 reduced",
        "start_date": "2024-01-01",
        "end_date": "2024-12-31",
        "partners": "[\"Green Fashion NGO\", \"Ministry of Environment\", \"Local Artisan Association\"]",
        "participant_count": 150,
        "progress_notes": "Great progress! Currently at 35% of our fundraising target.",
        "created_by": 1,
        "created_at": "2024-01-01T10:00:00.000000Z",
        "updated_at": "2024-01-15T14:30:00.000000Z",
        "progress_percentage": 35.00,
        "admin": {
          "id": 1,
          "firstname": "Admin",
          "lastname": "User"
        }
      }
    ],
    "links": {...},
    "meta": {
      "current_page": 1,
      "per_page": 5,
      "total": 12
    }
  }
}
```

### Error Response (422 Validation Error)
```json
{
  "message": "The category field must be one of: environmental, social, economic, governance.",
  "errors": {
    "category": ["The category field must be one of: environmental, social, economic, governance."]
  }
}
```

---

## 7. View Single Initiative (Public)

### Endpoint Details
- **Method:** GET
- **URL:** `/api/sustainability/{id}`
- **Authentication:** None (Public)
- **Description:** View detailed information about a sustainability initiative

### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | Initiative ID |

### Request Example
```http
GET /api/sustainability/1 HTTP/1.1
Host: your-api.com
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Sustainability initiative retrieved successfully",
  "data": {
    "id": 1,
    "title": "Zero Waste Fashion Initiative",
    "description": "Promoting sustainable fashion practices and reducing textile waste through education and partnerships with local artisans. Our goal is to train 500 artisans in sustainable practices by end of year.",
    "image_url": "https://example.com/sustainability/zero-waste.jpg",
    "category": "environmental",
    "status": "active",
    "target_amount": 1000000.00,
    "current_amount": 350000.00,
    "impact_metrics": "200 artisans trained, 50 tons CO2 reduced, 1000 garments upcycled",
    "start_date": "2024-01-01",
    "end_date": "2024-12-31",
    "partners": "[\"Green Fashion NGO\", \"Ministry of Environment\", \"Local Artisan Association\"]",
    "participant_count": 150,
    "progress_notes": "Great progress! Currently at 35% of our fundraising target. More artisans joining every week.",
    "created_by": 1,
    "created_at": "2024-01-01T10:00:00.000000Z",
    "updated_at": "2024-01-15T14:30:00.000000Z",
    "progress_percentage": 35.00,
    "admin": {
      "id": 1,
      "firstname": "Admin",
      "lastname": "User"
    }
  }
}
```

### Error Response (404 Not Found)
```json
{
  "message": "No query results for model [App\\Models\\SustainabilityInitiative] 999"
}
```

**Note:** Only initiatives with `status: active` are publicly visible.

---

## 8. List Adverts (Public)

### Endpoint Details
- **Method:** GET
- **URL:** `/api/adverts`
- **Authentication:** None (Public)
- **Description:** List all active advertisements

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| position | string | No | Filter by: banner, sidebar, footer, popup |
| per_page | integer | No | Items per page (default: 10, max: 50) |
| page | integer | No | Page number (default: 1) |

### Request Example
```http
GET /api/adverts?position=banner HTTP/1.1
Host: your-api.com
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Adverts retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "title": "Summer Fashion Sale",
        "description": "Get 50% off all summer collection items. Limited time offer!",
        "image_url": "https://example.com/ads/summer-sale.jpg",
        "action_url": "https://example.com/sales/summer",
        "position": "banner",
        "status": "active",
        "priority": 10,
        "start_date": "2024-01-15",
        "end_date": "2024-02-28",
        "created_at": "2024-01-10T08:00:00.000000Z",
        "updated_at": "2024-01-10T08:00:00.000000Z"
      },
      {
        "id": 2,
        "title": "New Sellers Welcome",
        "description": "Register as a seller today and get your first month free!",
        "image_url": "https://example.com/ads/seller-promo.jpg",
        "action_url": "https://example.com/seller/register",
        "position": "banner",
        "status": "active",
        "priority": 8,
        "start_date": null,
        "end_date": null,
        "created_at": "2024-01-05T10:00:00.000000Z",
        "updated_at": "2024-01-05T10:00:00.000000Z"
      }
    ],
    "links": {...},
    "meta": {
      "current_page": 1,
      "per_page": 10,
      "total": 8
    }
  }
}
```

**Note:** Adverts are ordered by `priority` (highest first), and only active ads within their date range are shown.

---

## 9. View Single Advert (Public)

### Endpoint Details
- **Method:** GET
- **URL:** `/api/adverts/{id}`
- **Authentication:** None (Public)
- **Description:** View single advertisement details

### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | Advert ID |

### Request Example
```http
GET /api/adverts/1 HTTP/1.1
Host: your-api.com
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Advert retrieved successfully",
  "data": {
    "id": 1,
    "title": "Summer Fashion Sale",
    "description": "Get 50% off all summer collection items. Limited time offer!",
    "image_url": "https://example.com/ads/summer-sale.jpg",
    "action_url": "https://example.com/sales/summer",
    "position": "banner",
    "status": "active",
    "priority": 10,
    "start_date": "2024-01-15",
    "end_date": "2024-02-28",
    "created_at": "2024-01-10T08:00:00.000000Z",
    "updated_at": "2024-01-10T08:00:00.000000Z"
  }
}
```

### Error Response (404 Not Found)
```json
{
  "message": "No query results for model [App\\Models\\Advert] 999"
}
```

---


# Part 4: Authenticated User Features

## 10. User Logout

### Endpoint Details
- **Method:** POST
- **URL:** `/api/logout`
- **Authentication:** Required (`auth:sanctum`)
- **Description:** Logout user and revoke current access token

### Headers
```
Authorization: Bearer {token}
Accept: application/json
```

### Request Example
```http
POST /api/logout HTTP/1.1
Host: your-api.com
Authorization: Bearer 1|aBcDeFgHiJkLmNoPqRsTuVwXyZ
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Logged out successfully"
}
```

### Error Response (401 Unauthorized)
```json
{
  "message": "Unauthenticated."
}
```

**Note:** Only revokes the current token. Other active sessions remain valid.

---

## 11. Cancel Order

### Endpoint Details
- **Method:** POST
- **URL:** `/api/orders/{id}/cancel`
- **Authentication:** Required (`auth:sanctum`)
- **Description:** Cancel a pending or processing order

### Headers
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | Order ID |

### Request Body
```json
{
  "cancellation_reason": "string (required, max: 500)"
}
```

### Validation Rules
- `cancellation_reason`: required|string|max:500

### Request Example
```http
POST /api/orders/5/cancel HTTP/1.1
Host: your-api.com
Authorization: Bearer 1|aBcDeFgHiJkLmNoPqRsTuVwXyZ
Content-Type: application/json

{
  "cancellation_reason": "Found a better deal elsewhere"
}
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Order cancelled successfully",
  "data": {
    "id": 5,
    "user_id": 1,
    "total_price": 45000.00,
    "status": "cancelled",
    "payment_reference": "ORDER_20240117_ABC123",
    "tracking_number": null,
    "cancellation_reason": "Found a better deal elsewhere",
    "delivered_at": null,
    "created_at": "2024-01-17T10:00:00.000000Z",
    "updated_at": "2024-01-20T14:30:00.000000Z"
  }
}
```

### Error Response (400 Bad Request)
```json
{
  "status": "error",
  "message": "Cannot cancel order with status 'shipped'. Only pending or processing orders can be cancelled."
}
```

### Error Response (404 Not Found)
```json
{
  "message": "No query results for model [App\\Models\\Order] 999"
}
```

### Error Response (422 Validation Error)
```json
{
  "message": "The cancellation reason field is required.",
  "errors": {
    "cancellation_reason": ["The cancellation reason field is required."]
  }
}
```

**Business Rules:**
- Only order owner can cancel
- Can only cancel orders with status: `pending` or `processing`
- Cannot cancel: `paid`, `shipped`, `delivered`, or already `cancelled` orders
- Sends email and push notification to user
- Cancellation reason is stored for record-keeping

---


# Part 5: Shopping Cart System

## 12. Get User's Cart

### Endpoint Details
- **Method:** GET
- **URL:** `/api/cart`
- **Authentication:** Required (`auth:sanctum`)
- **Description:** Get current user's shopping cart with all items

### Headers
```
Authorization: Bearer {token}
Accept: application/json
```

### Request Example
```http
GET /api/cart HTTP/1.1
Host: your-api.com
Authorization: Bearer 1|aBcDeFgHiJkLmNoPqRsTuVwXyZ
Accept: application/json
```

### Success Response (200 OK) - With Items
```json
{
  "status": "success",
  "data": {
    "cart_id": 1,
    "items": [
      {
        "id": 1,
        "cart_id": 1,
        "product_id": 3,
        "quantity": 2,
        "unit_price": 18000.00,
        "created_at": "2024-01-20T10:00:00.000000Z",
        "updated_at": "2024-01-20T10:00:00.000000Z",
        "subtotal": 36000.00,
        "product": {
          "id": 3,
          "seller_profile_id": 2,
          "name": "Ankara Print Dress",
          "gender": "female",
          "style": "Modern",
          "tribe": "Yoruba",
          "description": "Beautiful Ankara print dress",
          "image": "https://example.com/images/ankara-dress.jpg",
          "size": "S, M, L, XL",
          "price": 18000.00,
          "status": "approved",
          "seller_profile": {
            "id": 2,
            "business_name": "Fashion House Lagos"
          }
        }
      },
      {
        "id": 2,
        "cart_id": 1,
        "product_id": 5,
        "quantity": 1,
        "unit_price": 15000.00,
        "created_at": "2024-01-20T10:05:00.000000Z",
        "updated_at": "2024-01-20T10:05:00.000000Z",
        "subtotal": 15000.00,
        "product": {
          "id": 5,
          "seller_profile_id": 1,
          "name": "Aso Oke Gele",
          "gender": "female",
          "style": "Traditional",
          "tribe": "Yoruba",
          "description": "Authentic hand-woven Aso Oke",
          "image": "https://example.com/images/gele.jpg",
          "size": "One Size",
          "price": 15000.00,
          "status": "approved",
          "seller_profile": {
            "id": 1,
            "business_name": "Adire Creations"
          }
        }
      }
    ],
    "total": 51000.00,
    "items_count": 3
  }
}
```

### Success Response (200 OK) - Empty Cart
```json
{
  "status": "success",
  "data": {
    "cart_id": 1,
    "items": [],
    "total": 0,
    "items_count": 0
  }
}
```

**Note:** Cart is automatically created if user doesn't have one.

---

## 13. Add Item to Cart

### Endpoint Details
- **Method:** POST
- **URL:** `/api/cart/items`
- **Authentication:** Required (`auth:sanctum`)
- **Description:** Add a product to cart or increase quantity if already exists

### Headers
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### Request Body
```json
{
  "product_id": "integer (required, must exist and be approved)",
  "quantity": "integer (required, min: 1)"
}
```

### Validation Rules
- `product_id`: required|exists:products,id
- `quantity`: required|integer|min:1

### Request Example
```http
POST /api/cart/items HTTP/1.1
Host: your-api.com
Authorization: Bearer 1|aBcDeFgHiJkLmNoPqRsTuVwXyZ
Content-Type: application/json

{
  "product_id": 7,
  "quantity": 2
}
```

### Success Response (201 Created) - New Item
```json
{
  "status": "success",
  "message": "Item added to cart",
  "data": {
    "cart_item": {
      "id": 3,
      "cart_id": 1,
      "product_id": 7,
      "quantity": 2,
      "unit_price": 25000.00,
      "created_at": "2024-01-20T11:00:00.000000Z",
      "updated_at": "2024-01-20T11:00:00.000000Z",
      "subtotal": 50000.00,
      "product": {
        "id": 7,
        "name": "Traditional Agbada Set",
        "gender": "male",
        "price": 25000.00,
        "image": "https://example.com/images/agbada.jpg",
        "status": "approved",
        "seller_profile": {
          "id": 3,
          "business_name": "Lagos Fashion"
        }
      }
    },
    "cart_total": 101000.00,
    "items_count": 5
  }
}
```

### Success Response (201 Created) - Existing Item (Quantity Increased)
```json
{
  "status": "success",
  "message": "Item added to cart",
  "data": {
    "cart_item": {
      "id": 1,
      "cart_id": 1,
      "product_id": 3,
      "quantity": 4,
      "unit_price": 18000.00,
      "created_at": "2024-01-20T10:00:00.000000Z",
      "updated_at": "2024-01-20T11:15:00.000000Z",
      "subtotal": 72000.00,
      "product": {
        "id": 3,
        "name": "Ankara Print Dress",
        "image": "https://example.com/images/ankara-dress.jpg",
        "seller_profile": {
          "id": 2,
          "business_name": "Fashion House Lagos"
        }
      }
    },
    "cart_total": 123000.00,
    "items_count": 7
  }
}
```

### Error Response (404 Not Found)
```json
{
  "message": "No query results for model [App\\Models\\Product] 999"
}
```

### Error Response (422 Validation Error)
```json
{
  "message": "The product id field is required.",
  "errors": {
    "product_id": ["The product id field is required."]
  }
}
```

**Business Logic:**
- If product already in cart → increases quantity
- If new product → creates new cart item
- Price is captured at time of adding (price snapshot)
- Only approved products can be added

---

## 14. Update Cart Item Quantity

### Endpoint Details
- **Method:** PATCH
- **URL:** `/api/cart/items/{id}`
- **Authentication:** Required (`auth:sanctum`)
- **Description:** Update quantity of a specific cart item

### Headers
```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | Cart Item ID (not product ID) |

### Request Body
```json
{
  "quantity": "integer (required, min: 1)"
}
```

### Validation Rules
- `quantity`: required|integer|min:1

### Request Example
```http
PATCH /api/cart/items/1 HTTP/1.1
Host: your-api.com
Authorization: Bearer 1|aBcDeFgHiJkLmNoPqRsTuVwXyZ
Content-Type: application/json

{
  "quantity": 5
}
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Cart item updated",
  "data": {
    "cart_item": {
      "id": 1,
      "cart_id": 1,
      "product_id": 3,
      "quantity": 5,
      "unit_price": 18000.00,
      "created_at": "2024-01-20T10:00:00.000000Z",
      "updated_at": "2024-01-20T12:00:00.000000Z",
      "subtotal": 90000.00,
      "product": {
        "id": 3,
        "name": "Ankara Print Dress",
        "price": 18000.00,
        "image": "https://example.com/images/ankara-dress.jpg"
      }
    },
    "cart_total": 155000.00,
    "items_count": 8
  }
}
```

### Error Response (404 Not Found)
```json
{
  "message": "No query results for model [App\\Models\\CartItem] 99"
}
```

### Error Response (422 Validation Error)
```json
{
  "message": "The quantity must be at least 1.",
  "errors": {
    "quantity": ["The quantity must be at least 1."]
  }
}
```

**Note:** Quantity replaces current quantity (not incremental). User can only update items in their own cart.

---

## 15. Remove Item from Cart

### Endpoint Details
- **Method:** DELETE
- **URL:** `/api/cart/items/{id}`
- **Authentication:** Required (`auth:sanctum`)
- **Description:** Remove specific item from cart

### Headers
```
Authorization: Bearer {token}
Accept: application/json
```

### URL Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | integer | Yes | Cart Item ID |

### Request Example
```http
DELETE /api/cart/items/2 HTTP/1.1
Host: your-api.com
Authorization: Bearer 1|aBcDeFgHiJkLmNoPqRsTuVwXyZ
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Item removed from cart",
  "data": {
    "cart_total": 90000.00,
    "items_count": 5
  }
}
```

### Error Response (404 Not Found)
```json
{
  "message": "No query results for model [App\\Models\\CartItem] 99"
}
```

**Note:** Returns updated cart totals after removal.

---

## 16. Clear Entire Cart

### Endpoint Details
- **Method:** DELETE
- **URL:** `/api/cart`
- **Authentication:** Required (`auth:sanctum`)
- **Description:** Remove all items from cart

### Headers
```
Authorization: Bearer {token}
Accept: application/json
```

### Request Example
```http
DELETE /api/cart HTTP/1.1
Host: your-api.com
Authorization: Bearer 1|aBcDeFgHiJkLmNoPqRsTuVwXyZ
Accept: application/json
```

### Success Response (200 OK)
```json
{
  "status": "success",
  "message": "Cart cleared successfully"
}
```

**Note:** Typically called after successful order creation. Cart remains (only items deleted).

---

# Summary Tables

## Endpoint Quick Reference

| # | Method | Endpoint | Auth | Purpose |
|---|--------|----------|------|---------|
| 1 | GET | `/api/business/public` | No | Browse businesses |
| 2 | GET | `/api/business/public/{id}` | No | View business |
| 3 | GET | `/api/products/browse` | No | Browse products |
| 4 | GET | `/api/products/filters` | No | Get filters |
| 5 | GET | `/api/products/public/{id}` | No | View product |
| 6 | GET | `/api/sustainability` | No | List initiatives |
| 7 | GET | `/api/sustainability/{id}` | No | View initiative |
| 8 | GET | `/api/adverts` | No | List adverts |
| 9 | GET | `/api/adverts/{id}` | No | View advert |
| 10 | POST | `/api/logout` | Yes | User logout |
| 11 | POST | `/api/orders/{id}/cancel` | Yes | Cancel order |
| 12 | GET | `/api/cart` | Yes | Get cart |
| 13 | POST | `/api/cart/items` | Yes | Add to cart |
| 14 | PATCH | `/api/cart/items/{id}` | Yes | Update quantity |
| 15 | DELETE | `/api/cart/items/{id}` | Yes | Remove item |
| 16 | DELETE | `/api/cart` | Yes | Clear cart |

---

## Response Status Codes

| Code | Meaning | When It Occurs |
|------|---------|----------------|
| 200 | OK | Successful GET, PATCH, DELETE |
| 201 | Created | Successful POST (new resource) |
| 400 | Bad Request | Business rule violation |
| 401 | Unauthorized | Missing or invalid token |
| 404 | Not Found | Resource doesn't exist |
| 422 | Validation Error | Invalid request data |

---

## Common Response Patterns

### Success Response
```json
{
  "status": "success",
  "message": "Operation completed successfully",
  "data": { ... }
}
```

### Error Response
```json
{
  "message": "Error description",
  "errors": {
    "field_name": ["Error message for field"]
  }
}
```

### Pagination Response
```json
{
  "data": [...],
  "links": {
    "first": "...",
    "last": "...",
    "prev": null,
    "next": "..."
  },
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total": 50
  }
}
```

---

## Testing Checklist

### Public Endpoints (No Auth)
- [ ] GET /api/business/public
- [ ] GET /api/business/public/1
- [ ] GET /api/products/browse
- [ ] GET /api/products/filters
- [ ] GET /api/products/public/1
- [ ] GET /api/sustainability
- [ ] GET /api/sustainability/1
- [ ] GET /api/adverts
- [ ] GET /api/adverts/1

### Authenticated Endpoints
- [ ] POST /api/logout
- [ ] GET /api/cart
- [ ] POST /api/cart/items
- [ ] PATCH /api/cart/items/1
- [ ] DELETE /api/cart/items/1
- [ ] DELETE /api/cart
- [ ] POST /api/orders/1/cancel

---

## Frontend Integration Examples

### React/JavaScript Examples

#### Browse Products
```javascript
const browseProducts = async (filters = {}) => {
  const params = new URLSearchParams(filters);
  const response = await fetch(`/api/products/browse?${params}`, {
    headers: { 'Accept': 'application/json' }
  });
  return await response.json();
};

// Usage
const products = await browseProducts({
  q: 'ankara',
  gender: 'female',
  sort: 'price_asc',
  per_page: 20
});
```

#### Get Cart
```javascript
const getCart = async (token) => {
  const response = await fetch('/api/cart', {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/json'
    }
  });
  return await response.json();
};
```

#### Add to Cart
```javascript
const addToCart = async (token, productId, quantity) => {
  const response = await fetch('/api/cart/items', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({ product_id: productId, quantity })
  });
  return await response.json();
};
```

#### Update Cart Item
```javascript
const updateCartItem = async (token, itemId, quantity) => {
  const response = await fetch(`/api/cart/items/${itemId}`, {
    method: 'PATCH',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({ quantity })
  });
  return await response.json();
};
```

#### Cancel Order
```javascript
const cancelOrder = async (token, orderId, reason) => {
  const response = await fetch(`/api/orders/${orderId}/cancel`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
    body: JSON.stringify({ cancellation_reason: reason })
  });
  return await response.json();
};
```

---

## Business Rules Summary

### Public Browsing
- Only `approved` businesses shown
- Only `approved` products shown
- Only `active` sustainability initiatives shown
- Only `active` adverts within date range shown

### Cart System
- One cart per user (auto-created)
- Price snapshot taken when item added
- Duplicate products increase quantity instead
- Cart persists across sessions
- Must be logged in to access cart

### Order Cancellation
- Only order owner can cancel
- Only `pending` or `processing` orders can be cancelled
- Cancellation reason required
- Email & push notification sent
- Cannot cancel shipped/delivered orders

---

**Created:** January 2024  
**Total New Endpoints:** 16  
**Documentation Status:** Complete with full request/response examples
