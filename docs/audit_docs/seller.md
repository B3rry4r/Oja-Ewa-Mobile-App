# Seller Orders & Buyer Tracking API Documentation

## Overview

This document covers:
1. Seller order management endpoints (Your Shop > Orders)
2. Buyer order tracking and details
3. Delivery fee logic

---

## Delivery Fee Logic

**Strategy: Flat Fee (₦2,000)**

All orders include a flat delivery fee of ₦2,000 regardless of:
- Number of items
- Order weight
- Delivery location

**Order Pricing Breakdown:**
- `subtotal`: Sum of (quantity × unit_price) for all order items
- `delivery_fee`: Fixed ₦2,000
- `total_price`: subtotal + delivery_fee

---

## Buyer Endpoints

### Get Order Details

**Endpoint:** `GET /api/orders/{order_id}`

**Authentication:** Required (Bearer token)

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "order_number": "ORD-000001",
    "status": "processing",
    "created_at": "2026-01-16T14:52:35.000000Z",
    "subtotal": 5000.00,
    "delivery_fee": 2000.00,
    "total_price": 7000.00,
    "tracking_number": "TRK123456789",
    "delivered_at": null,
    "shipping_address": "123 Main St, Lagos, Lagos State, Nigeria",
    "order_items": [
      {
        "id": 1,
        "product_id": 5,
        "quantity": 2,
        "unit_price": 2500.00,
        "product": {
          "id": 5,
          "name": "Ankara Dress",
          "image": "https://example.com/image.jpg"
        }
      }
    ],
    "avg_rating": 0
  }
}
```

### Get Order Tracking

**Endpoint:** `GET /api/orders/{order_id}/tracking`

**Authentication:** Required (Bearer token)

**Response:**
```json
{
  "status": "success",
  "data": {
    "estimated_delivery": "2026-01-21",
    "tracking_number": "TRK123456789",
    "stages": [
      {
        "status": "Order Placed",
        "timestamp": "2026-01-16T14:52:35.000000Z",
        "completed": true
      },
      {
        "status": "Processing",
        "timestamp": "2026-01-16T15:00:00.000000Z",
        "completed": true
      },
      {
        "status": "Shipped",
        "timestamp": null,
        "completed": false
      },
      {
        "status": "Delivered",
        "timestamp": null,
        "completed": false
      }
    ]
  }
}
```

**Stage Completion Logic:**
- `Order Placed`: Always completed (timestamp = order created_at)
- `Processing`: Completed when status is processing, shipped, or delivered
- `Shipped`: Completed when status is shipped or delivered
- `Delivered`: Completed when status is delivered (timestamp = delivered_at)

**Cancelled Orders:**
When an order is cancelled, an additional stage is appended:
```json
{
  "status": "Cancelled",
  "timestamp": "2026-01-16T16:00:00.000000Z",
  "completed": true,
  "reason": "Customer requested cancellation"
}
```

**Estimated Delivery:**
- Calculated as 5 business days from order creation
- Returns `null` if order is delivered or cancelled
- Format: `YYYY-MM-DD`

---

## Seller Order Endpoints

All seller endpoints require authentication and an active seller profile.

### List Seller Orders

**Endpoint:** `GET /api/seller/orders`

**Authentication:** Required (Bearer token + Seller Profile)

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| status | string | No | Filter by status: pending, processing, shipped, delivered, cancelled |
| per_page | integer | No | Items per page (1-50, default: 10) |

**Response:**
```json
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "order_number": "ORD-000001",
      "status": "pending",
      "created_at": "2026-01-16T14:52:35.000000Z",
      "customer_name": "John Doe",
      "total_price": 7000.00,
      "processing_days": 5,
      "items": [
        {
          "product_id": 5,
          "product_name": "Ankara Dress",
          "product_image": "https://example.com/image.jpg",
          "quantity": 2,
          "size": "M",
          "price": 2500.00
        }
      ]
    }
  ],
  "links": {
    "first": "http://api.ojaewa.com/api/seller/orders?page=1",
    "last": "http://api.ojaewa.com/api/seller/orders?page=3",
    "prev": null,
    "next": "http://api.ojaewa.com/api/seller/orders?page=2"
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 3,
    "path": "http://api.ojaewa.com/api/seller/orders",
    "per_page": 10,
    "to": 10,
    "total": 25
  }
}
```

**Note:** Only shows items belonging to the authenticated seller's products.

### Get Seller Order Details

**Endpoint:** `GET /api/seller/orders/{order_id}`

**Authentication:** Required (Bearer token + Seller Profile)

**Response:**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "order_number": "ORD-000001",
    "status": "pending",
    "created_at": "2026-01-16T14:52:35.000000Z",
    "processing_days": 5,
    "customer": {
      "name": "John Doe",
      "phone": "+234 801 234 5678",
      "address": "123 Main St",
      "city": "Lagos",
      "state": "Lagos State",
      "country": "Nigeria"
    },
    "items": [
      {
        "product_id": 5,
        "product_name": "Ankara Dress",
        "product_image": "https://example.com/image.jpg",
        "quantity": 2,
        "size": "M",
        "price": 2500.00,
        "processing_days": 5
      }
    ],
    "total_price": 7000.00,
    "tracking_number": null,
    "shipped_at": null,
    "delivered_at": null,
    "payment_status": "pending"
  }
}
```

### Update Order Status

**Endpoint:** `PATCH /api/seller/orders/{order_id}/status`

**Authentication:** Required (Bearer token + Seller Profile)

**Request Body:**
```json
{
  "status": "shipped",
  "tracking_number": "TRK123456789",
  "reason": "Optional reason for cancellation"
}
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| status | string | Yes | New status: processing, shipped, delivered, cancelled |
| tracking_number | string | No | Tracking number (recommended when shipping) |
| reason | string | No | Reason for status change (required for cancellation) |

**Response:**
```json
{
  "status": "success",
  "message": "Order status updated",
  "data": {
    "id": 1,
    "status": "shipped",
    "tracking_number": "TRK123456789",
    "updated_at": "2026-01-16T16:00:00.000000Z"
  }
}
```

**Status Transition Flow:**
```
pending → processing → shipped → delivered
    ↓         ↓           ↓
    └─────────┴───────────┴──→ cancelled
```

**Side Effects:**
- Changing status triggers a notification to the buyer (email + push)
- Setting status to `delivered` automatically sets `delivered_at` timestamp

---

## Error Responses

### 404 - Seller Profile Not Found
```json
{
  "status": "error",
  "message": "Seller profile not found"
}
```

### 404 - Order Not Found for Seller
```json
{
  "status": "error",
  "message": "Order not found for this seller"
}
```

### 422 - Validation Error
```json
{
  "message": "The status field is required.",
  "errors": {
    "status": ["The status field is required."]
  }
}
```

---

## Create Order (Buyer)

**Endpoint:** `POST /api/orders`

**Authentication:** Required (Bearer token)

**Request Body:**
```json
{
  "items": [
    {
      "product_id": 5,
      "quantity": 2
    },
    {
      "product_id": 12,
      "quantity": 1
    }
  ],
  "shipping_name": "John Doe",
  "shipping_phone": "+234 801 234 5678",
  "shipping_address": "123 Main St",
  "shipping_city": "Lagos",
  "shipping_state": "Lagos State",
  "shipping_country": "Nigeria"
}
```

**Response:**
```json
{
  "message": "Order created successfully",
  "order": {
    "id": 1,
    "user_id": 1,
    "subtotal": 5000.00,
    "delivery_fee": 2000.00,
    "total_price": 7000.00,
    "status": "pending",
    "shipping_name": "John Doe",
    "shipping_phone": "+234 801 234 5678",
    "shipping_address": "123 Main St",
    "shipping_city": "Lagos",
    "shipping_state": "Lagos State",
    "shipping_country": "Nigeria",
    "created_at": "2026-01-16T14:52:35.000000Z",
    "order_items": [...]
  }
}
```

---

## Notification Events

When order status is updated, the following notification is sent to the buyer:

**Email Template:** `order_status_updated`

**Push Notification:**
```json
{
  "title": "Order Status Updated",
  "body": "Your order #1 status has been updated to shipped.",
  "data": {
    "order_id": 1,
    "status": "shipped",
    "deep_link": "/orders/1"
  }
}
```
