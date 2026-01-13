# Products API Documentation

## Overview
Endpoints for managing products in the marketplace, including CRUD operations, search, and suggestions.

---

## Product Management

### 1. List Seller's Products
**Endpoint:** `GET /api/products`  
**Controller:** `ProductController@index`  
**Middleware:** `auth:sanctum`  
**Description:** Get all products for authenticated seller

#### Headers
```
Authorization: Bearer {token}
```

#### Success Response (200)
```json
{
  "data": [
    {
      "id": 1,
      "seller_profile_id": 1,
      "name": "Ankara Agbada Set",
      "gender": "male",
      "style": "Traditional",
      "tribe": "Yoruba",
      "description": "Beautiful handmade Ankara Agbada with matching cap",
      "image": "https://example.com/images/product1.jpg",
      "size": "M, L, XL",
      "processing_time_type": "normal",
      "processing_days": 7,
      "price": 25000.00,
      "status": "approved",
      "rejection_reason": null,
      "created_at": "2024-01-15T10:00:00.000000Z",
      "updated_at": "2024-01-15T10:00:00.000000Z",
      "deleted_at": null
    }
  ],
  "links": {
    "first": "http://api.example.com/api/products?page=1",
    "last": "http://api.example.com/api/products?page=3",
    "prev": null,
    "next": "http://api.example.com/api/products?page=2"
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 3,
    "path": "http://api.example.com/api/products",
    "per_page": 10,
    "to": 10,
    "total": 25
  }
}
```

#### Error Response (403)
```json
{
  "message": "You must have a seller profile to view products"
}
```

#### Business Logic Notes
- User must have an active seller profile
- Only returns products belonging to authenticated seller
- Paginated with 10 items per page
- Ordered by creation date (newest first)

---

### 2. Create Product
**Endpoint:** `POST /api/products`  
**Controller:** `ProductController@store`  
**Middleware:** `auth:sanctum`  
**Description:** Create a new product (requires seller profile)

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "name": "string (required, max:255)",
  "gender": "string (required, enum: male|female|unisex)",
  "style": "string (required, max:100)",
  "tribe": "string (required, max:100)",
  "description": "string (required, max:1000)",
  "image": "string (optional, max:2000, URL)",
  "size": "string (required, max:50)",
  "processing_time_type": "string (required, enum: normal|quick_quick)",
  "processing_days": "integer (required, min:1, max:30)",
  "price": "decimal (required, min:0.01)"
}
```

#### Validation Rules
- `name`: required|string|max:255
- `gender`: required|in:male,female,unisex
- `style`: required|string|max:100
- `tribe`: required|string|max:100
- `description`: required|string|max:1000
- `image`: nullable|string|max:2000 (URL for now)
- `size`: required|string|max:50
- `processing_time_type`: required|in:normal,quick_quick
- `processing_days`: required|integer|min:1|max:30
- `price`: required|numeric|min:0.01

#### Success Response (201)
```json
{
  "message": "Product created successfully",
  "product": {
    "id": 5,
    "seller_profile_id": 1,
    "name": "Aso Oke Gele",
    "gender": "female",
    "style": "Traditional",
    "tribe": "Yoruba",
    "description": "Authentic hand-woven Aso Oke fabric for tying Gele",
    "image": "https://example.com/images/product5.jpg",
    "size": "One Size",
    "processing_time_type": "normal",
    "processing_days": 5,
    "price": 15000.00,
    "status": "pending",
    "rejection_reason": null,
    "created_at": "2024-01-17T14:00:00.000000Z",
    "updated_at": "2024-01-17T14:00:00.000000Z"
  }
}
```

#### Error Response (403)
```json
{
  "message": "This action is unauthorized."
}
```

#### Authorization Logic
- User must be authenticated
- User must have an active seller profile
- Checked in `StoreProductRequest::authorize()` method

#### Business Logic Notes
- Product status defaults to 'pending' (requires admin approval)
- Automatically associates product with seller's profile
- Image upload functionality to be implemented (currently accepts URL)

---

### 3. Get Product Details
**Endpoint:** `GET /api/products/{product}`  
**Controller:** `ProductController@show`  
**Middleware:** `auth:sanctum`  
**Description:** Get detailed information about a specific product

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `product`: Product ID (integer)

#### Success Response (200)
```json
{
  "id": 1,
  "seller_profile_id": 1,
  "name": "Ankara Agbada Set",
  "gender": "male",
  "style": "Traditional",
  "tribe": "Yoruba",
  "description": "Beautiful handmade Ankara Agbada with matching cap",
  "image": "https://example.com/images/product1.jpg",
  "size": "M, L, XL",
  "processing_time_type": "normal",
  "processing_days": 7,
  "price": 25000.00,
  "status": "approved",
  "avg_rating": 4.5,
  "created_at": "2024-01-15T10:00:00.000000Z",
  "updated_at": "2024-01-15T10:00:00.000000Z",
  "seller_profile": {
    "id": 1,
    "business_name": "Adire Creations",
    "business_email": "adire@example.com",
    "city": "Lagos",
    "state": "Lagos"
  },
  "reviews": [
    {
      "id": 1,
      "user_id": 2,
      "rating": 5,
      "headline": "Excellent Quality!",
      "body": "The fabric quality is superb and the tailoring is perfect.",
      "created_at": "2024-01-16T09:00:00.000000Z"
    }
  ],
  "suggestions": [
    {
      "id": 2,
      "name": "Ankara Kaftan",
      "price": 20000.00,
      "image": "https://example.com/images/product2.jpg",
      "seller_profile": {
        "business_name": "Adire Creations"
      }
    }
  ]
}
```

#### Business Logic Notes
- Includes seller profile information
- Includes all product reviews
- Provides 5 product suggestions based on style, tribe, or gender
- Suggestions are randomized for variety
- `avg_rating` is calculated from reviews

---

### 4. Update Product
**Endpoint:** `PUT /api/products/{product}`  
**Controller:** `ProductController@update`  
**Middleware:** `auth:sanctum`  
**Description:** Update existing product

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `product`: Product ID (integer)

#### Request Body
```json
{
  "name": "string (optional, max:255)",
  "gender": "string (optional, enum: male|female|unisex)",
  "style": "string (optional, max:100)",
  "tribe": "string (optional, max:100)",
  "description": "string (optional, max:1000)",
  "image": "string (optional, max:2000, URL)",
  "size": "string (optional, max:50)",
  "processing_time_type": "string (optional, enum: normal|quick_quick)",
  "processing_days": "integer (optional, min:1, max:30)",
  "price": "decimal (optional, min:0.01)",
  "status": "string (optional, enum: pending|approved|rejected)"
}
```

#### Validation Rules
- `name`: sometimes|string|max:255
- `gender`: sometimes|in:male,female,unisex
- `style`: sometimes|string|max:100
- `tribe`: sometimes|string|max:100
- `description`: sometimes|string|max:1000
- `image`: nullable|string|max:2000
- `size`: sometimes|string|max:50
- `processing_time_type`: sometimes|in:normal,quick_quick
- `processing_days`: sometimes|integer|min:1|max:30
- `price`: sometimes|numeric|min:0.01
- `status`: sometimes|in:pending,approved,rejected

#### Success Response (200)
```json
{
  "message": "Product updated successfully",
  "product": {
    "id": 1,
    "seller_profile_id": 1,
    "name": "Ankara Agbada Set - Updated",
    "gender": "male",
    "style": "Traditional",
    "tribe": "Yoruba",
    "description": "Updated description with new details",
    "price": 27000.00,
    "updated_at": "2024-01-17T15:00:00.000000Z"
  }
}
```

#### Authorization Logic
- Checked in `UpdateProductRequest::authorize()` method
- User must be authenticated
- User must have seller profile
- Product must belong to user's seller profile

#### Business Logic Notes
- Only provided fields are updated
- All fields are optional (partial update supported)
- Cannot change seller_profile_id

---

### 5. Delete Product
**Endpoint:** `DELETE /api/products/{product}`  
**Controller:** `ProductController@destroy`  
**Middleware:** `auth:sanctum`  
**Description:** Soft delete a product

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `product`: Product ID (integer)

#### Success Response (200)
```json
{
  "message": "Product deleted successfully"
}
```

#### Error Response (403)
```json
{
  "message": "Unauthorized to delete this product"
}
```

#### Business Logic Notes
- Soft delete (sets deleted_at timestamp)
- User can only delete their own products
- Verifies product belongs to authenticated seller

---

### 6. Search Products
**Endpoint:** `GET /api/products/search`  
**Controller:** `ProductController@search`  
**Middleware:** `auth:sanctum`  
**Description:** Search for approved products

#### Headers
```
Authorization: Bearer {token}
```

#### Query Parameters
```
q: string (required, min:1, max:255) - Search term
gender: string (optional, enum: male|female|unisex)
style: string (optional, max:100)
tribe: string (optional, max:100)
price_min: decimal (optional, min:0)
price_max: decimal (optional, min:0)
per_page: integer (optional, min:1, max:50, default:10)
```

#### Validation Rules
- `q`: required|string|min:1|max:255
- `gender`: sometimes|in:male,female,unisex
- `style`: sometimes|string|max:100
- `tribe`: sometimes|string|max:100
- `price_min`: sometimes|numeric|min:0
- `price_max`: sometimes|numeric|min:0
- `per_page`: sometimes|integer|min:1|max:50

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "data": [
      {
        "id": 3,
        "name": "Ankara Print Dress",
        "description": "Vibrant Ankara print dress for special occasions",
        "gender": "female",
        "style": "Modern",
        "tribe": "Mixed",
        "price": 18000.00,
        "image": "https://example.com/images/product3.jpg",
        "status": "approved",
        "avg_rating": 4.2,
        "seller_profile": {
          "id": 2,
          "business_name": "Ankara Styles"
        },
        "created_at": "2024-01-16T11:00:00.000000Z"
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 10,
      "total": 15
    }
  }
}
```

#### Business Logic Notes
- Only searches approved products
- Searches in product name and description
- Supports multiple filter combinations
- Results paginated based on per_page parameter
- Ordered by creation date (newest first)

---

### 7. Get Product Suggestions
**Endpoint:** `GET /api/products/suggestions`  
**Controller:** `ProductController@suggestions`  
**Middleware:** `auth:sanctum`  
**Description:** Get product recommendations based on filters

#### Headers
```
Authorization: Bearer {token}
```

#### Query Parameters
```
gender: string (optional, enum: male|female|unisex)
tribe: string (optional, max:100)
style: string (optional, max:100)
price_min: decimal (optional, min:0)
price_max: decimal (optional, min:0)
limit: integer (optional, min:1, max:20, default:10)
```

#### Validation Rules
- `gender`: sometimes|in:male,female,unisex
- `tribe`: sometimes|string|max:100
- `style`: sometimes|string|max:100
- `price_min`: sometimes|numeric|min:0
- `price_max`: sometimes|numeric|min:0
- `limit`: sometimes|integer|min:1|max:20

#### Success Response (200)
```json
[
  {
    "id": 7,
    "name": "Aso Ebi Bundle",
    "description": "Complete Aso Ebi set for weddings",
    "gender": "female",
    "style": "Traditional",
    "tribe": "Yoruba",
    "price": 35000.00,
    "image": "https://example.com/images/product7.jpg",
    "status": "approved",
    "avg_rating": 4.8,
    "reviews_count": 12,
    "created_at": "2024-01-14T08:00:00.000000Z"
  }
]
```

#### Business Logic Notes
- Only returns approved products
- Filters applied as provided
- Results ordered by review count (most reviewed first)
- Includes avg_rating accessor from model
- Limit defaults to 10, maximum 20
- Also accepts 'count' parameter for backward compatibility

---

## Product Reviews

### 8. Create Product Review
**Endpoint:** `POST /api/reviews`  
**Controller:** `ReviewController@store`  
**Middleware:** `auth:sanctum`  
**Description:** Create a review for a product or order

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "reviewable_id": "integer (required)",
  "reviewable_type": "string (required, enum: App\\Models\\Product|App\\Models\\Order)",
  "rating": "integer (required, min:1, max:5)",
  "headline": "string (required, max:100)",
  "body": "string (required, max:1000)"
}
```

#### Validation Rules (from StoreReviewRequest)
- `reviewable_id`: required|integer
- `reviewable_type`: required|in:[Product::class, Order::class]
- `rating`: required|integer|min:1|max:5
- `headline`: required|string|max:100
- `body`: required|string|max:1000

#### Success Response (201)
```json
{
  "message": "Review created successfully",
  "review": {
    "id": 10,
    "user_id": 1,
    "reviewable_id": 3,
    "reviewable_type": "App\\Models\\Product",
    "rating": 5,
    "headline": "Amazing Quality!",
    "body": "I'm extremely satisfied with the quality and craftsmanship. Highly recommend!",
    "created_at": "2024-01-17T16:00:00.000000Z",
    "updated_at": "2024-01-17T16:00:00.000000Z"
  }
}
```

#### Authorization Logic
- User must be authenticated
- Anyone can review a product
- Only order owner can review their order
- Checked in `StoreReviewRequest::authorize()` method

---

### 9. Get Reviews by Entity
**Endpoint:** `GET /api/reviews/{type}/{id}`  
**Controller:** `ReviewController@byEntity`  
**Middleware:** `auth:sanctum`  
**Description:** Get all reviews for a product or order

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `type`: Entity type (string, enum: product|order)
- `id`: Entity ID (integer)

#### Success Response (200)
```json
{
  "entity": {
    "id": 3,
    "type": "product",
    "avg_rating": 4.7
  },
  "reviews": {
    "data": [
      {
        "id": 8,
        "user_id": 5,
        "reviewable_id": 3,
        "reviewable_type": "App\\Models\\Product",
        "rating": 5,
        "headline": "Perfect fit!",
        "body": "The sizing was accurate and the quality exceeded my expectations.",
        "created_at": "2024-01-16T14:00:00.000000Z",
        "user": {
          "id": 5,
          "firstname": "Sarah",
          "lastname": "Johnson",
          "email": "sarah@example.com"
        }
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 10,
      "total": 8
    }
  }
}
```

#### Error Response (400)
```json
{
  "message": "Invalid entity type"
}
```

#### Error Response (403)
```json
{
  "message": "Unauthorized to view these reviews"
}
```

#### Business Logic Notes
- For orders: Only order owner can view reviews
- For products: Anyone can view reviews
- Reviews paginated with 10 per page
- Ordered by creation date (newest first)
- Includes reviewer information
- Returns average rating for the entity

---

## Common Responses

### Product Status Values
- `pending`: Awaiting admin approval
- `approved`: Available for purchase
- `rejected`: Rejected by admin

### Gender Values
- `male`: Men's products
- `female`: Women's products
- `unisex`: Gender-neutral products

### Processing Time Types
- `normal`: Standard processing time
- `quick_quick`: Express/rush processing

---

## Business Logic Summary

1. **Seller Profile Requirement**: All product management operations require an active seller profile
2. **Product Approval**: New products default to 'pending' status and require admin approval
3. **Soft Deletes**: Products are soft-deleted, preserving order history
4. **Review System**: Polymorphic reviews support both products and orders
5. **Average Ratings**: Calculated dynamically from reviews using model accessor
6. **Authorization**: Sellers can only manage their own products
7. **Search**: Only approved products appear in search results
8. **Suggestions**: Algorithm prioritizes products with more reviews
