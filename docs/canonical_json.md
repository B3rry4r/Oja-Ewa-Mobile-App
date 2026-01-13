# Canonical JSON Schema Documentation - Business Profile Fields

## 🎯 DEFINITIVE ANSWER

### How JSON Fields Are Handled:

**Database Storage:** JSON type columns (PostgreSQL `json` type)  
**Laravel Model Casting:** Automatic conversion via `$casts` property  
**API Request Format:** **DEPENDS ON CONTENT-TYPE HEADER**

---

## 📊 The Truth About JSON Fields

### Database Schema (Migration):
```php
$table->json('product_list')->nullable();
$table->json('service_list')->nullable();
$table->json('business_certificates')->nullable();
$table->json('classes_offered')->nullable();
```

### Laravel Model Casting:
```php
protected $casts = [
    'product_list' => 'json',
    'service_list' => 'json',
    'business_certificates' => 'json',
    'classes_offered' => 'json',
];
```

### Request Validation:
```php
'product_list' => 'nullable|json',
'service_list' => 'nullable|json',
'business_certificates' => 'nullable|json',
'classes_offered' => 'nullable|json',
```

---

## 🔑 CRITICAL: Content-Type Determines Format

### Option 1: `Content-Type: application/json` (RECOMMENDED)

**Send as ACTUAL JSON arrays/objects:**

```javascript
fetch('/api/business', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer token'
  },
  body: JSON.stringify({
    category: "beauty",
    offering_type: "providing_service",
    service_list: [  // ← ACTUAL JSON ARRAY (not string)
      {
        name: "Hair Styling",
        description: "Professional styling",
        price_range: "₦5,000 - ₦15,000"
      },
      {
        name: "Makeup Application",
        description: "Bridal makeup",
        price_range: "₦10,000 - ₦30,000"
      }
    ],
    professional_title: "Licensed Cosmetologist",
    // ... other fields
  })
})
```

**Laravel receives:** Actual array/object (already parsed)  
**Validation:** Passes `json` validation  
**Storage:** Automatically converted to JSON string for database

---

### Option 2: `Content-Type: multipart/form-data` (For File Uploads)

**Send as JSON-encoded strings:**

```javascript
const formData = new FormData();
formData.append('category', 'beauty');
formData.append('offering_type', 'providing_service');

// ← Must JSON.stringify() for form-data!
formData.append('service_list', JSON.stringify([
  {
    name: "Hair Styling",
    description: "Professional styling",
    price_range: "₦5,000 - ₦15,000"
  },
  {
    name: "Makeup Application",
    description: "Bridal makeup",
    price_range: "₦10,000 - ₦30,000"
  }
]));

formData.append('professional_title', 'Licensed Cosmetologist');
formData.append('business_logo', fileInput.files[0]); // File upload

fetch('/api/business', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer token'
    // NO Content-Type header - browser sets it automatically with boundary
  },
  body: formData
})
```

**Laravel receives:** JSON string  
**Validation:** Checks if string is valid JSON  
**Storage:** String stored directly as JSON in database

---

## 📋 Canonical Schemas for Each Field

### 1. `product_list`

**Required when:** `offering_type: "selling_product"`

**Schema:**
```typescript
type ProductList = Array<Product | string>;

interface Product {
  name: string;           // Product name
  description?: string;   // Optional description
  category?: string;      // Optional category
  price?: string;        // Optional price info
}
```

**Examples:**

**Detailed format:**
```json
[
  {
    "name": "Ankara Dresses",
    "description": "Traditional African print dresses",
    "category": "Women's Clothing",
    "price": "₦15,000 - ₦30,000"
  },
  {
    "name": "Kente Fabric",
    "description": "Authentic Ghanaian Kente cloth",
    "category": "Fabrics"
  }
]
```

**Simplified format (also valid):**
```json
["Ankara Dresses", "Kente Fabric", "African Jewelry", "Beaded Bags"]
```

**Stored in database as:**
```json
[{"name":"Ankara Dresses","description":"Traditional African print dresses","category":"Women's Clothing","price":"₦15,000 - ₦30,000"},{"name":"Kente Fabric","description":"Authentic Ghanaian Kente cloth","category":"Fabrics"}]
```

---

### 2. `service_list`

**Required when:** `offering_type: "providing_service"`

**Schema:**
```typescript
type ServiceList = Array<Service | string>;

interface Service {
  name: string;           // Service name
  description?: string;   // Optional description
  duration?: string;      // Optional duration (e.g., "1-2 hours")
  price_range?: string;   // Optional price range
}
```

**Examples:**

**Detailed format:**
```json
[
  {
    "name": "Hair Styling",
    "description": "Professional hair styling and treatment",
    "duration": "1-2 hours",
    "price_range": "₦5,000 - ₦15,000"
  },
  {
    "name": "Makeup Application",
    "description": "Bridal and event makeup",
    "duration": "1.5 hours",
    "price_range": "₦10,000 - ₦30,000"
  },
  {
    "name": "Nail Services",
    "description": "Manicure and pedicure",
    "duration": "1 hour",
    "price_range": "₦3,000 - ₦8,000"
  }
]
```

**Simplified format:**
```json
["Hair Styling", "Makeup Application", "Nail Services", "Spa Treatment"]
```

**Stored in database as:**
```json
[{"name":"Hair Styling","description":"Professional hair styling and treatment","duration":"1-2 hours","price_range":"₦5,000 - ₦15,000"},{"name":"Makeup Application","description":"Bridal and event makeup","duration":"1.5 hours","price_range":"₦10,000 - ₦30,000"}]
```

---

### 3. `business_certificates`

**Required when:** `offering_type: "selling_product"`

**Schema:**
```typescript
type BusinessCertificates = Array<Certificate | string>;

interface Certificate {
  type?: string;          // Certificate type (e.g., "Business Registration")
  file_path: string;      // Path to certificate file
  issued_date?: string;   // Issue date (YYYY-MM-DD)
  expiry_date?: string | null; // Expiry date or null if no expiry
}
```

**Examples:**

**Detailed format:**
```json
[
  {
    "type": "Business Registration Certificate",
    "file_path": "storage/certificates/cert_123.pdf",
    "issued_date": "2023-06-15",
    "expiry_date": "2028-06-15"
  },
  {
    "type": "Tax Identification Number",
    "file_path": "storage/certificates/tin_456.pdf",
    "issued_date": "2023-07-01",
    "expiry_date": null
  }
]
```

**Simplified format (file paths only):**
```json
["storage/certificates/cert1.pdf", "storage/certificates/cert2.pdf"]
```

**After file upload (controller line 232):**
```json
["storage/business_documents/abc123xyz.pdf"]
```

**Note:** The upload endpoint appends to existing array using `json_encode()`

---

### 4. `classes_offered`

**Required when:** `category: "school"`

**Schema:**
```typescript
type ClassesOffered = Array<Course | string>;

interface Course {
  name: string;           // Course/class name
  description?: string;   // Course description
  duration?: string;      // Duration (e.g., "3 months", "8 weeks")
  level?: string;         // Level (e.g., "Beginner", "Advanced")
  price?: string;         // Course fee
  schedule?: string;      // Class schedule/timing
}
```

**Examples:**

**Detailed format:**
```json
[
  {
    "name": "Fashion Design Basics",
    "description": "Introduction to fashion design and pattern making",
    "duration": "3 months",
    "level": "Beginner",
    "price": "₦50,000",
    "schedule": "Mon, Wed, Fri - 10am to 2pm"
  },
  {
    "name": "Advanced Tailoring",
    "description": "Professional tailoring techniques",
    "duration": "6 months",
    "level": "Advanced",
    "price": "₦120,000",
    "schedule": "Tue, Thu - 9am to 4pm"
  }
]
```

**Simplified format:**
```json
[
  "Fashion Design Basics - 3 months",
  "Advanced Tailoring - 6 months",
  "Fashion Illustration - 2 months"
]
```

**Stored in database as:**
```json
[{"name":"Fashion Design Basics","description":"Introduction to fashion design and pattern making","duration":"3 months","level":"Beginner","price":"₦50,000","schedule":"Mon, Wed, Fri - 10am to 2pm"}]
```

---

## 🔧 Implementation Guide

### Frontend: Using `Content-Type: application/json` (EASIEST)

```javascript
// React/JavaScript example
const createBusiness = async () => {
  const response = await fetch('https://api.example.com/api/business', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/json'
    },
    body: JSON.stringify({
      category: "beauty",
      country: "Nigeria",
      state: "Lagos",
      city: "Lekki",
      address: "45 Beauty Lane",
      business_email: "beauty@example.com",
      business_phone_number: "+2348012345678",
      business_name: "Glam Beauty Studio",
      business_description: "Professional beauty services",
      offering_type: "providing_service",
      
      // ✅ Send as ACTUAL array (not JSON string)
      service_list: [
        {
          name: "Hair Styling",
          description: "Professional styling",
          price_range: "₦5,000 - ₦15,000"
        },
        {
          name: "Makeup Application",
          description: "Bridal makeup",
          price_range: "₦10,000 - ₦30,000"
        }
      ],
      
      professional_title: "Licensed Cosmetologist"
    })
  });
  
  return await response.json();
};
```

---

### Frontend: Using `multipart/form-data` (For File Uploads)

```javascript
// When you need to upload files
const createBusinessWithFiles = async () => {
  const formData = new FormData();
  
  // Regular fields
  formData.append('category', 'brand');
  formData.append('offering_type', 'selling_product');
  formData.append('business_name', 'Fashion House');
  // ... other fields
  
  // ✅ JSON fields MUST be stringified for form-data
  formData.append('product_list', JSON.stringify([
    {
      name: "Ankara Dresses",
      description: "Traditional dresses",
      category: "Women's Wear"
    },
    {
      name: "Accessories",
      description: "Fashion accessories"
    }
  ]));
  
  formData.append('business_certificates', JSON.stringify([
    "storage/certificates/cert1.pdf"
  ]));
  
  // File uploads
  formData.append('business_logo', logoFile);
  formData.append('identity_document', idDocFile);
  
  const response = await fetch('https://api.example.com/api/business', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/json'
      // NO Content-Type - browser sets it with boundary
    },
    body: formData
  });
  
  return await response.json();
};
```

---

## ✅ Validation Rules

Laravel validates these fields with: `'field_name' => 'nullable|json'`

**What this means:**
- Field is optional (nullable)
- If provided, must be valid JSON

**Valid inputs:**
1. `null` - Field not provided
2. `"[]"` - Empty array (as JSON string)
3. `[]` - Empty array (as actual array when Content-Type is JSON)
4. `"[...]"` - Non-empty array (as JSON string)
5. `[...]` - Non-empty array (as actual array when Content-Type is JSON)

**Invalid inputs:**
- `"[invalid json"` - Malformed JSON string
- `"not an array"` - Valid JSON but not an array
- `123` - Not JSON
- `"plain string"` - Valid JSON but should be array

---

## 🎯 Quick Reference Card

| Field | Required When | Format | Can Be String Array? | Can Be Object Array? |
|-------|--------------|--------|---------------------|---------------------|
| `product_list` | `offering_type: "selling_product"` | Array | ✅ Yes | ✅ Yes |
| `service_list` | `offering_type: "providing_service"` | Array | ✅ Yes | ✅ Yes |
| `business_certificates` | `offering_type: "selling_product"` | Array | ✅ Yes | ✅ Yes |
| `classes_offered` | `category: "school"` | Array | ✅ Yes | ✅ Yes |

---

## 📊 What Gets Stored in Database

### Request Input (JSON Content-Type):
```javascript
{
  "service_list": [
    {"name": "Hair Styling", "price_range": "₦5,000"},
    {"name": "Makeup", "price_range": "₦10,000"}
  ]
}
```

### Database Storage (PostgreSQL JSON column):
```json
[{"name":"Hair Styling","price_range":"₦5,000"},{"name":"Makeup","price_range":"₦10,000"}]
```

### Retrieved by Laravel (Auto-decoded by $casts):
```php
$business->service_list
// Returns: array(2) {
//   [0] => array("name" => "Hair Styling", "price_range" => "₦5,000")
//   [1] => array("name" => "Makeup", "price_range" => "₦10,000")
// }
```

### API Response (Auto-encoded to JSON):
```json
{
  "service_list": [
    {"name": "Hair Styling", "price_range": "₦5,000"},
    {"name": "Makeup", "price_range": "₦10,000"}
  ]
}
```

---

## 🚨 Common Mistakes

### ❌ WRONG: Double JSON encoding with Content-Type: application/json
```javascript
body: JSON.stringify({
  service_list: JSON.stringify([...])  // ← WRONG! Double encoding
})
```

### ✅ CORRECT: Single encoding
```javascript
body: JSON.stringify({
  service_list: [...]  // ← CORRECT! Single encoding
})
```

---

### ❌ WRONG: Not stringifying with multipart/form-data
```javascript
formData.append('service_list', [{name: "Hair"}]);  // ← WRONG! Object as-is
```

### ✅ CORRECT: Stringify for form-data
```javascript
formData.append('service_list', JSON.stringify([{name: "Hair"}]));  // ← CORRECT!
```

---

## 📝 Summary

### For `Content-Type: application/json`:
✅ Send as **ACTUAL arrays/objects** (not JSON strings)  
✅ Laravel receives them already parsed  
✅ `$casts` handles database conversion automatically

### For `Content-Type: multipart/form-data`:
✅ Send as **JSON strings** (use `JSON.stringify()`)  
✅ Laravel validates the JSON string  
✅ `$casts` decodes on retrieval

### Both methods work correctly!
The key is matching your Content-Type with your data format.

---

**Created:** January 2024  
**Status:** Canonical - This is the definitive schema  
**References:** 
- `StoreBusinessProfileRequest.php` (validation)
- `BusinessProfileController.php` (handling)
- `BusinessProfile.php` (model casts)
- `create_business_profiles_table.php` (schema)
