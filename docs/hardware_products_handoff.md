# Hardware Products Handoff

This document covers the new `hardware` product category, how mobile should consume it, and how admin should manage it.

## Summary

- `hardware` replaces the old idea of `technology`
- users can browse and view hardware products like other approved products
- sellers cannot create hardware products
- admins create, update, and delete hardware products
- admin-created hardware products are attached to a dedicated platform seller profile: `Ojá-Ẹwà`

## Ownership Model

Hardware products are platform-managed products.

That means:

- `seller_profile_id` points to the platform seller profile
- the seller identity is the platform seller `Ojá-Ẹwà`
- these products are uploaded by admin only
- public product responses still include seller data
- admin product detail responses still include seller data

Frontend implication:

- frontend contract stays stable
- hardware products can still render a seller card
- seller name for hardware products should be `Ojá-Ẹwà`

## Category Type

New product category type:

- `hardware`

Public category endpoints now support:

- `GET /api/categories?type=hardware`
- `GET /api/categories/all`

Public product filters now include:

- `hardware` in `product_category_types`
- `hardware` in `category_trees`

## Hardware Category Tree

Top-level categories:

1. `Beauty Equipment & Machines`
2. `Hair Tools & Machines`
3. `Fashion Production Equipment`
4. `Printing & Branding Equipment`
5. `Packaging & Finishing Equipment`
6. `Content Creation & Media Tools`
7. `Smart Fashion & Wearable Tech`
8. `Renewable Energy`

Leaf examples:

- `Facial Machines`
- `Hair Dryers`
- `Sewing Machines (Manual & Industrial)`
- `Heat Press Machines`
- `Sealing Machines`
- `Ring Lights`
- `Fitness Wearables`
- `Solar Inverter Systems`

## Public Mobile APIs

### 1. Get hardware categories

`GET /api/categories?type=hardware`

Response:

```json
{
  "status": "success",
  "data": [
    {
      "id": 901,
      "name": "Beauty Equipment & Machines",
      "slug": "hardware-beauty-equipment-machines",
      "type": "hardware",
      "children": [
        {
          "id": 902,
          "name": "Facial Machines",
          "slug": "hardware-beauty-equipment-machines-facial-machines",
          "type": "hardware",
          "children": []
        }
      ]
    }
  ],
  "meta": {
    "type": "hardware",
    "returns": "products"
  }
}
```

### 2. Get all category trees

`GET /api/categories/all`

Frontend should expect `hardware` in:

```json
{
  "status": "success",
  "data": {
    "textiles": [],
    "shoes_bags": [],
    "afro_beauty_products": [],
    "art": [],
    "hardware": [],
    "school": [],
    "sustainability": []
  }
}
```

### 3. Get product filters

`GET /api/products/filters`

Relevant response shape:

```json
{
  "status": "success",
  "data": {
    "product_category_types": [
      "textiles",
      "shoes_bags",
      "afro_beauty_products",
      "art",
      "hardware"
    ],
    "category_trees": {
      "hardware": [
        {
          "id": 901,
          "name": "Beauty Equipment & Machines",
          "slug": "hardware-beauty-equipment-machines",
          "children": [
            {
              "id": 902,
              "name": "Facial Machines",
              "slug": "hardware-beauty-equipment-machines-facial-machines"
            }
          ]
        }
      ]
    }
  }
}
```

### 4. Search products

`GET /api/products/search?type=hardware&q=machine`

`type=hardware` is now valid.

### 5. Browse products

`GET /api/products/browse`

Hardware products appear here if:

- `status = approved`

### 6. Public single product

`GET /api/products/public/{id}`

Important for hardware:

```json
{
  "status": "success",
  "data": {
    "product": {
      "id": 501,
      "seller_profile_id": 77,
      "category_id": 902,
      "name": "Industrial Embroidery Machine",
      "status": "approved"
    },
    "suggestions": []
  }
}
```

Frontend rule:

- treat hardware products like normal public products
- seller data is expected to exist and represent the platform seller

## Seller App Rules

Seller product creation endpoint:

- `POST /api/products`

Sellers must **not** use this endpoint for hardware.

If they try, backend returns validation error on `category_id`.

Example:

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "category_id": [
      "The selected category is invalid or not a seller product category. Valid types: textiles, shoes_bags, afro_beauty_products, art"
    ]
  }
}
```

## Admin APIs

All admin endpoints require admin auth:

- `Authorization: Bearer {admin_token}`

### 1. List products

`GET /api/admin/market/products`

You can filter hardware only with:

`GET /api/admin/market/products?type=hardware`

Response items include `category`.

### 2. Create hardware product

`POST /api/admin/market/products`

Request:

```json
{
  "category_id": 902,
  "name": "Industrial Embroidery Machine",
  "description": "Admin-managed hardware product.",
  "image": "https://example.com/embroidery-machine.jpg",
  "processing_time_type": "normal",
  "processing_days": 5,
  "price": 850000,
  "fabric_type": null,
  "style": null,
  "tribe": null,
  "size": null,
  "gender": null,
  "status": "approved"
}
```

Notes:

- `category_id` must be a `hardware` category
- if `status` is omitted, backend defaults to `approved`
- backend automatically attaches the product to the platform seller profile `Ojá-Ẹwà`

Success response:

```json
{
  "status": "success",
  "message": "Hardware product created successfully",
  "data": {
    "id": 501,
    "seller_profile_id": 77,
    "category_id": 902,
    "name": "Industrial Embroidery Machine",
    "status": "approved",
    "category": {
      "id": 902,
      "name": "Embroidery Machines",
      "type": "hardware"
    }
  }
}
```

### 3. Update hardware product

`PUT /api/admin/market/products/{id}`

Request example:

```json
{
  "name": "Updated Hardware Product",
  "price": 250000
}
```

Success response:

```json
{
  "status": "success",
  "message": "Hardware product updated successfully",
  "data": {
    "id": 501,
    "name": "Updated Hardware Product"
  }
}
```

Constraint:

- this endpoint is intended for hardware products only

### 4. Delete hardware product

`DELETE /api/admin/market/products/{id}`

Success response:

```json
{
  "status": "success",
  "message": "Hardware product deleted successfully"
}
```

Constraint:

- this endpoint is intended for hardware products only

### 5. View single admin product

`GET /api/admin/products/{id}`

Hardware response note:

```json
{
  "status": "success",
  "data": {
    "product": {
      "id": 501,
      "category": {
        "id": 902,
        "type": "hardware"
      }
    },
    "seller": {
      "business_name": "Ojá-Ẹwà"
    }
  }
}
```

## Mobile Rendering Rules

### Public app

- include `hardware` in category tabs/filters
- show approved hardware products in browse/search
- render hardware products with the platform seller identity `Ojá-Ẹwà`

### Seller app

- do not show hardware in seller product creation category picker
- treat backend validation error on hardware category as expected behavior

### Admin app

- use `GET /api/categories?type=hardware` to populate the admin category picker
- use `POST /api/admin/market/products` to create hardware products
- use `PUT /api/admin/market/products/{id}` to edit hardware products
- use `DELETE /api/admin/market/products/{id}` to remove hardware products
- use `GET /api/admin/market/products?type=hardware` to list hardware products only

## Final Rule

Hardware products are **platform-managed catalog products**, not regular seller-submitted marketplace listings.

That is why:

- users can see them
- admins can manage them
- sellers cannot create them
- they are attached to the dedicated platform seller `Ojá-Ẹwà`
