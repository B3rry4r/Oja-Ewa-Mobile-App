# Logistics Checkout and Multi-Seller Fulfillment API

This document describes the frontend-facing backend contract for:

- shipping quote discovery
- multi-seller checkout
- order creation with selected shipping options
- payment finalization across multiple gateways
- shipment-based seller fulfillment
- buyer tracking

This is the contract the frontend should use going forward.

---

## Summary

The backend no longer treats shipping as one flat fee for the whole order.

Instead:

- cart items are grouped by seller
- each seller group gets its own shipping quotes
- the buyer selects one shipping option per seller group
- one order is created
- one shipment is created per seller group
- payment is still one payment for the whole order
- after payment, each shipment is booked with its selected logistics provider

This supports:

- multiple sellers in one checkout
- different shipping prices per seller
- different logistics providers per seller
- different tracking numbers inside one order
- Paystack, MoMo, and future gateways using one shared paid-order flow

---

## Core Concepts

### Order

Represents the buyer's overall checkout.

### Shipment

Represents one seller-specific fulfillment leg inside an order.

One order can have many shipments.

### Shipping Quote

A temporary quote returned for a specific:

- user
- seller group
- address
- provider
- package snapshot

The frontend must select one valid quote for each seller group before creating the order.

---

## Status Model

### Order Status

Order status is now derived from payment status and shipment statuses.

Possible values:

- `pending`
- `paid`
- `processing`
- `shipped`
- `delivered`
- `cancelled`

### Payment Status

Possible values:

- `pending`
- `paid`
- `failed`

### Shipment Status

Possible values currently supported by the backend:

- `pending_booking`
- `booking_failed`
- `booked`
- `processing`
- `shipped`
- `in_transit`
- `delivered`
- `cancelled`

---

## Endpoints

### 1. Get Shipping Quotes

`POST /api/logistics/quotes`

Authentication required.

Use this before order creation.

The backend:

- groups items by seller
- requests quotes from configured providers
- stores quote snapshots
- returns quotes grouped by seller

#### Request body

```json
{
  "items": [
    {
      "product_id": 101,
      "quantity": 2
    },
    {
      "product_id": 205,
      "quantity": 1
    }
  ],
  "address_id": 12,
  "providers": ["gig", "dhl"]
}
```

You can also send raw shipping fields instead of `address_id`:

```json
{
  "items": [
    {
      "product_id": 101,
      "quantity": 2
    }
  ],
  "shipping_name": "John Doe",
  "shipping_phone": "08030000000",
  "shipping_address": "12 Admiralty Way",
  "shipping_city": "Lekki",
  "shipping_state": "Lagos",
  "shipping_country": "Nigeria",
  "shipping_zip_code": "100001",
  "providers": ["gig", "dhl"]
}
```

#### Request fields

| Field | Type | Required | Notes |
|---|---|---:|---|
| `items` | array | yes | Checkout items |
| `items[].product_id` | integer | yes | Approved product id |
| `items[].quantity` | integer | yes | Min 1 |
| `address_id` | integer | no | Saved user address id |
| `shipping_name` | string | no | Required if `address_id` not used |
| `shipping_phone` | string | no | Required if `address_id` not used |
| `shipping_address` | string | no | Required if `address_id` not used |
| `shipping_city` | string | no | Required if `address_id` not used |
| `shipping_state` | string | no | Required if `address_id` not used |
| `shipping_country` | string | no | Required if `address_id` not used |
| `shipping_zip_code` | string | no | Optional |
| `providers` | array | no | If omitted, backend uses enabled/default providers |

#### Response

```json
{
  "status": "success",
  "data": [
    {
      "seller_profile_id": 5,
      "quotes": [
        {
          "quote_reference": "QUOTE-SELLER-ONE",
          "provider": "gig",
          "service_code": "standard",
          "service_name": "GIG Standard",
          "amount": "2500.00",
          "currency": "NGN",
          "estimated_days": 2,
          "expires_at": "2026-03-10T11:30:00.000000Z"
        },
        {
          "quote_reference": "DHL-EXP-839201",
          "provider": "dhl",
          "service_code": "express",
          "service_name": "DHL Express",
          "amount": "4500.00",
          "currency": "NGN",
          "estimated_days": 3,
          "expires_at": "2026-03-10T11:30:00.000000Z"
        }
      ]
    },
    {
      "seller_profile_id": 9,
      "quotes": [
        {
          "quote_reference": "QUOTE-SELLER-TWO",
          "provider": "gig",
          "service_code": "economy",
          "service_name": "GIG Economy",
          "amount": "1800.00",
          "currency": "NGN",
          "estimated_days": 1,
          "expires_at": "2026-03-10T11:30:00.000000Z"
        }
      ]
    }
  ]
}
```

#### Frontend rule

The frontend must collect one chosen quote per `seller_profile_id`.

---

### 2. Create Order

`POST /api/orders`

Authentication required.

The frontend must call this only after shipping quotes have been selected.

#### Request body

```json
{
  "items": [
    {
      "product_id": 101,
      "quantity": 2
    },
    {
      "product_id": 205,
      "quantity": 1
    }
  ],
  "address_id": 12,
  "selected_quotes": [
    {
      "seller_profile_id": 5,
      "quote_reference": "QUOTE-SELLER-ONE"
    },
    {
      "seller_profile_id": 9,
      "quote_reference": "QUOTE-SELLER-TWO"
    }
  ]
}
```

Or with inline address:

```json
{
  "items": [
    {
      "product_id": 101,
      "quantity": 2
    },
    {
      "product_id": 205,
      "quantity": 1
    }
  ],
  "shipping_name": "John Doe",
  "shipping_phone": "08030000000",
  "shipping_address": "12 Admiralty Way",
  "shipping_city": "Lekki",
  "shipping_state": "Lagos",
  "shipping_country": "Nigeria",
  "shipping_zip_code": "100001",
  "selected_quotes": [
    {
      "seller_profile_id": 5,
      "quote_reference": "QUOTE-SELLER-ONE"
    },
    {
      "seller_profile_id": 9,
      "quote_reference": "QUOTE-SELLER-TWO"
    }
  ]
}
```

#### Request fields

| Field | Type | Required | Notes |
|---|---|---:|---|
| `items` | array | yes | Checkout items |
| `items[].product_id` | integer | yes | Approved product id |
| `items[].quantity` | integer | yes | Min 1 |
| `address_id` | integer | no | Saved user address id |
| `shipping_name` | string | no | Used when `address_id` is omitted |
| `shipping_phone` | string | no | Used when `address_id` is omitted |
| `shipping_address` | string | no | Used when `address_id` is omitted |
| `shipping_city` | string | no | Used when `address_id` is omitted |
| `shipping_state` | string | no | Used when `address_id` is omitted |
| `shipping_country` | string | no | Used when `address_id` is omitted |
| `shipping_zip_code` | string | no | Optional |
| `selected_quotes` | array | yes | One quote per seller group |
| `selected_quotes[].seller_profile_id` | integer | yes | Seller group id |
| `selected_quotes[].quote_reference` | string | yes | Quote returned by `/api/logistics/quotes` |

#### Response

```json
{
  "message": "Order created successfully",
  "order": {
    "id": 44,
    "user_id": 7,
    "total_price": "39000.00",
    "subtotal": "32000.00",
    "delivery_fee": "7000.00",
    "shipping_name": "John Doe",
    "shipping_phone": "08030000000",
    "shipping_address": "12 Admiralty Way",
    "shipping_city": "Lekki",
    "shipping_state": "Lagos",
    "shipping_country": "Nigeria",
    "status": "pending",
    "payment_status": "pending",
    "payment_gateway": null,
    "payment_method": null,
    "payment_reference": null,
    "paid_at": null,
    "created_at": "2026-03-10T11:00:00.000000Z",
    "updated_at": "2026-03-10T11:00:00.000000Z",
    "order_number": "ORD-000044",
    "avg_rating": 0,
    "order_items": [
      {
        "id": 501,
        "order_id": 44,
        "shipment_id": 301,
        "product_id": 101,
        "quantity": 2,
        "unit_price": "12500.00"
      },
      {
        "id": 502,
        "order_id": 44,
        "shipment_id": 302,
        "product_id": 205,
        "quantity": 1,
        "unit_price": "7000.00"
      }
    ],
    "shipments": [
      {
        "id": 301,
        "order_id": 44,
        "seller_profile_id": 5,
        "provider": "gig",
        "service_code": "standard",
        "service_name": "GIG Standard",
        "status": "pending_booking",
        "tracking_number": null,
        "provider_shipment_id": null,
        "label_url": null,
        "shipping_fee": "2500.00",
        "currency": "NGN",
        "booked_at": null,
        "shipped_at": null,
        "delivered_at": null,
        "cancelled_at": null,
        "created_at": "2026-03-10T11:00:00.000000Z",
        "updated_at": "2026-03-10T11:00:00.000000Z"
      },
      {
        "id": 302,
        "order_id": 44,
        "seller_profile_id": 9,
        "provider": "dhl",
        "service_code": "express",
        "service_name": "DHL Express",
        "status": "pending_booking",
        "tracking_number": null,
        "provider_shipment_id": null,
        "label_url": null,
        "shipping_fee": "4500.00",
        "currency": "NGN",
        "booked_at": null,
        "shipped_at": null,
        "delivered_at": null,
        "cancelled_at": null,
        "created_at": "2026-03-10T11:00:00.000000Z",
        "updated_at": "2026-03-10T11:00:00.000000Z"
      }
    ]
  }
}
```

#### Validation notes

- if any seller group is missing a selected quote, order creation fails
- if a quote is expired or invalid, order creation fails
- all selected quotes must belong to the authenticated user

---

### 3. Create Paystack Payment Link

`POST /api/payment/link`

Authentication required.

#### Request

```json
{
  "order_id": 44
}
```

#### Response

```json
{
  "status": "success",
  "message": "Payment link generated successfully",
  "data": {
    "payment_url": "https://checkout.paystack.com/abc123",
    "access_code": "abc123",
    "reference": "ORDER-8F3A2B1C",
    "amount": 39000,
    "currency": "NGN"
  }
}
```

#### Backend behavior

- sets `payment_gateway = paystack`
- sets `payment_method = paystack`
- sets `payment_status = pending`
- stores `payment_reference`

---

### 4. Verify Paystack Payment

`POST /api/payment/verify`

Authentication required.

#### Request

```json
{
  "reference": "ORDER-8F3A2B1C"
}
```

#### Response

```json
{
  "status": "success",
  "message": "Payment verified successfully",
  "data": {
    "order_id": 44,
    "payment_status": "paid",
    "amount": 39000,
    "currency": "NGN",
    "paid_at": "2026-03-10T11:07:00+00:00"
  }
}
```

#### Backend behavior after successful verification

- marks order payment as paid
- clears buyer cart
- attempts shipment booking for each shipment
- updates order status from shipment states

---

### 5. Initialize MoMo Payment

`POST /api/momo/initialize`

Authentication required.

#### Request

```json
{
  "order_id": 44,
  "phone": "08030000000"
}
```

#### Response

```json
{
  "status": "success",
  "message": "Payment request sent. Please approve on your phone.",
  "data": {
    "reference_id": "550e8400-e29b-41d4-a716-446655440000",
    "order_id": 44,
    "amount": "39000.00",
    "currency": "NGN",
    "phone": "08030000000",
    "payment_status": "pending"
  }
}
```

#### Backend behavior

- sets `payment_gateway = momo`
- sets `payment_method = mtn_momo`
- stores `payment_reference`
- keeps `payment_status = pending`

---

### 6. Check MoMo Payment Status

`POST /api/momo/check-status`

Authentication required.

#### Request

```json
{
  "reference_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

#### Response

```json
{
  "status": "success",
  "data": {
    "transaction_status": "SUCCESSFUL",
    "reference_id": "550e8400-e29b-41d4-a716-446655440000",
    "order": {
      "id": 44,
      "status": "processing",
      "payment_status": "paid"
    },
    "details": {
      "status": "success",
      "transaction_status": "SUCCESSFUL",
      "amount": "39000.00",
      "currency": "NGN",
      "financial_transaction_id": "1234567890",
      "external_id": "ORDER-44-1741600000"
    }
  }
}
```

#### Backend behavior after successful status

- uses the same shared payment finalization flow as Paystack
- clears cart
- attempts shipment booking
- updates aggregate order status

---

### 7. List Buyer Orders

`GET /api/orders`

Authentication required.

#### Response

```json
{
  "status": "success",
  "data": [
    {
      "id": 44,
      "order_number": "ORD-000044",
      "status": "processing",
      "payment_status": "paid",
      "subtotal": "32000.00",
      "delivery_fee": "7000.00",
      "total_price": "39000.00",
      "shipments": [
        {
          "id": 301,
          "seller_profile_id": 5,
          "provider": "gig",
          "status": "booked",
          "tracking_number": "GIG123456789"
        },
        {
          "id": 302,
          "seller_profile_id": 9,
          "provider": "dhl",
          "status": "pending_booking",
          "tracking_number": null
        }
      ]
    }
  ],
  "links": {
    "first": "https://api.example.com/api/orders?page=1",
    "last": "https://api.example.com/api/orders?page=1",
    "prev": null,
    "next": null
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 1,
    "path": "https://api.example.com/api/orders",
    "per_page": 10,
    "to": 1,
    "total": 1
  }
}
```

---

### 8. Get Buyer Order Details

`GET /api/orders/{order_id}`

Authentication required.

#### Response

```json
{
  "status": "success",
  "data": {
    "id": 44,
    "order_number": "ORD-000044",
    "status": "processing",
    "payment_status": "paid",
    "payment_gateway": "paystack",
    "created_at": "2026-03-10T11:00:00.000000Z",
    "paid_at": "2026-03-10T11:07:00.000000Z",
    "subtotal": "32000.00",
    "delivery_fee": "7000.00",
    "total_price": "39000.00",
    "delivered_at": null,
    "shipping_address": "12 Admiralty Way, Lekki, Lagos, Nigeria",
    "order_items": [
      {
        "id": 501,
        "order_id": 44,
        "shipment_id": 301,
        "product_id": 101,
        "quantity": 2,
        "unit_price": "12500.00"
      }
    ],
    "shipments": [
      {
        "id": 301,
        "seller_id": 5,
        "seller_name": "Seller One",
        "provider": "gig",
        "service_code": "standard",
        "service_name": "GIG Standard",
        "status": "booked",
        "tracking_number": "GIG123456789",
        "shipping_fee": "2500.00",
        "currency": "NGN",
        "booked_at": "2026-03-10T11:07:05.000000Z",
        "shipped_at": null,
        "delivered_at": null,
        "label_url": "https://provider.example.com/label.pdf",
        "items": [
          {
            "id": 501,
            "product_id": 101,
            "quantity": 2,
            "unit_price": "12500.00"
          }
        ]
      }
    ],
    "avg_rating": 0
  }
}
```

---

### 9. Get Buyer Tracking

`GET /api/orders/{order_id}/tracking`

Authentication required.

#### Response

```json
{
  "status": "success",
  "data": {
    "estimated_delivery": "2026-03-14",
    "shipments": [
      {
        "shipment_id": 301,
        "seller_id": 5,
        "seller_name": "Seller One",
        "provider": "gig",
        "service_name": "GIG Standard",
        "tracking_number": "GIG123456789",
        "status": "in_transit",
        "events": [
          {
            "status": "booked",
            "title": "Shipment booked",
            "description": "Shipment created with logistics provider.",
            "timestamp": "2026-03-10T11:07:05.000000Z"
          },
          {
            "status": "in_transit",
            "title": "Package in transit",
            "description": "Shipment departed origin hub.",
            "timestamp": "2026-03-11T08:00:00.000000Z"
          }
        ]
      },
      {
        "shipment_id": 302,
        "seller_id": 9,
        "seller_name": "Seller Two",
        "provider": "dhl",
        "service_name": "DHL Express",
        "tracking_number": "DHL99887766",
        "status": "booked",
        "events": []
      }
    ],
    "stages": [
      {
        "status": "Order Placed",
        "timestamp": "2026-03-10T11:00:00.000000Z",
        "completed": true
      },
      {
        "status": "Payment Confirmed",
        "timestamp": "2026-03-10T11:07:00.000000Z",
        "completed": true
      },
      {
        "status": "Processing",
        "timestamp": "2026-03-10T11:07:05.000000Z",
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

#### Important frontend note

Do not display only one tracking number for the whole order.

Display:

- order-level summary
- then shipment cards grouped by seller/provider
- then each shipment's tracking and status

---

### 10. Cancel Order

`POST /api/orders/{id}/cancel`

Authentication required.

#### Request

```json
{
  "cancellation_reason": "Customer changed mind"
}
```

#### Response

```json
{
  "status": "success",
  "message": "Order cancelled successfully",
  "data": {
    "id": 44,
    "status": "cancelled"
  }
}
```

#### Backend behavior

- marks order as cancelled
- marks every shipment as cancelled

---

### 11. Seller List Shipments

`GET /api/seller/orders`

Authentication required.

This endpoint now behaves like "seller shipment list" rather than "whole order list".

#### Query params

| Param | Type | Notes |
|---|---|---|
| `status` | string | `pending_booking`, `booking_failed`, `booked`, `processing`, `shipped`, `in_transit`, `delivered`, `cancelled` |
| `per_page` | integer | Default 10 |

#### Response

```json
{
  "status": "success",
  "data": [
    {
      "shipment_id": 301,
      "order_id": 44,
      "order_number": "ORD-000044",
      "status": "booked",
      "created_at": "2026-03-10T11:00:00.000000Z",
      "customer_name": "John Doe",
      "provider": "gig",
      "service_name": "GIG Standard",
      "shipping_fee": "2500.00",
      "tracking_number": "GIG123456789",
      "items": [
        {
          "product_id": 101,
          "product_name": "Elegant Ankara Gown",
          "product_image": "https://...",
          "quantity": 2,
          "size": "L",
          "price": "12500.00"
        }
      ]
    }
  ],
  "links": {
    "first": "https://api.example.com/api/seller/orders?page=1",
    "last": "https://api.example.com/api/seller/orders?page=1",
    "prev": null,
    "next": null
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 1,
    "path": "https://api.example.com/api/seller/orders",
    "per_page": 10,
    "to": 1,
    "total": 1
  }
}
```

---

### 12. Seller Get Shipment Details For Order

`GET /api/seller/orders/{order_id}`

Authentication required.

Returns the seller's shipment inside that order.

#### Response

```json
{
  "status": "success",
  "data": {
    "id": 44,
    "shipment_id": 301,
    "order_number": "ORD-000044",
    "status": "booked",
    "order_status": "processing",
    "created_at": "2026-03-10T11:00:00.000000Z",
    "provider": "gig",
    "service_name": "GIG Standard",
    "customer": {
      "name": "John Doe",
      "phone": "08030000000",
      "address": "12 Admiralty Way",
      "city": "Lekki",
      "state": "Lagos",
      "country": "Nigeria"
    },
    "items": [
      {
        "product_id": 101,
        "product_name": "Elegant Ankara Gown",
        "product_image": "https://...",
        "quantity": 2,
        "size": "L",
        "price": "12500.00",
        "processing_days": 4
      }
    ],
    "shipping_fee": "2500.00",
    "tracking_number": "GIG123456789",
    "booked_at": "2026-03-10T11:07:05.000000Z",
    "shipped_at": null,
    "delivered_at": null,
    "payment_status": "paid",
    "events": []
  }
}
```

---

### 13. Seller Update Shipment Status

`PATCH /api/seller/orders/{order_id}/status`

Authentication required.

This updates the seller's shipment, not every seller's shipment.

#### Request

```json
{
  "status": "shipped",
  "tracking_number": "GIG123456789",
  "reason": "Dispatched from seller hub"
}
```

#### Request fields

| Field | Type | Required | Notes |
|---|---|---:|---|
| `status` | string | yes | `processing`, `shipped`, `in_transit`, `delivered`, `cancelled` |
| `tracking_number` | string | no | Recommended for shipped / in transit |
| `reason` | string | no | Optional seller note |

#### Response

```json
{
  "status": "success",
  "message": "Shipment status updated",
  "data": {
    "id": 301,
    "order_id": 44,
    "seller_profile_id": 5,
    "status": "shipped",
    "tracking_number": "GIG123456789",
    "shipped_at": "2026-03-11T08:00:00.000000Z"
  }
}
```

#### Backend behavior

- updates only that seller's shipment
- recalculates aggregate order status
- notifies buyer

---

## New Frontend Flow

### Single seller flow

1. Buyer enters checkout.
2. App calls `POST /api/logistics/quotes`.
3. App receives one seller group with one or more provider options.
4. Buyer selects one quote.
5. App calls `POST /api/orders`.
6. App initializes Paystack or MoMo payment.
7. Payment success marks order paid.
8. Backend books shipment.
9. Buyer sees shipment tracking under the order.

### Multi-seller flow

1. Buyer has products from Seller A and Seller B.
2. App calls `POST /api/logistics/quotes`.
3. Backend splits cart into:
   - Seller A shipment group
   - Seller B shipment group
4. Backend returns quotes for each seller group.
5. Buyer selects one quote for Seller A and one quote for Seller B.
6. App calls `POST /api/orders` with both selected quotes.
7. Backend creates:
   - one order
   - one shipment for Seller A
   - one shipment for Seller B
8. Shipping total becomes:
   - `Seller A shipping fee + Seller B shipping fee`
9. Payment total becomes:
   - `subtotal + all shipment fees`
10. Buyer pays once.
11. Backend books each shipment independently after payment.
12. Seller A may ship first while Seller B is still processing.
13. Buyer tracking screen must show both shipments separately.
14. Order becomes fully `delivered` only when all shipments are delivered.

### Important frontend UX guidance

- checkout should show shipping grouped by seller
- shipping selection should be mandatory per seller
- order details should render a shipment list
- tracking screen should render multiple tracking cards
- seller app should think in terms of "my shipment in this order", not "entire customer order"

---

## Payment Gateway Architecture

The backend now uses a shared paid-order flow.

That means:

- Paystack can mark order as paid
- MoMo can mark order as paid
- future gateways can mark order as paid

After that, the same backend behavior happens:

- set payment fields
- clear cart
- book shipments
- emit shipment events
- refresh order status
- notify buyer

So to add more gateways later, the main requirement is:

- create gateway-specific initialize/verify/webhook flow
- call the same shared order payment finalizer

---

## Required Environment Variables

Add these to your `.env`.

### Logistics general

## Frontend Integration Notes

- this document is for frontend consumption only
- provider setup, credentials, and vendor-specific implementation details are backend/internal concerns
- the frontend should rely only on the REST and realtime contracts documented above
- the frontend does not need to know whether a quote or shipment came from GIG or DHL internals beyond the normalized `provider`, `service_name`, `amount`, `tracking_number`, and `status` fields returned by our API

## Current Frontend Assumptions

- shipping is selected per seller group
- one order can contain many shipments
- one payment covers the full order total
- shipment booking starts after payment is confirmed
- buyer order screens must render `shipments[]`
- seller order screens should treat each shipment as the unit of fulfillment
- websocket events should be treated as refresh triggers, with REST as the source of truth
