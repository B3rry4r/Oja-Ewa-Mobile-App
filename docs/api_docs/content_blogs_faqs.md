# Content, Blogs & FAQs API Documentation

## Overview
Endpoints for accessing blogs, FAQs, categories, wishlists, blog favorites, and connect information.

---

## Blog Management (Public)

### 1. List Published Blogs
**Endpoint:** `GET /api/blogs`  
**Controller:** `BlogController@index`  
**Middleware:** None (Public)  
**Description:** Get all published blog posts with pagination

#### Query Parameters
```
page: integer (optional, default: 1)
```

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "data": [
      {
        "id": 1,
        "title": "The Art of Traditional Nigerian Fashion",
        "slug": "art-of-traditional-nigerian-fashion",
        "body": "Full blog content here...",
        "featured_image": "https://example.com/images/blog1.jpg",
        "category": "Fashion",
        "published_at": "2024-01-15T10:00:00.000000Z",
        "created_at": "2024-01-14T15:00:00.000000Z",
        "updated_at": "2024-01-15T10:00:00.000000Z",
        "admin": {
          "id": 1,
          "firstname": "Admin",
          "lastname": "User"
        }
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 10,
      "total": 25
    }
  }
}
```

#### Business Logic Notes
- Only shows published blogs (published_at not null)
- Includes admin author information
- Ordered by published_at (newest first)
- Paginated with 10 per page

---

### 2. Get Latest Blogs
**Endpoint:** `GET /api/blogs/latest`  
**Controller:** `BlogController@latest`  
**Middleware:** None (Public)  
**Description:** Get 5 most recent published blogs for homepage

#### Success Response (200)
```json
{
  "status": "success",
  "data": [
    {
      "id": 5,
      "title": "5 Tips for Starting Your Fashion Business",
      "slug": "5-tips-starting-fashion-business",
      "body": "Blog content...",
      "featured_image": "https://example.com/images/blog5.jpg",
      "category": "Business",
      "published_at": "2024-01-17T08:00:00.000000Z",
      "admin": {
        "id": 1,
        "firstname": "Admin",
        "lastname": "User"
      }
    }
  ]
}
```

#### Business Logic Notes
- Returns maximum 5 blogs
- Only published blogs
- Ordered by published_at (newest first)
- Ideal for homepage/featured section

---

### 3. Search Blogs
**Endpoint:** `GET /api/blogs/search`  
**Controller:** `BlogController@search`  
**Middleware:** None (Public)  
**Description:** Search blogs by title or content

#### Query Parameters
```
query: string (required, min:3)
page: integer (optional, default: 1)
```

#### Validation Rules
- `query`: required|string|min:3

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "data": [
      {
        "id": 3,
        "title": "Understanding Ankara Fabric Patterns",
        "slug": "understanding-ankara-fabric-patterns",
        "body": "Detailed content about Ankara patterns...",
        "featured_image": "https://example.com/images/blog3.jpg",
        "published_at": "2024-01-16T12:00:00.000000Z",
        "admin": {
          "id": 1,
          "firstname": "Admin",
          "lastname": "User"
        }
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 10,
      "total": 3
    }
  }
}
```

#### Business Logic Notes
- Searches in both title and body fields
- Only searches published blogs
- Case-insensitive search using LIKE
- Minimum 3 characters required
- Paginated with 10 per page

---

### 4. Get Single Blog
**Endpoint:** `GET /api/blogs/{slug}`  
**Controller:** `BlogController@show`  
**Middleware:** None (Public)  
**Description:** Get detailed blog post by slug

#### URL Parameters
- `slug`: Blog slug (string)

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "blog": {
      "id": 1,
      "title": "The Art of Traditional Nigerian Fashion",
      "slug": "art-of-traditional-nigerian-fashion",
      "body": "Full detailed blog content with all paragraphs...",
      "featured_image": "https://example.com/images/blog1.jpg",
      "category": "Fashion",
      "published_at": "2024-01-15T10:00:00.000000Z",
      "created_at": "2024-01-14T15:00:00.000000Z",
      "updated_at": "2024-01-15T10:00:00.000000Z",
      "admin": {
        "id": 1,
        "firstname": "Admin",
        "lastname": "User"
      }
    },
    "related_posts": [
      {
        "id": 2,
        "title": "Yoruba Wedding Attire Guide",
        "slug": "yoruba-wedding-attire-guide",
        "featured_image": "https://example.com/images/blog2.jpg",
        "category": "Fashion",
        "published_at": "2024-01-14T09:00:00.000000Z",
        "admin": {
          "id": 1,
          "firstname": "Admin",
          "lastname": "User"
        }
      }
    ]
  }
}
```

#### Error Response (404)
```json
{
  "status": "error",
  "message": "Blog post not found"
}
```

#### Business Logic Notes
- Only shows published blogs
- Returns 3 related posts from same category
- Related posts exclude current blog
- Related posts ordered by published_at (newest first)

---

## FAQ Management (Public)

### 5. List FAQs
**Endpoint:** `GET /api/faqs`  
**Controller:** `FaqController@index`  
**Middleware:** None (Public)  
**Description:** Get all FAQs with optional category filter

#### Query Parameters
```
category: string (optional)
page: integer (optional, default: 1)
```

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "data": [
      {
        "id": 1,
        "category": "Orders",
        "question": "How do I track my order?",
        "answer": "You can track your order by going to the Orders section in your account and clicking on the order number. You'll see real-time tracking information.",
        "created_at": "2024-01-10T08:00:00.000000Z",
        "updated_at": "2024-01-10T08:00:00.000000Z"
      },
      {
        "id": 2,
        "category": "Payments",
        "question": "What payment methods do you accept?",
        "answer": "We accept payments via Paystack, which supports card payments, bank transfers, and USSD.",
        "created_at": "2024-01-10T08:15:00.000000Z",
        "updated_at": "2024-01-10T08:15:00.000000Z"
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 20,
      "total": 45
    }
  }
}
```

#### Business Logic Notes
- Paginated with 20 per page
- Optional filtering by category
- Ordered by latest first
- All FAQs are public

---

### 6. Get FAQ Categories
**Endpoint:** `GET /api/faqs/categories`  
**Controller:** `FaqController@categories`  
**Middleware:** None (Public)  
**Description:** Get list of all available FAQ categories

#### Success Response (200)
```json
{
  "status": "success",
  "data": [
    "Orders",
    "Payments",
    "Shipping",
    "Returns",
    "Account",
    "Products",
    "Sellers",
    "General"
  ]
}
```

#### Business Logic Notes
- Returns distinct categories from FAQ model
- Uses model method `Faq::getCategories()`
- Useful for category filters in UI

---

### 7. Search FAQs
**Endpoint:** `GET /api/faqs/search`  
**Controller:** `FaqController@search`  
**Middleware:** None (Public)  
**Description:** Search FAQs by question or answer

#### Query Parameters
```
query: string (required, min:3)
page: integer (optional, default: 1)
```

#### Validation Rules
- `query`: required|string|min:3

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "data": [
      {
        "id": 5,
        "category": "Orders",
        "question": "Can I cancel my order?",
        "answer": "Yes, you can cancel your order before it has been shipped. Go to your order details and click the 'Cancel Order' button.",
        "created_at": "2024-01-10T09:00:00.000000Z",
        "updated_at": "2024-01-10T09:00:00.000000Z"
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 20,
      "total": 5
    }
  }
}
```

#### Business Logic Notes
- Searches both question and answer fields
- Case-insensitive search using LIKE
- Minimum 3 characters required
- Paginated with 20 per page

---

### 8. Get Single FAQ
**Endpoint:** `GET /api/faqs/{id}`  
**Controller:** `FaqController@show`  
**Middleware:** None (Public)  
**Description:** Get specific FAQ details

#### URL Parameters
- `id`: FAQ ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "category": "Orders",
    "question": "How do I track my order?",
    "answer": "You can track your order by going to the Orders section in your account and clicking on the order number. You'll see real-time tracking information including order status, tracking number if available, and estimated delivery date.",
    "created_at": "2024-01-10T08:00:00.000000Z",
    "updated_at": "2024-01-10T08:00:00.000000Z"
  }
}
```

#### Error Response (404)
```json
{
  "status": "error",
  "message": "FAQ not found"
}
```

---

## Category Management (Public)

### 9. Get Categories by Type
**Endpoint:** `GET /api/categories`  
**Controller:** `CategoryController@index`  
**Middleware:** None (Public)  
**Description:** Get categories filtered by type

#### Query Parameters
```
type: string (required, enum: market|beauty|brand|school|sustainability|music)
```

#### Validation Rules
- `type`: required|in:market,beauty,brand,school,sustainability,music

#### Success Response (200)
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "type": "market",
      "name": "Traditional Wear",
      "slug": "traditional-wear",
      "description": "Traditional Nigerian clothing and accessories",
      "parent_id": null,
      "order": 1,
      "created_at": "2024-01-05T10:00:00.000000Z",
      "children": [
        {
          "id": 5,
          "type": "market",
          "name": "Agbada",
          "slug": "agbada",
          "parent_id": 1,
          "order": 1
        },
        {
          "id": 6,
          "type": "market",
          "name": "Ankara",
          "slug": "ankara",
          "parent_id": 1,
          "order": 2
        }
      ]
    }
  ]
}
```

#### Business Logic Notes
- Only returns top-level categories
- Includes nested children categories
- Ordered by 'order' field
- Categories organized hierarchically

---

### 10. Get Category Children
**Endpoint:** `GET /api/categories/{id}/children`  
**Controller:** `CategoryController@children`  
**Middleware:** None (Public)  
**Description:** Get child categories of a specific category

#### URL Parameters
- `id`: Category ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "parent": {
      "id": 1,
      "type": "market",
      "name": "Traditional Wear",
      "slug": "traditional-wear",
      "parent_id": null
    },
    "children": [
      {
        "id": 5,
        "type": "market",
        "name": "Agbada",
        "slug": "agbada",
        "parent_id": 1,
        "order": 1,
        "created_at": "2024-01-05T10:30:00.000000Z"
      },
      {
        "id": 6,
        "type": "market",
        "name": "Ankara",
        "slug": "ankara",
        "parent_id": 1,
        "order": 2,
        "created_at": "2024-01-05T10:45:00.000000Z"
      }
    ]
  }
}
```

#### Business Logic Notes
- Returns parent category info
- Lists all direct children
- Ordered by 'order' field

---

### 11. Get Category Items
**Endpoint:** `GET /api/categories/{type}/{slug}/items`  
**Controller:** `CategoryController@items`  
**Middleware:** None (Public)  
**Description:** Get items (products/businesses) for a category

#### URL Parameters
- `type`: Category type (string, enum: market|beauty|brand|school|sustainability|music)
- `slug`: Category slug (string)

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "category": {
      "id": 1,
      "type": "market",
      "name": "Traditional Wear",
      "slug": "traditional-wear",
      "description": "Traditional Nigerian clothing"
    },
    "items": [1, 3, 5, 7, 9, 12, 15, 18, 21, 24]
  }
}
```

#### Error Response (400)
```json
{
  "status": "error",
  "message": "Invalid category type"
}
```

#### Business Logic Notes
- For 'market': Returns approved product IDs (max 20)
- For business categories (beauty/brand/school/music): Returns approved business profile IDs (max 20)
- Items returned as array of IDs only
- Client should fetch full details separately

---

## Wishlist Management

### 12. Get User Wishlist
**Endpoint:** `GET /api/wishlist`  
**Controller:** `WishlistController@index`  
**Middleware:** `auth:sanctum`  
**Description:** Get all wishlist items for authenticated user

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
        "wishlistable_id": 3,
        "wishlistable_type": "App\\Models\\Product",
        "created_at": "2024-01-16T10:00:00.000000Z",
        "wishlistable": {
          "id": 3,
          "name": "Ankara Print Dress",
          "price": 18000.00,
          "image": "https://example.com/images/product3.jpg",
          "status": "approved"
        }
      },
      {
        "id": 2,
        "user_id": 1,
        "wishlistable_id": 5,
        "wishlistable_type": "App\\Models\\BusinessProfile",
        "created_at": "2024-01-16T11:00:00.000000Z",
        "wishlistable": {
          "id": 5,
          "business_name": "Glam Beauty Studio",
          "category": "beauty",
          "business_logo": "https://example.com/logos/glam.png"
        }
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 20,
      "total": 2
    }
  }
}
```

#### Business Logic Notes
- Returns both products and business profiles
- Includes full wishlistable item details
- Ordered by latest first
- Paginated with 20 per page

---

### 13. Add to Wishlist
**Endpoint:** `POST /api/wishlist`  
**Controller:** `WishlistController@store`  
**Middleware:** `auth:sanctum`  
**Description:** Add item to wishlist

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "wishlistable_type": "string (required, enum: product|business_profile)",
  "wishlistable_id": "integer (required)"
}
```

#### Validation Rules
- `wishlistable_type`: required|in:product,business_profile
- `wishlistable_id`: required|integer

#### Success Response (201)
```json
{
  "status": "success",
  "message": "Item added to wishlist",
  "data": {
    "id": 3,
    "user_id": 1,
    "wishlistable_id": 7,
    "wishlistable_type": "App\\Models\\Product",
    "created_at": "2024-01-17T15:00:00.000000Z",
    "wishlistable": {
      "id": 7,
      "name": "Aso Ebi Bundle",
      "price": 35000.00,
      "image": "https://example.com/images/product7.jpg"
    }
  }
}
```

#### Error Response (404)
```json
{
  "status": "error",
  "message": "Item not found"
}
```

#### Error Response (409)
```json
{
  "status": "error",
  "message": "Item already in wishlist"
}
```

#### Business Logic Notes
- Validates item exists before adding
- Prevents duplicate entries
- Polymorphic relationship supports products and businesses
- Type converted to full class name internally

---

### 14. Remove from Wishlist
**Endpoint:** `DELETE /api/wishlist`  
**Controller:** `WishlistController@destroy`  
**Middleware:** `auth:sanctum`  
**Description:** Remove item from wishlist

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "wishlistable_type": "string (required, enum: product|business_profile)",
  "wishlistable_id": "integer (required)"
}
```

#### Validation Rules
- `wishlistable_type`: required|in:product,business_profile
- `wishlistable_id`: required|integer

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Item removed from wishlist"
}
```

#### Error Response (404)
```json
{
  "status": "error",
  "message": "Item not found in wishlist"
}
```

---

## Blog Favorites

### 15. Get Favorite Blogs
**Endpoint:** `GET /api/blogs/favorites`  
**Controller:** `BlogFavoriteController@index`  
**Middleware:** `auth:sanctum`  
**Description:** Get user's favorite blog posts

#### Headers
```
Authorization: Bearer {token}
```

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Favorite blogs retrieved successfully",
  "data": {
    "data": [
      {
        "id": 1,
        "title": "The Art of Traditional Nigerian Fashion",
        "slug": "art-of-traditional-nigerian-fashion",
        "featured_image": "https://example.com/images/blog1.jpg",
        "published_at": "2024-01-15T10:00:00.000000Z",
        "admin": {
          "id": 1,
          "firstname": "Admin",
          "lastname": "User"
        }
      }
    ],
    "links": {},
    "meta": {
      "current_page": 1,
      "per_page": 10,
      "total": 3
    }
  }
}
```

#### Business Logic Notes
- Only returns published blogs
- Filters out deleted blogs automatically
- Ordered by favorite date (newest first)
- Paginated with 10 per page

---

### 16. Add Blog to Favorites
**Endpoint:** `POST /api/blogs/favorites`  
**Controller:** `BlogFavoriteController@store`  
**Middleware:** `auth:sanctum`  
**Description:** Add blog to favorites

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "blog_id": "integer (required, exists:blogs,id)"
}
```

#### Validation Rules
- `blog_id`: required|integer|exists:blogs,id

#### Success Response (201)
```json
{
  "status": "success",
  "message": "Blog added to favorites successfully"
}
```

#### Error Response (400)
```json
{
  "status": "error",
  "message": "Blog is already in your favorites"
}
```

#### Business Logic Notes
- Blog must be published
- Prevents duplicate favorites
- Validates blog existence first

---

### 17. Remove Blog from Favorites
**Endpoint:** `DELETE /api/blogs/favorites`  
**Controller:** `BlogFavoriteController@destroy`  
**Middleware:** `auth:sanctum`  
**Description:** Remove blog from favorites

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "blog_id": "integer (required, exists:blogs,id)"
}
```

#### Validation Rules
- `blog_id`: required|integer|exists:blogs,id

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Blog removed from favorites successfully"
}
```

#### Error Response (404)
```json
{
  "status": "error",
  "message": "Blog is not in your favorites"
}
```

---

## Connect Information

### 18. Get All Connect Links
**Endpoint:** `GET /api/connect`  
**Controller:** `ConnectController@index`  
**Middleware:** None (Public)  
**Description:** Get all social media and contact information

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "social_links": {
      "facebook": "https://facebook.com/ojaewa",
      "instagram": "https://instagram.com/ojaewa",
      "twitter": "https://twitter.com/ojaewa",
      "youtube": "https://youtube.com/@ojaewa",
      "tiktok": "https://tiktok.com/@ojaewa"
    },
    "contact": {
      "email": "support@ojaewa.com",
      "phone": "+234XXXXXXXXXX",
      "whatsapp": "+234XXXXXXXXXX",
      "address": "Lagos, Nigeria"
    },
    "app_links": {
      "ios": "https://apps.apple.com/app/ojaewa",
      "android": "https://play.google.com/store/apps/details?id=com.ojaewa"
    }
  }
}
```

#### Business Logic Notes
- Data loaded from `config/connect.php`
- Public endpoint for footer/contact page
- All links and contact info in one response

---

### 19. Get Social Media Links
**Endpoint:** `GET /api/connect/social`  
**Controller:** `ConnectController@social`  
**Middleware:** None (Public)  
**Description:** Get only social media links

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "facebook": "https://facebook.com/ojaewa",
    "instagram": "https://instagram.com/ojaewa",
    "twitter": "https://twitter.com/ojaewa",
    "youtube": "https://youtube.com/@ojaewa",
    "tiktok": "https://tiktok.com/@ojaewa"
  }
}
```

---

### 20. Get Contact Information
**Endpoint:** `GET /api/connect/contact`  
**Controller:** `ConnectController@contact`  
**Middleware:** None (Public)  
**Description:** Get contact information

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "email": "support@ojaewa.com",
    "phone": "+234XXXXXXXXXX",
    "whatsapp": "+234XXXXXXXXXX",
    "address": "Lagos, Nigeria"
  }
}
```

---

### 21. Get App Download Links
**Endpoint:** `GET /api/connect/app-links`  
**Controller:** `ConnectController@appLinks`  
**Middleware:** None (Public)  
**Description:** Get mobile app download links

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "ios": "https://apps.apple.com/app/ojaewa",
    "android": "https://play.google.com/store/apps/details?id=com.ojaewa"
  }
}
```

---

## Business Logic Summary

1. **Public Content**: All blogs, FAQs, categories, and connect info are publicly accessible
2. **Blog Publishing**: Only published blogs appear in public endpoints
3. **Search Functionality**: Minimum 3 characters for all searches
4. **Wishlist**: Supports both products and business profiles polymorphically
5. **Blog Favorites**: Only published blogs can be favorited
6. **Category Hierarchy**: Supports parent-child relationships
7. **Pagination**: Default 10-20 items per page depending on endpoint
8. **Related Content**: Blogs show 3 related posts from same category
9. **Configuration-Based**: Connect info loaded from config files
10. **Item IDs**: Category items return ID arrays for flexible client-side fetching
