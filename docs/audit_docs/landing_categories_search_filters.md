# Landing Categories + Search + Filters API (Client Agent Pack)

This document is intended to be sent to the mobile/client agent.
It contains the **exact endpoints**, **required params**, **headers**, and **real request/response examples** captured from a seeded local environment.

> Key rule: **Do not guess slugs.** Always fetch categories first and use the returned `slug`.

---

## 1) Category Navigation (Landing Page)

### 1.0 Get ALL categories (grouped by type) for registration forms

**GET** `/api/categories/all`

This endpoint returns **all category trees** grouped by `type`, so the mobile app can:
- show full category pickers during registration/onboarding
- store the correct `category_id` / `subcategory_id`
- avoid guessing slugs

**Headers**
- `Accept: application/json`

**Example request**
```bash
curl -X GET "https://<host>/api/categories/all" \
  -H "Accept: application/json"
```

**Response (example)**
```json
{
  "status": "success",
  "data": {
    "textiles": [
      {"id": 1, "name": "Women", "slug": "textiles-women", "type": "textiles", "children": [
        {"id": 5, "name": "Dresses & Gowns", "slug": "textiles-women-dresses-gowns", "type": "textiles"}
      ]}
    ],
    "afro_beauty_products": [
      {"id": 55, "name": "Hair Care", "slug": "afro-beauty-products-hair-care", "type": "afro_beauty_products"}
    ],
    "afro_beauty_services": [
      {"id": 80, "name": "Hair Care & Styling Services", "slug": "afro-beauty-services-hair-care-styling-services", "type": "afro_beauty_services"}
    ],
    "shoes_bags": [
      {"id": 70, "name": "Women", "slug": "shoes-bags-women", "type": "shoes_bags", "children": [
        {"id": 72, "name": "Slides & Mules", "slug": "shoes-bags-women-slides-mules", "type": "shoes_bags"}
      ]}
    ],
    "art": [
      {"id": 76, "name": "Sculpture", "slug": "art-sculpture", "type": "art"}
    ],
    "school": [
      {"id": 90, "name": "Undergraduate", "slug": "school-undergraduate", "type": "school"}
    ],
    "sustainability": [
      {"id": 110, "name": "Biodegradable Items", "slug": "sustainability-biodegradable-items", "type": "sustainability"}
    ]
  },
  "meta": {
    "usage": {
      "products": "Use category_id from textiles, shoes_bags, afro_beauty_products",
      "businesses": "Use category_id from art, school, or afro_beauty_services",
      "sustainability": "Use category_id from sustainability"
    }
  }
}
```

### 1.1 List categories for a landing box

**GET** `/api/categories?type={type}`

**Query params**
- `type` (required): `textiles | shoes_bags | afro_beauty_products | afro_beauty_services | art | school | sustainability`

**Headers**
- `Accept: application/json`

**Example request**
```bash
curl -X GET "https://<host>/api/categories?type=textiles" \
  -H "Accept: application/json"
```

**Example response (real)**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "name": "Women",
      "slug": "textiles-women",
      "type": "textiles",
      "parent_id": null,
      "children": [
        {
          "id": 5,
          "name": "Dresses & Gowns",
          "slug": "textiles-women-dresses-gowns",
          "parent_id": 1,
          "type": "textiles",
          "children": []
        },
        {
          "id": 6,
          "name": "Tops",
          "slug": "textiles-women-tops",
          "parent_id": 1,
          "type": "textiles",
          "children": []
        }
      ]
    },
    {
      "id": 2,
      "name": "Men",
      "slug": "textiles-men",
      "type": "textiles",
      "parent_id": null,
      "children": [
        {
          "id": 12,
          "name": "Shirts & Tops",
          "slug": "textiles-men-shirts-tops",
          "parent_id": 2,
          "type": "textiles",
          "children": []
        }
      ]
    },
    {
      "id": 3,
      "name": "Unisex",
      "slug": "textiles-unisex",
      "type": "textiles",
      "parent_id": null,
      "children": [
        {
          "id": 20,
          "name": "Modern Casual Wear",
          "slug": "textiles-unisex-modern-casual-wear",
          "parent_id": 3,
          "type": "textiles",
          "children": []
        }
      ]
    }
  ]
}
```

---

### 1.2 Fetch items for a category/subcategory

**GET** `/api/categories/{type}/{slug}/items`

**Path params**
- `type`: same as the category type you loaded
- `slug`: a slug returned from `/api/categories?type=...`

**Query params**
- `per_page` (optional)

**Headers**
- `Accept: application/json`

**Example request (Textiles → Women → Dresses & Gowns)**
```bash
curl -X GET "https://<host>/api/categories/textiles/textiles-women-dresses-gowns/items?per_page=2" \
  -H "Accept: application/json"
```

**Example response (real, products)**
```json
{
    "status": "success",
    "data": {
        "category": {
            "id": 5,
            "type": "textiles",
            "name": "Dresses & Gowns",
            "slug": "textiles-women-dresses-gowns",
            "description": null
        },
        "items": {
            "current_page": 1,
            "data": [
                {
                    "id": 1,
                    "seller_profile_id": 1,
                    "name": "reprehenderit amet esse Boubou",
                    "gender": "male",
                    "style": "Adire",
                    "tribe": "Yoruba",
                    "description": "Non error et velit quisquam vel esse maiores autem...",
                    "image": "https://images.unsplash.com/photo-1485968579580-b6d095142e6e?w=500&h=500&fit=crop",
                    "size": "36",
                    "processing_time_type": "quick_quick",
                    "processing_days": 8,
                    "price": "206.96",
                    "status": "approved",
                    "created_at": "2026-01-15T18:02:32.000000Z",
                    "updated_at": "2026-01-15T18:02:32.000000Z",
                    "deleted_at": null,
                    "rejection_reason": null,
                    "category_id": 5,
                    "avg_rating": 4,
                    "category": {
                        "id": 5,
                        "name": "Dresses & Gowns",
                        "slug": "textiles-women-dresses-gowns",
                        "parent_id": 1,
                        "type": "textiles"
                    },
                    "seller_profile": {
                        "id": 1,
                        "business_name": "Steuber-Altenwerth",
                        "business_email": "evan99@anderson.info",
                        "city": "McGlynnview",
                        "state": "Missouri"
                    }
                }
            ],
            "per_page": 2,
            "total": 3
        }
    }
}
```

---

### 1.3 Afro Beauty Services returns Businesses (NOT Products)

**GET** `/api/categories/afro_beauty_services/{slug}/items`

The services tab uses `type=afro_beauty_services` and returns **business profiles**.

**Example request**
```bash
curl -X GET "https://<host>/api/categories/afro_beauty_services/afro-beauty-services-hair-care-styling-services/items?per_page=2" \
  -H "Accept: application/json"
```

**Example response (real, businesses)**
```json
{
  "status": "success",
  "data": {
    "category": {
      "id": 57,
      "type": "afro_beauty_services",
      "name": "Hair Care & Styling Services",
      "slug": "afro-beauty-services-hair-care-styling-services",
      "description": null
    },
    "items": {
      "current_page": 1,
      "data": [
        {
          "id": 2,
          "user_id": 2,
          "category": "afro_beauty_services",
          "country": "Solomon Islands",
          "state": "Hawaii",
          "city": "Douglasville",
          "address": "1691 McClure Fords Apt. 468",
          "business_email": "bernadine91@wisozk.com",
          "business_phone_number": "1-820-588-6654",
          "business_name": "Koelpin, Bahringer and Schultz Afro_beauty",
          "business_description": "Sunt eos soluta esse...",
          "business_logo": "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400&h=400&fit=crop",
          "offering_type": "providing_service",
          "service_list": "[{\"name\":\"Hair Styling\",\"price\":5000}]",
          "store_status": "approved",
          "category_id": 56,
          "subcategory_id": 57,
          "user": {
            "id": 2,
            "firstname": "Carole",
            "lastname": "Becker"
          },
          "category_relation": {
            "id": 57,
            "name": "Hair Care & Styling Services",
            "slug": "afro-beauty-services-hair-care-styling-services",
            "parent_id": null,
            "type": "afro_beauty_services"
          }
        }
      ],
      "per_page": 2,
      "total": 1
    }
  }
}
```

---

## 2) Products Search + Filters

### 2.1 Public filters metadata (includes category trees)

**GET** `/api/products/filters`

**Headers**
- `Accept: application/json`

**Example request**
```bash
curl -X GET "https://<host>/api/products/filters" \
  -H "Accept: application/json"
```

**Example response (real, trimmed)**
- Contains `category_trees.textiles`, `category_trees.shoes_bags`, `category_trees.afro_beauty_products`, `category_trees.art`
- Also contains `fabrics`, `styles`, `tribes`, `price_range`, `sort_options`

```json
{
  "status": "success",
  "data": {
    "product_category_types": ["textiles", "shoes_bags", "afro_beauty_products", "art"],
    "category_trees": {
      "textiles": [ {"id": 1, "name": "Women", "slug": "textiles-women", "children": [ ... ] } ],
      "afro_beauty_products": [ {"id": 55, "name": "Hair Care", "slug": "afro-beauty-products-hair-care" } ],
      "shoes_bags": [ {"id": 70, "name": "Women", "slug": "shoes-bags-women", "children": [ ... ] } ],
      "art": [ {"id": 200, "name": "Products", "slug": "art-products", "children": [ {"id": 201, "name": "Sculpture", "slug": "art-products-sculpture"} ] } ]
    },
    "price_range": {"min": "89.81", "max": "467.04"},
    "sort_options": [
      {"value": "newest", "label": "Newest First"},
      {"value": "price_asc", "label": "Price: Low to High"}
    ]
  }
}
```

---

### 2.2 Product search (AUTH REQUIRED)

**GET** `/api/products/search`

**Headers**
- `Accept: application/json`
- `Authorization: Bearer <token>`

**Query params**
- `q` (required)
- `type` (optional): `textiles|shoes_bags|afro_beauty_products|art`
- `category_slug` (optional)
- `category_id` (optional)
- `style`, `tribe`, `fabric_type`, `price_min`, `price_max`, `per_page`

**Example request**
```bash
curl -X GET "https://<host>/api/products/search?q=a&type=textiles&per_page=2" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <token>"
```

**Example response (real)**
```json
{
  "status": "success",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "seller_profile_id": 1,
        "name": "reprehenderit amet esse Boubou",
        "gender": "male",
        "style": "Adire",
        "tribe": "Yoruba",
        "image": "https://images.unsplash.com/photo-1485968579580-b6d095142e6e?w=500&h=500&fit=crop",
        "price": "206.96",
        "status": "approved",
        "category_id": 5,
        "seller_profile": {"id": 1, "business_name": "Steuber-Altenwerth"},
        "category": {"id": 5, "name": "Dresses & Gowns", "slug": "textiles-women-dresses-gowns", "type": "textiles"}
      }
    ],
    "per_page": 2,
    "total": 15
  }
}
```

**If you call it without auth**
```json
{
  "message": "Unauthenticated."
}
```

---

## 3) Businesses (Services): Public Search + Filters

### 3.1 Business filters

**GET** `/api/business/public/filters`

**Example request**
```bash
curl -X GET "https://<host>/api/business/public/filters" \
  -H "Accept: application/json"
```

**Response contains**
- `category_trees.school`
- `category_trees.afro_beauty_services` (services subtree)

---

### 3.2 Business search

**GET** `/api/business/public/search`

**Query params**
- `q` (required)
- optional: `category` (legacy), `category_id`, `category_slug`, `state`, `city`, `sort`, `per_page`

**Example request**
```bash
curl -X GET "https://<host>/api/business/public/search?q=school&per_page=2" \
  -H "Accept: application/json"
```

**Example response (real)**
```json
{
  "status": "success",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "category": "school",
        "business_name": "Quigley, Roberts and Gulgowski School",
        "business_email": "samson.windler@bergstrom.net",
        "business_logo": "https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400&h=400&fit=crop",
        "school_type": "fashion",
        "store_status": "approved",
        "category_id": 81,
        "subcategory_id": 82,
        "user": {"id": 1, "firstname": "Test", "lastname": "User"}
      }
    ],
    "per_page": 2,
    "total": 1
  }
}
```

---

## 4) Sustainability: Search + Filters

### 4.1 Filters

**GET** `/api/sustainability/filters`

Includes:
- legacy `categories` (environmental/social/economic/governance)
- new `category_tree` (from `/api/categories?type=sustainability`)

### 4.2 Search

**GET** `/api/sustainability/search`

**Query params**
- `q` (required)
- legacy: `category`
- new: `category_id`, `category_slug`

**Example request**
```bash
curl -X GET "https://<host>/api/sustainability/search?q=initiative&per_page=2" \
  -H "Accept: application/json"
```

**Example response (real)**
```json
{
  "status": "success",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "title": "Zero Waste Fashion Initiative",
        "category": "environmental",
        "status": "active",
        "target_amount": "1000000.00",
        "current_amount": "350000.00",
        "category_id": 113,
        "admin": {"id": 1, "firstname": "Super", "lastname": "Admin"}
      }
    ],
    "per_page": 2,
    "total": 2
  }
}
```

---

## 5) Registration / Creation forms: what category fields must be sent

### Product creation (seller)
- Endpoint: `POST /api/products`
- Required: `category_id`
  - Must be a valid category node under one of the product catalogs:
    - `textiles`, `shoes_bags`, `afro_beauty_products`, `art`

### Business profile creation (services)
- Endpoint: `POST /api/business`
- Recommended:
  - `category_id` picked from:
    - `school` category tree, or
    - `afro_beauty_services` (leaf categories)

### Sustainability initiative creation (admin)
- Endpoint: `POST /api/admin/sustainability`
- Supports:
  - legacy `category` (environmental/social/economic/governance)
  - new `category_id` (recommended) → pick from `type=sustainability` tree

---

## 6) Recommended client implementation

### Category browsing
1. Load category tree: `GET /api/categories?type=<landing_type>`
2. Render nodes.
3. On click: `GET /api/categories/{type}/{slug}/items`

This is the **primary** and **correct** way to power category screens.

### Search
- Products: `/api/products/search` (auth required)
- Services: `/api/business/public/search` (public)

---
