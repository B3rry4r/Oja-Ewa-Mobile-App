# Business Profile Registration — Inputs & UI Flow (for Backend + Mobile)

Source of truth: `docs/api_docs/business_seller.md` (Business Profile: `POST /api/business`).

This document summarizes:
- Required inputs per category (`beauty`, `brand`, `school`, `music`)
- Conditional rules driven by `offering_type`
- **Concrete JSON shapes** for `product_list` and `service_list` that the UI can generate (docs currently only say “json”)
- UI flow checklist (what screens/steps must collect)

---

## Endpoint
- **Create Business Profile:** `POST /api/business`
- **Auth:** `auth:sanctum`
- **Notes from docs:**
  - one business per category per user
  - different validation rules per category + offering_type

---

## Common fields (all categories)

| Field | Required | Type / Constraints |
|---|---:|---|
| `category` | Yes | enum: `beauty` \| `brand` \| `school` \| `music` |
| `country` | Yes | string, max 100 |
| `state` | Yes | string, max 100 |
| `city` | Yes | string, max 100 |
| `address` | Yes | string, max 255 |
| `business_email` | Yes | email, max 100 |
| `business_phone_number` | Yes | string, max 20 |
| `business_name` | Yes | string, max 100 |
| `business_description` | Yes | string, max 1000 |
| `website_url` | No | url, max 255 |
| `instagram` | No | string, max 100 |
| `facebook` | No | string, max 100 |
| `business_logo` | No | string, max 255 |
| `identity_document` | No* | string, max 255 (*required for music; see below) |

---

## Conditional fields (based on `offering_type`)

| offering_type | Required fields | Field types |
|---|---|---|
| `providing_service` | `service_list`, `professional_title` | `service_list`: JSON (required) • `professional_title`: string max 100 (required) |
| `selling_product` | `product_list`, `business_certificates` | `product_list`: JSON (required) • `business_certificates`: JSON (required) |

> Docs note: these are required **when offering_type equals the corresponding value**.

---

## Category-specific required fields

### Category = `school`

| Field | Required | Type / Constraints |
|---|---:|---|
| `school_type` | Yes | enum: `fashion` \| `music` \| `catering` \| `beauty` |
| `school_biography` | Yes | string, max 1000 |
| `classes_offered` | Yes | JSON |

### Category = `music`

| Field | Required | Type / Constraints | Notes |
|---|---:|---|---|
| `music_category` | Yes | enum: `dj` \| `artist` \| `producer` | |
| `identity_document` | Yes | string, max 255 | required for music |
| `youtube` | Conditionally | string, max 255 | at least one of youtube/spotify required |
| `spotify` | Conditionally | string, max 255 | at least one of youtube/spotify required |

### Category = `beauty`
No additional required fields beyond common + offering_type conditional requirements.

### Category = `brand`
No additional required fields beyond common + offering_type conditional requirements.

---

## Canonical JSON schemas (CONFIRMED)

Source of truth: `docs/canonical_json.md` (confirmed by backend agent).

### General rule (very important)
- These fields are stored as JSON columns and validated as `nullable|json`.
- With `Content-Type: application/json`, send these as **real JSON arrays/objects** (NOT JSON-encoded strings).
- With multipart/form-data, send them as **stringified JSON**.

### 1) `product_list` (for `offering_type = selling_product`)
Canonical shape: **Array of strings**
```json
["Ankara Dresses", "Kente Fabric", "African Jewelry"]
```

### 2) `service_list` (for `offering_type = providing_service`)
Canonical shape: **Array of objects**
```json
[
  {"name": "Hair Styling", "price_range": "₦5,000 - ₦15,000"},
  {"name": "Makeup Application", "price_range": "₦10,000 - ₦30,000"}
]
```

### 3) `business_certificates` (for `offering_type = selling_product`)
Canonical shape: **Array of objects**
```json
[
  {"name": "CAC Registration", "url": "https://..."},
  {"name": "NAFDAC Certificate", "url": "https://..."}
]
```

### 4) `classes_offered` (for `category = school`)
Canonical shape: **Array of objects**
```json
[
  {"name": "Beginner Makeup", "duration": "4 weeks"},
  {"name": "Advanced Tailoring", "duration": "6 weeks"}
]
```

---

## UI flow checklist (Show Your Business)

### Step 1: Basic business info (common)
Collect:
- business_name, business_description
- business_email, business_phone_number
- country/state/city/address
- social links (optional)

### Step 2: Choose category
- `category`: beauty | brand | school | music

### Step 3: Category form (conditional)

- **Beauty / Brand**
  - choose offering_type
  - if providing_service → collect professional_title + service_list
  - if selling_product → collect product_list + business_certificates

- **School**
  - school_type + school_biography + classes_offered
  - plus offering_type conditional fields if the product supports it

- **Music**
  - music_category
  - identity_document
  - youtube/spotify (at least one)
  - plus offering_type conditional fields if the product supports it

### Step 4: Submit
- `POST /api/business`
- capture returned `id` (required for update/upload/deactivate)

### Step 5: Uploads (if needed)
- `POST /api/business/{id}/upload`

### Step 6: Post-registration management
- `GET /api/business` (list yours)
- `GET /api/business/{id}`
- `PUT /api/business/{id}`
- `PATCH /api/business/{id}/deactivate`

---

## Action needed from backend agent
1) Confirm and document canonical JSON schemas for:
- `product_list`
- `service_list`
- `classes_offered`
- `business_certificates`

2) Clarify whether these JSON fields are expected as real JSON arrays/objects or JSON-encoded strings.

