# Category System API Documentation

## Final Locked Model

The category system has been restructured with a clear mapping between landing boxes, category types, and entity types.

---

## Category Types & Entity Mapping

### Product Catalogs (Return Products)

| Type | Depth | Structure | Returns |
|------|-------|-----------|---------|
| `textiles` | 3 levels | Group → Leaf | Products |
| `shoes_bags` | 3 levels | Group → Leaf | Products |
| `afro_beauty_products` | 3 levels | Group → Leaf | Products |

**Kids Categories Added:**
- `textiles` now has `Kids` group with Female/Male leaf items
- `shoes_bags` now has `Kids` group with Shoes + Bags leaf items
- `afro_beauty_products` now has `Kids` group (Male/Female leaf items)

### Business Directories (Return BusinessProfiles)

| Type | Depth | Structure | Returns |
|------|-------|-----------|---------|
| `school` | 2 levels | Leaf only | BusinessProfiles |

### Initiatives (Return SustainabilityInitiatives)

| Type | Depth | Structure | Returns |
|------|-------|-----------|---------|
| `sustainability` | 2 levels | Leaf only | SustainabilityInitiatives |

### Afro Beauty

The Afro Beauty landing box has a single products tree:
- **Products**: Uses `afro_beauty_products` type (Kids/Women/Men groups)

---

## Endpoints

### 1. Get All Categories Tree

Retrieve all categories grouped by type. Useful for registration forms.

```
GET /api/categories/all
```

**Response:**
```json
{
    "status": "success",
    "data": {
        "textiles": [
            {
                "id": 1,
                "name": "Women",
                "slug": "textiles-women",
                "parent_id": null,
                "type": "textiles",
                "order": 1,
                "children": [
                    {
                        "id": 5,
                        "name": "Dresses & Gowns",
                        "slug": "textiles-women-dresses-gowns",
                        "parent_id": 1,
                        "type": "textiles",
                        "order": 1,
                        "children": []
                    }
                ]
            }
        ],
        "shoes_bags": [...],
        "afro_beauty_products": [...],
        "afro_beauty_services": [...],
        "art": [...],
        "school": [...],
        "sustainability": [...]
    },
    "meta": {
        "type_mapping": {
            "product_catalogs": {
                "types": ["textiles", "shoes_bags", "afro_beauty_products"],
                "returns": "Products",
                "description": "Use category_id when creating products"
            },
            "business_directories": {
                "types": ["art", "school", "afro_beauty_services"],
                "returns": "BusinessProfiles",
                "description": "Use category_id when registering businesses"
            },
            "initiatives": {
                "types": ["sustainability"],
                "returns": "SustainabilityInitiatives",
                "description": "Use category_id when creating initiatives"
            }
        },
        "afro_beauty_tabs": {
            "tab_1_products": "afro_beauty_products",
            "tab_2_services": "afro_beauty_services"
        },
        "depth_rules": {
            "textiles": "3 levels (Group → Leaf)",
            "shoes_bags": "3 levels (Group → Leaf)",
            "afro_beauty_products": "2 levels (Leaf only)",
            "afro_beauty_services": "2 levels (Leaf only)",
            "art": "2 levels (Leaf only)",
            "school": "2 levels (Leaf only)",
            "sustainability": "2 levels (Leaf only)"
        },
        "types": [
            "textiles",
            "shoes_bags",
            "afro_beauty_products",
            "afro_beauty_services",
            "art",
            "school",
            "sustainability"
        ]
    }
}
```

---

### 2. Get Categories by Type

Retrieve categories for a specific type.

```
GET /api/categories?type={type}
```

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `type` | string | Yes | One of: `textiles`, `shoes_bags`, `afro_beauty_products`, `afro_beauty_services`, `art`, `school`, `sustainability` |

**Request Example:**
```
GET /api/categories?type=textiles
```

**Response:**
```json
{
    "status": "success",
    "data": [
        {
            "id": 1,
            "name": "Women",
            "slug": "textiles-women",
            "parent_id": null,
            "type": "textiles",
            "order": 1,
            "children": [
                {
                    "id": 5,
                    "name": "Dresses & Gowns",
                    "slug": "textiles-women-dresses-gowns",
                    "parent_id": 1,
                    "type": "textiles",
                    "order": 1
                },
                {
                    "id": 6,
                    "name": "Two-Piece Sets",
                    "slug": "textiles-women-two-piece-sets",
                    "parent_id": 1,
                    "type": "textiles",
                    "order": 2
                }
            ]
        },
        {
            "id": 2,
            "name": "Men",
            "slug": "textiles-men",
            "parent_id": null,
            "type": "textiles",
            "order": 2,
            "children": [...]
        }
    ],
    "meta": {
        "type": "textiles",
        "returns": "products",
        "total_count": 4
    }
}
```

**Error Response (Invalid Type):**
```json
{
    "message": "The selected type is invalid.",
    "errors": {
        "type": ["The selected type is invalid."]
    }
}
```

---

### 3. Get Category Children

Retrieve children of a specific category.

```
GET /api/categories/{id}/children
```

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `id` | integer | Yes | Category ID |

**Request Example:**
```
GET /api/categories/1/children
```

**Response:**
```json
{
    "status": "success",
    "data": {
        "parent": {
            "id": 1,
            "name": "Women",
            "slug": "textiles-women",
            "parent_id": null,
            "type": "textiles",
            "order": 1
        },
        "children": [
            {
                "id": 5,
                "name": "Dresses & Gowns",
                "slug": "textiles-women-dresses-gowns",
                "parent_id": 1,
                "type": "textiles",
                "order": 1
            },
            {
                "id": 6,
                "name": "Two-Piece Sets",
                "slug": "textiles-women-two-piece-sets",
                "parent_id": 1,
                "type": "textiles",
                "order": 2
            }
        ],
        "entity_type": "products"
    }
}
```

**Error Response (Not Found):**
```json
{
    "message": "No query results for model [App\\Models\\Category] 999"
}
```
HTTP Status: 404

---

### 4. Get Category Items

Retrieve items (products, businesses, or initiatives) for a specific category.

```
GET /api/categories/{type}/{slug}/items
```

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `type` | string | Yes | Category type |
| `slug` | string | Yes | Category slug |
| `per_page` | integer | No | Items per page (1-50, default: 15) |
| `page` | integer | No | Page number (default: 1) |

**Request Example - Products (textiles):**
```
GET /api/categories/textiles/textiles-women-dresses-gowns/items?per_page=10&page=1
```

**Response (Products):**
```json
{
    "status": "success",
    "data": {
        "category": {
            "id": 5,
            "type": "textiles",
            "name": "Dresses & Gowns",
            "slug": "textiles-women-dresses-gowns",
            "parent_id": 1,
            "entity_type": "products"
        },
        "items": {
            "current_page": 1,
            "data": [
                {
                    "id": 1,
                    "seller_profile_id": 1,
                    "category_id": 5,
                    "name": "Elegant Ankara Dress",
                    "gender": "female",
                    "style": "Traditional",
                    "tribe": "Yoruba",
                    "description": "Beautiful handmade Ankara dress",
                    "image": "https://example.com/image.jpg",
                    "size": "M",
                    "processing_time_type": "normal",
                    "processing_days": 7,
                    "price": "25000.00",
                    "status": "approved",
                    "avg_rating": 4.5,
                    "created_at": "2026-01-15T10:00:00.000000Z",
                    "updated_at": "2026-01-15T10:00:00.000000Z",
                    "category": {
                        "id": 5,
                        "name": "Dresses & Gowns",
                        "slug": "textiles-women-dresses-gowns",
                        "parent_id": 1,
                        "type": "textiles"
                    },
                    "seller_profile": {
                        "id": 1,
                        "business_name": "Ankara Palace",
                        "business_email": "info@ankarapalace.com",
                        "city": "Lagos",
                        "state": "Lagos"
                    }
                }
            ],
            "first_page_url": "http://localhost/api/categories/textiles/textiles-women-dresses-gowns/items?page=1",
            "from": 1,
            "last_page": 1,
            "last_page_url": "http://localhost/api/categories/textiles/textiles-women-dresses-gowns/items?page=1",
            "next_page_url": null,
            "path": "http://localhost/api/categories/textiles/textiles-women-dresses-gowns/items",
            "per_page": 10,
            "prev_page_url": null,
            "to": 1,
            "total": 1
        }
    }
}
```

**Request Example - Businesses (art):**
```
GET /api/categories/art/art-sculpture/items
```

**Response (Businesses):**
```json
{
    "status": "success",
    "data": {
        "category": {
            "id": 50,
            "type": "art",
            "name": "Sculpture",
            "slug": "art-sculpture",
            "parent_id": null,
            "entity_type": "businesses"
        },
        "items": {
            "current_page": 1,
            "data": [
                {
                    "id": 1,
                    "user_id": 5,
                    "category_id": 50,
                    "subcategory_id": null,
                    "category": "art",
                    "business_name": "African Sculpture Studio",
                    "business_description": "Contemporary African sculpture art",
                    "business_email": "info@sculptestudio.com",
                    "business_phone_number": "+2348012345678",
                    "country": "Nigeria",
                    "state": "Lagos",
                    "city": "Victoria Island",
                    "address": "123 Art Lane",
                    "store_status": "approved",
                    "created_at": "2026-01-15T10:00:00.000000Z",
                    "updated_at": "2026-01-15T10:00:00.000000Z",
                    "user": {
                        "id": 5,
                        "firstname": "John",
                        "lastname": "Doe"
                    },
                    "category_relation": {
                        "id": 50,
                        "name": "Sculpture",
                        "slug": "art-sculpture",
                        "parent_id": null,
                        "type": "art"
                    },
                    "subcategory_relation": null
                }
            ],
            "first_page_url": "...",
            "from": 1,
            "last_page": 1,
            "last_page_url": "...",
            "next_page_url": null,
            "path": "...",
            "per_page": 15,
            "prev_page_url": null,
            "to": 1,
            "total": 1
        }
    }
}
```

**Request Example - Initiatives (sustainability):**
```
GET /api/categories/sustainability/sustainability-recycling/items
```

**Response (Initiatives):**
```json
{
    "status": "success",
    "data": {
        "category": {
            "id": 80,
            "type": "sustainability",
            "name": "Recycling Solutions",
            "slug": "sustainability-recycling-solutions",
            "parent_id": null,
            "entity_type": "initiatives"
        },
        "items": {
            "current_page": 1,
            "data": [
                {
                    "id": 1,
                    "title": "Community Recycling Program",
                    "description": "A community-based recycling initiative",
                    "image_url": "https://example.com/recycling.jpg",
                    "category_id": 80,
                    "category": "recycling",
                    "status": "active",
                    "target_amount": "500000.00",
                    "current_amount": "125000.00",
                    "impact_metrics": "1000 kg waste recycled",
                    "start_date": "2026-01-01",
                    "end_date": "2026-12-31",
                    "partners": ["Partner A", "Partner B"],
                    "participant_count": 250,
                    "progress_percentage": 25.0,
                    "created_at": "2026-01-01T00:00:00.000000Z",
                    "updated_at": "2026-01-15T10:00:00.000000Z",
                    "admin": {
                        "id": 1,
                        "firstname": "Admin",
                        "lastname": "User"
                    },
                    "category_relation": {
                        "id": 80,
                        "name": "Recycling Solutions",
                        "slug": "sustainability-recycling-solutions",
                        "parent_id": null,
                        "type": "sustainability"
                    }
                }
            ],
            "first_page_url": "...",
            "from": 1,
            "last_page": 1,
            "last_page_url": "...",
            "next_page_url": null,
            "path": "...",
            "per_page": 15,
            "prev_page_url": null,
            "to": 1,
            "total": 1
        }
    }
}
```

**Error Response (Invalid Type):**
```json
{
    "status": "error",
    "message": "Invalid category type. Valid types: textiles, shoes_bags, afro_beauty_products, afro_beauty_services, art, school, sustainability"
}
```
HTTP Status: 400

---

## Registration Forms - How to Use Categories

### Creating Products

Products should use `category_id` from these types:
- `textiles`
- `shoes_bags`
- `afro_beauty_products`

**Request:**
```
POST /api/products
Authorization: Bearer {token}
Content-Type: application/json

{
    "category_id": 5,  // Must be from product types
    "name": "Elegant Ankara Dress",
    "gender": "female",
    "style": "Traditional",
    "tribe": "Yoruba",
    "description": "Beautiful handmade Ankara dress",
    "image": "https://example.com/image.jpg",
    "size": "M",
    "processing_time_type": "normal",
    "processing_days": 7,
    "price": 25000.00
}
```

### Registering Businesses

Businesses should use `category_id` from these types:
- `art`
- `school`
- `afro_beauty_services`

**Request:**
```
POST /api/business
Authorization: Bearer {token}
Content-Type: application/json

{
    "category_id": 50,  // Must be from business types
    "category": "art",  // Legacy field: art, school, or afro_beauty_services
    "country": "Nigeria",
    "state": "Lagos",
    "city": "Victoria Island",
    "address": "123 Art Lane",
    "business_email": "info@studio.com",
    "business_phone_number": "+2348012345678",
    "business_name": "African Sculpture Studio",
    "business_description": "Contemporary African sculpture art",
    "offering_type": "providing_service",
    "service_list": "[{\"name\": \"Sculpture\", \"price\": 50000}]",
    "professional_title": "Sculptor"
}
```

### Creating Sustainability Initiatives (Admin)

Initiatives should use `category_id` from:
- `sustainability`

**Request:**
```
POST /api/admin/sustainability
Authorization: Bearer {admin_token}
Content-Type: application/json

{
    "category_id": 80,  // Must be from sustainability type
    "title": "Community Recycling Program",
    "description": "A community-based recycling initiative",
    "image_url": "https://example.com/recycling.jpg",
    "target_amount": 500000,
    "start_date": "2026-01-01",
    "end_date": "2026-12-31",
    "partners": ["Partner A", "Partner B"],
    "status": "active"
}
```

---

## Category Structure Examples

### Textiles (3 levels)
```
textiles/
├── Women (textiles-women)
│   ├── Dresses & Gowns (textiles-women-dresses-gowns)
│   ├── Two-Piece Sets (textiles-women-two-piece-sets)
│   ├── Wrappers & Skirts (textiles-women-wrappers-skirts)
│   └── ...
├── Men (textiles-men)
│   ├── Full Suits & Gowns (textiles-men-full-suits-gowns)
│   ├── Two-Piece Sets (textiles-men-two-piece-sets)
│   └── ...
├── Unisex (textiles-unisex)
│   └── ...
└── Fabrics (textiles-fabrics)
    ├── Ankara (textiles-fabrics-ankara)
    ├── Kente (textiles-fabrics-kente)
    └── ...
```

### Art (2 levels - leaf only)
```
art/
├── Sculpture (art-sculpture)
├── Painting (art-painting)
├── Mask (art-mask)
├── Mixed Media (art-mixed-media)
└── Installation (art-installation)
```

### Afro Beauty - Two Tabs
```
Tab 1 - Products (afro_beauty_products):
├── Hair Care (afro-beauty-products-hair-care)
├── Skin Care (afro-beauty-products-skin-care)
├── Makeup & Color Cosmetics (afro-beauty-products-makeup-color-cosmetics)
└── ...

Tab 2 - Services (afro_beauty_services):
├── Hair Care & Styling Services (afro-beauty-services-hair-care-styling-services)
├── Skin Care & Aesthetics Services (afro-beauty-services-skin-care-aesthetics-services)
├── Makeup Artistry Services (afro-beauty-services-makeup-artistry-services)
└── ...
```

---

## Valid Category Types

| Type | Entity Returned | Depth |
|------|-----------------|-------|
| `textiles` | Products | 3 levels |
| `shoes_bags` | Products | 3 levels |
| `afro_beauty_products` | Products | 2 levels |
| `afro_beauty_services` | BusinessProfiles | 2 levels |
| `art` | BusinessProfiles | 2 levels |
| `school` | BusinessProfiles | 2 levels |
| `sustainability` | SustainabilityInitiatives | 2 levels |

---

## Error Codes

| HTTP Status | Error | Description |
|-------------|-------|-------------|
| 400 | Invalid category type | The provided type is not valid |
| 404 | Not found | Category with the given ID or slug does not exist |
| 422 | Validation error | Missing or invalid required parameters |
