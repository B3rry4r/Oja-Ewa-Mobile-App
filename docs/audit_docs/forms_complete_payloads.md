# Full Form Payloads (Client Agent)

This document contains **complete request + response payloads** for the main creation/update forms the client app submits.

It is designed to be sent to the client agent so they can implement the full onboarding + creation flows correctly.

> Notes:
> - For category selection UI, use `GET /api/categories/all` (or `GET /api/categories?type=...`).
> - **Do not guess category slugs**.
> - Products require `category_id`.
> - Business profiles should send `category_id`/`subcategory_id` (recommended).
> - Business profile file fields are uploaded after create via `/api/business/{id}/upload`.

---

## 1) Seller Product Creation Form

### 1.1 Create Product

**POST** `/api/products`

**Auth:** Required (Bearer token) – user must have an approved seller profile.

**Headers**
- `Authorization: Bearer <token>`
- `Accept: application/json`
- `Content-Type: application/json`

**Request body (complete — TEXTILES example)**
```json
{
  "category_id": 5,
  "name": "Traditional Agbada",
  "gender": "male",
  "style": "Agbada",
  "tribe": "Yoruba",
  "description": "Handmade Agbada set with premium embroidery.",
  "image": "https://images.unsplash.com/photo-1485968579580-b6d095142e6e?w=500&h=500&fit=crop",
  "size": "XL",
  "processing_time_type": "normal",
  "processing_days": 5,
  "fabric_type": "Ankara",
  "price": 45000
}
```

**Request body (complete — SHOES & BAGS example)**
```json
{
  "category_id": 70,
  "name": "Leather Sandals",
  "gender": "male",
  "style": "Leather Sandals",
  "tribe": "Hausa",
  "description": "Handcrafted leather sandals with traditional patterns.",
  "image": "https://images.unsplash.com/photo-1514986888952-8cd320577b68?w=500&h=500&fit=crop",
  "size": "42",
  "processing_time_type": "normal",
  "processing_days": 4,
  "price": 18000
}
```

**Request body (complete — AFRO BEAUTY PRODUCTS example)**
```json
{
  "category_id": 90,
  "name": "Shea Butter Hair Cream",
  "description": "Moisturizing hair cream for natural hair.",
  "image": "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=500&h=500&fit=crop",
  "processing_time_type": "normal",
  "processing_days": 2,
  "price": 3500
}
```

> Note: Afro Beauty Products and Art Products do **not** require `size`, `style`, `tribe`, `gender`, or `fabric_type`. Textiles require `fabric_type`; Shoes & Bags do not.

**Validation rules (backend)**
- `category_id` (required) must exist in `categories`
- `gender`: `male|female|unisex`
- `processing_time_type`: `normal|quick_quick`

**Success response (typical)**
```json
{
  "status": "success",
  "message": "Product created successfully",
  "data": {
    "id": 123,
    "seller_profile_id": 10,
    "category_id": 5,
    "name": "Traditional Agbada",
    "gender": "male",
    "style": "Agbada",
    "tribe": "Yoruba",
    "description": "Handmade Agbada set with premium embroidery.",
    "image": "https://images.unsplash.com/...",
    "size": "XL",
    "processing_time_type": "normal",
    "processing_days": 5,
    "price": "45000.00",
    "status": "pending",
    "created_at": "2026-01-15T12:00:00.000000Z",
    "updated_at": "2026-01-15T12:00:00.000000Z"
  }
}
```

**Common error responses**
- Missing category_id
```json
{
  "message": "The category id field is required.",
  "errors": { "category_id": ["Please select a product category"] }
}
```
- No seller profile / not authorized
```json
{
  "message": "This action is unauthorized."
}
```

### 1.2 Update Product

**PUT** `/api/products/{id}`

**Auth:** Required

**Request (example)**
```json
{
  "category_id": 6,
  "price": 47000,
  "description": "Updated description"
}
```

---

## 2) Business Profile Creation Form (Services / Schools)

### 2.1 Create Business Profile

**POST** `/api/business`

**Auth:** Required (Bearer token)

**Headers**
- `Authorization: Bearer <token>`
- `Accept: application/json`
- `Content-Type: application/json`

**Request body (complete, SCHOOL example)**
```json
{
  "category": "school",
  "category_id": 81,

  "country": "Nigeria",
  "state": "Lagos",
  "city": "Ikeja",
  "address": "123 School Street",

  "business_name": "OjaEwa Fashion School",
  "business_description": "We train students in tailoring, pattern drafting, and fashion design.",

  "business_email": "school@ojaewa.com",
  "business_phone_number": "08012345678",

  "website_url": "https://ojaewaschool.com",
  "instagram": "@ojaewaschool",
  "facebook": "ojaewaschool",

  "business_logo": null,
  "identity_document": null,
  "business_certificates": null,

  "offering_type": "providing_service",
  "service_list": "[{\"name\":\"Fashion Training\",\"price\":50000}]",
  "professional_title": "Head Instructor",

  "school_type": "fashion",
  "school_biography": "We have trained over 500 students.",
  "classes_offered": "[{\"title\":\"Beginner Tailoring\",\"duration\":\"8 weeks\"}]"
}
```

**Request body (complete, AFRO BEAUTY services example)**
```json
{
  "category": "afro_beauty_services",
  "category_id": 57,
  "subcategory_id": null,

  "country": "Nigeria",
  "state": "Lagos",
  "city": "Lekki",
  "address": "45 Beauty Avenue",

  "business_name": "Afro Beauty Styling Lounge",
  "business_description": "Hair care, styling and wellness services.",

  "business_email": "afrobeauty@ojaewa.com",
  "business_phone_number": "08022223333",

  "website_url": null,
  "instagram": "@afrobeautylounge",
  "facebook": null,

  "business_logo": null,
  "identity_document": null,
  "business_certificates": null,

  "offering_type": "providing_service",
  "service_list": "[{\"name\":\"Hair Styling\",\"price\":12000}]",
  "professional_title": "Senior Stylist"
}
```

### 2.2 Upload Business Files (after create)

**POST** `/api/business/my/{id}/upload`

**Auth:** Required

**Content-Type:** `multipart/form-data`

**Form fields**
- `file_type` (required): `identity_document | business_logo | business_certificates`
- `file` (required): binary file

**Example cURL**
```bash
curl -X POST "https://<host>/api/business/my/123/upload" \
  -H "Authorization: Bearer <token>" \
  -F "file_type=business_logo" \
  -F "file=@/path/to/logo.png"
```

**Success response (typical)**
```json
{
  "status": "success",
  "message": "File uploaded successfully",
  "data": {
    "business_id": 123,
    "file_type": "business_logo",
    "path": "storage/business_logos/logo.png"
  }
}
```

---

## 3) Sustainability Initiative Form (Admin)

### 3.1 Create Sustainability Initiative

**POST** `/api/admin/sustainability`

**Auth:** Required (Admin token)

**Headers**
- `Authorization: Bearer <admin_token>`
- `Accept: application/json`
- `Content-Type: application/json`

**Request body (complete)**
```json
{
  "title": "Zero Waste Initiative",
  "description": "Reducing textile waste through recycling programs.",
  "image_url": "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600&h=400&fit=crop",

  "category": "environmental",
  "category_id": 101,

  "status": "active",

  "target_amount": 1000000,
  "current_amount": 350000,

  "impact_metrics": "Collected 2 tons of textile waste",
  "start_date": "2026-01-01",
  "end_date": "2026-12-31",

  "partners": ["NGO A", "NGO B"],
  "participant_count": 1200,
  "progress_notes": "Phase 1 completed"
}
```

**Success response (typical)**
```json
{
  "status": "success",
  "message": "Sustainability initiative created successfully",
  "data": {
    "id": 1,
    "title": "Zero Waste Initiative",
    "description": "Reducing textile waste through recycling programs.",
    "image_url": "https://images.unsplash.com/...",
    "category": "environmental",
    "category_id": 101,
    "status": "active",
    "target_amount": "1000000.00",
    "current_amount": "350000.00",
    "created_by": 1,
    "created_at": "2026-01-15T12:00:00.000000Z",
    "updated_at": "2026-01-15T12:00:00.000000Z",
    "admin": {
      "id": 1,
      "firstname": "Super",
      "lastname": "Admin"
    }
  }
}
```

### 3.2 Update Sustainability Initiative

**PUT** `/api/admin/sustainability/{sustainabilityInitiative}`

**Request (example)**
```json
{
  "status": "completed",
  "current_amount": 1000000,
  "progress_notes": "Completed successfully"
}
```

---

## 4) Category selection for forms

### Recommended approach
1. Call `GET /api/categories/all`
2. Render the tree UI based on your form type
3. Submit the selected node’s `id` as `category_id` (and `subcategory_id` for businesses)

**Do NOT hardcode category IDs in the app.**

---

*Last updated: 2026-01-15*


 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │
│ ┃                                                ✅ What I Changed                                                 ┃ │
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │
│                                                                                                                      │
│                                        1) Fabrics removed from category tree                                         │
│                                                                                                                      │
│  • Fabrics are now filters, not categories                                                                           │
│  • Category tree is clean 3‑step for products                                                                        │
│                                                                                                                      │
│                                           2) Added fabric_type to products                                           │
│                                                                                                                      │
│  • New DB column: products.fabric_type                                                                               │
│  • Factory now seeds realistic fabric types                                                                          │
│  • Filterable via /api/products/browse and /api/products/search                                                      │
│                                                                                                                      │
│                                           3) Art is now a PRODUCT catalog                                            │
│                                                                                                                      │
│  • Art moved from business categories to product categories                                                          │
│  • Tree is now:                                                                                                      │
│    Art → Products → Sculpture/Painting/etc                                                                           │
│  • CategoryController returns products for art                                                                       │
│                                                                                                                      │
│                                               4) Gender filter removed                                               │
│                                                                                                                      │
│  • Not needed because Men/Women are already category groups                                                          │
│  • Removed from product filters/search/browse/suggestions                                                            │
│                                                                                                                      │
│                                     5) Product validation now category‑sensitive                                     │
│                                                                                                                      │
│  • Textiles require: fabric_type, style, tribe, size                                                                 │
│  • Shoes & Bags require: style, tribe, size (fabric optional)                                                        │
│  • Afro Beauty Products & Art Products: no apparel fields required                                                   │
│                                                                                                                      │
│                                              6) Business types updated                                               │
│                                                                                                                      │
│  • Art removed from BusinessProfiles                                                                                 │
│  • Business categories now only:                                                                                     │
│     • school                                                                                                         │
│     • afro_beauty_services                                                      