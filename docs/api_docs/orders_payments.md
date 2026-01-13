# Orders & Payments API Documentation

## Overview
Endpoints for managing orders, payments, and order tracking.

---

## Order Management

### 1. Get User Orders
**Endpoint:** `GET /api/orders`  
**Controller:** `OrderController@index`  
**Middleware:** `auth:sanctum`  
**Description:** Get all orders for authenticated user

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
      "user_id": 1,
      "total_price": 45000.00,
      "status": "paid",
      "payment_reference": "ORDER_20240117_ABC123",
      "tracking_number": "TRK123456789",
      "cancellation_reason": null,
      "delivered_at": null,
      "created_at": "2024-01-17T10:00:00.000000Z",
      "updated_at": "2024-01-17T10:30:00.000000Z",
      "order_items": [
        {
          "id": 1,
          "order_id": 1,
          "product_id": 3,
          "quantity": 2,
          "unit_price": 18000.00,
          "created_at": "2024-01-17T10:00:00.000000Z",
          "product": {
            "id": 3,
            "name": "Ankara Print Dress",
            "image": "https://example.com/images/product3.jpg",
            "seller_profile_id": 2
          }
        }
      ]
    }
  ],
  "links": {
    "first": "http://api.example.com/api/orders?page=1",
    "last": "http://api.example.com/api/orders?page=2",
    "prev": null,
    "next": "http://api.example.com/api/orders?page=2"
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 2,
    "path": "http://api.example.com/api/orders",
    "per_page": 10,
    "to": 10,
    "total": 15
  }
}
```

#### Business Logic Notes
- Returns orders for authenticated user only
- Includes order items and associated products
- Paginated with 10 orders per page
- Ordered by creation date (newest first)

---

### 2. Create Order
**Endpoint:** `POST /api/orders`  
**Controller:** `OrderController@store`  
**Middleware:** `auth:sanctum`  
**Description:** Create a new order with multiple items

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "items": [
    {
      "product_id": "integer (required, exists in approved products)",
      "quantity": "integer (required, min:1)"
    },
    {
      "product_id": 5,
      "quantity": 1
    }
  ]
}
```

#### Validation Rules (from StoreOrderRequest)
- `items`: required|array|min:1
- `items.*.product_id`: required|exists:products,id,status,approved
- `items.*.quantity`: required|integer|min:1

#### Custom Validation Messages
- "You must include at least one item in your order"
- "Each item must specify a product ID"
- "One or more selected products do not exist or are not approved"
- "Each item must specify a quantity"
- "Quantity must be at least 1 for each item"

#### Success Response (201)
```json
{
  "message": "Order created successfully",
  "order": {
    "id": 5,
    "user_id": 1,
    "total_price": 53000.00,
    "status": "pending",
    "payment_reference": null,
    "tracking_number": null,
    "created_at": "2024-01-17T11:00:00.000000Z",
    "updated_at": "2024-01-17T11:00:00.000000Z",
    "order_items": [
      {
        "id": 10,
        "order_id": 5,
        "product_id": 3,
        "quantity": 2,
        "unit_price": 18000.00,
        "product": {
          "id": 3,
          "name": "Ankara Print Dress",
          "price": 18000.00,
          "image": "https://example.com/images/product3.jpg"
        }
      },
      {
        "id": 11,
        "order_id": 5,
        "product_id": 5,
        "quantity": 1,
        "unit_price": 17000.00,
        "product": {
          "id": 5,
          "name": "Aso Oke Gele",
          "price": 17000.00,
          "image": "https://example.com/images/product5.jpg"
        }
      }
    ]
  }
}
```

#### Error Response (500)
```json
{
  "message": "Failed to create order",
  "error": "Error details..."
}
```

#### Business Logic Notes
- Transaction-based: All items created together or none
- Total price calculated from product prices and quantities
- Order status defaults to 'pending'
- Each order item stores unit_price at time of order (price snapshot)
- Sends email and push notification to user upon creation
- Products must have 'approved' status to be ordered
- Automatically associates order with authenticated user

#### Notifications Sent
- **Email**: Order confirmation with order details
- **Push**: "Order Confirmed! Your order #{order_id} has been confirmed and is being processed."
- **Deep Link**: `/orders/{order_id}`

---

### 3. Get Order Details
**Endpoint:** `GET /api/orders/{order}`  
**Controller:** `OrderController@show`  
**Middleware:** `auth:sanctum`  
**Description:** Get detailed information about a specific order

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `order`: Order ID (integer)

#### Success Response (200)
```json
{
  "id": 1,
  "user_id": 1,
  "total_price": 45000.00,
  "status": "shipped",
  "payment_reference": "ORDER_20240117_ABC123",
  "tracking_number": "TRK123456789",
  "payment_data": "{...}",
  "cancellation_reason": null,
  "delivered_at": null,
  "created_at": "2024-01-17T10:00:00.000000Z",
  "updated_at": "2024-01-17T14:00:00.000000Z",
  "avg_rating": 4.5,
  "order_items": [
    {
      "id": 1,
      "order_id": 1,
      "product_id": 3,
      "quantity": 2,
      "unit_price": 18000.00,
      "product": {
        "id": 3,
        "name": "Ankara Print Dress",
        "description": "Vibrant Ankara print dress for special occasions",
        "image": "https://example.com/images/product3.jpg",
        "seller_profile": {
          "id": 2,
          "business_name": "Ankara Styles",
          "business_phone_number": "+2348098765432"
        }
      }
    }
  ],
  "reviews": [
    {
      "id": 5,
      "rating": 5,
      "headline": "Fast delivery!",
      "body": "Order arrived quickly and everything was perfect.",
      "created_at": "2024-01-18T09:00:00.000000Z"
    }
  ]
}
```

#### Business Logic Notes
- User can only view their own orders
- Includes all order items with product details
- Includes seller information for each product
- Shows any reviews associated with the order
- `avg_rating` calculated from order reviews

---

### 4. Get Order Tracking
**Endpoint:** `GET /api/orders/{order}/tracking`  
**Controller:** `OrderController@tracking`  
**Middleware:** `auth:sanctum`  
**Description:** Get order tracking status and timeline

#### Headers
```
Authorization: Bearer {token}
```

#### URL Parameters
- `order`: Order ID (integer)

#### Success Response (200)
```json
{
  "status": "success",
  "data": {
    "order_id": 1,
    "current_status": "shipped",
    "tracking_number": "TRK123456789",
    "stages": [
      {
        "title": "Order Placed",
        "description": "Your order has been placed and is awaiting processing",
        "completed": true,
        "date": "Jan 17, 2024 10:00"
      },
      {
        "title": "Processing",
        "description": "Your order is being prepared",
        "completed": true,
        "date": null
      },
      {
        "title": "Shipped",
        "description": "Tracking: TRK123456789",
        "completed": true,
        "date": "Current stage"
      },
      {
        "title": "Delivered",
        "description": "Your order has been delivered",
        "completed": false,
        "date": null
      }
    ],
    "estimated_delivery": "Jan 22, 2024"
  }
}
```

#### Cancelled Order Response (200)
```json
{
  "status": "success",
  "data": {
    "order_id": 2,
    "current_status": "cancelled",
    "tracking_number": null,
    "stages": [
      {
        "title": "Order Placed",
        "description": "Your order has been placed and is awaiting processing",
        "completed": true,
        "date": "Jan 17, 2024 10:00"
      },
      {
        "title": "Cancelled",
        "description": "Customer requested cancellation",
        "completed": true,
        "date": "Jan 17, 2024 11:30"
      }
    ],
    "estimated_delivery": null
  }
}
```

#### Business Logic Notes
- User can only track their own orders
- Tracking stages depend on current order status
- Estimated delivery is 5 days from order creation
- Cancelled orders show special tracking stage
- Tracking number displayed when available

#### Order Status Flow
1. **pending** → Order placed
2. **processing** → Being prepared
3. **shipped** → In transit
4. **delivered** → Completed
5. **cancelled** → Terminated

---

## Payment Operations

### 5. Create Payment Link for Order
**Endpoint:** `POST /api/payment/link`  
**Controller:** `PaymentController@createOrderPaymentLink`  
**Middleware:** `auth:sanctum`  
**Description:** Generate Paystack payment link for an order

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "order_id": "integer (required, exists in user's orders)"
}
```

#### Validation Rules
- `order_id`: required|integer|exists:orders,id

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Payment link generated successfully",
  "data": {
    "payment_url": "https://checkout.paystack.com/abc123xyz",
    "access_code": "abc123xyz",
    "reference": "ORDER_20240117_XYZ789",
    "amount": 45000.00,
    "currency": "NGN"
  }
}
```

#### Error Response (400)
```json
{
  "status": "error",
  "message": "Order is already paid"
}
```

#### Business Logic Notes
- Order must belong to authenticated user
- Cannot generate payment link for already paid orders
- Amount converted to kobo (multiply by 100) for Paystack
- Payment reference stored in order for tracking
- Callback URL set to frontend payment callback page
- Metadata includes order_id, user_id, and payment_type

#### Paystack Metadata
```json
{
  "order_id": 1,
  "user_id": 1,
  "payment_type": "order",
  "custom_fields": [
    {
      "display_name": "Order ID",
      "variable_name": "order_id",
      "value": 1
    }
  ]
}
```

---

### 6. Verify Payment
**Endpoint:** `POST /api/payment/verify`  
**Controller:** `PaymentController@verifyPayment`  
**Middleware:** `auth:sanctum`  
**Description:** Verify payment status using Paystack reference

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "reference": "string (required)"
}
```

#### Validation Rules
- `reference`: required|string

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Payment verified successfully",
  "data": {
    "order_id": 1,
    "payment_status": "success",
    "amount": 45000.00,
    "currency": "NGN",
    "paid_at": "2024-01-17T10:30:00Z"
  }
}
```

#### Error Response (404)
```json
{
  "status": "error",
  "message": "Order not found for this payment reference"
}
```

#### Error Response (400)
```json
{
  "status": "error",
  "message": "Payment verification failed"
}
```

#### Business Logic Notes
- Verifies payment with Paystack API
- Finds order by payment reference
- Updates order status to 'paid' if payment successful
- Stores complete payment data from Paystack
- Amount converted from kobo back to naira

---

### 7. Paystack Webhook (Order Payments)
**Endpoint:** `POST /api/webhook/paystack`  
**Controller:** `PaymentController@handleOrderWebhook`  
**Middleware:** None (Public, signature verified)  
**Description:** Handle Paystack payment webhooks

#### Headers
```
x-paystack-signature: {signature_hash}
```

#### Request Body (Paystack Format)
```json
{
  "event": "charge.success",
  "data": {
    "reference": "ORDER_20240117_XYZ789",
    "amount": 4500000,
    "currency": "NGN",
    "status": "success",
    "paid_at": "2024-01-17T10:30:00Z",
    "metadata": {
      "order_id": 1,
      "user_id": 1,
      "payment_type": "order"
    },
    "gateway_response": "Successful"
  }
}
```

#### Success Response (200)
```json
{
  "message": "Webhook received"
}
```

#### Error Response (400)
```json
{
  "message": "Invalid signature"
}
```

#### Supported Events
- `charge.success`: Payment successful
- `charge.failed`: Payment failed

#### Business Logic Notes
- Webhook signature verified using Paystack secret
- Automatically updates order status to 'paid'
- Stores complete payment data
- Handles both order and school registration payments
- Logs all webhook events
- Invalid signatures rejected immediately

#### Security
- HMAC SHA512 signature verification
- Compares signature with computed hash
- Prevents unauthorized webhook calls

---

## School Registration & Payment

### 8. Register for School
**Endpoint:** `POST /api/school-registrations`  
**Controller:** `SchoolController@register`  
**Middleware:** None (Public)  
**Description:** Submit school registration application

#### Request Body
```json
{
  "country": "string (required, max:100)",
  "full_name": "string (required, max:255)",
  "phone_number": "string (required, max:20)",
  "state": "string (required, max:100)",
  "city": "string (required, max:100)",
  "address": "string (required, max:500)"
}
```

#### Validation Rules
- `country`: required|string|max:100
- `full_name`: required|string|max:255
- `phone_number`: required|string|max:20
- `state`: required|string|max:100
- `city`: required|string|max:100
- `address`: required|string|max:500

#### Success Response (201)
```json
{
  "status": "success",
  "message": "School registration submitted successfully",
  "data": {
    "id": 1,
    "country": "Nigeria",
    "full_name": "Jane Doe",
    "phone_number": "+2348012345678",
    "state": "Lagos",
    "city": "Ikeja",
    "address": "123 School Street",
    "status": "pending",
    "payment_reference": null,
    "submitted_at": "2024-01-17T12:00:00.000000Z",
    "created_at": "2024-01-17T12:00:00.000000Z",
    "updated_at": "2024-01-17T12:00:00.000000Z"
  }
}
```

#### Business Logic Notes
- Public endpoint (no authentication required)
- Default status is 'pending'
- Payment not required at registration time
- Separate payment link generated in next step

---

### 9. Create School Payment Link
**Endpoint:** `POST /api/payment/link/school`  
**Controller:** `SchoolController@createPaymentLink`  
**Middleware:** `auth:sanctum`  
**Description:** Generate payment link for school registration fee

#### Headers
```
Authorization: Bearer {token}
```

#### Request Body
```json
{
  "registration_id": "integer (required, exists:school_registrations,id)",
  "email": "string (required, email)"
}
```

#### Validation Rules
- `registration_id`: required|integer|exists:school_registrations,id
- `email`: required|email

#### Success Response (200)
```json
{
  "status": "success",
  "message": "Payment link generated successfully",
  "data": {
    "payment_url": "https://checkout.paystack.com/xyz456abc",
    "access_code": "xyz456abc",
    "reference": "SCHOOL_20240117_ABC456",
    "amount": 50000,
    "currency": "NGN"
  }
}
```

#### Error Response (400)
```json
{
  "status": "error",
  "message": "Registration fee already paid"
}
```

#### Business Logic Notes
- Fixed registration fee: ₦500.00 (50,000 kobo)
- Cannot generate link if already paid
- Payment reference stored in registration record
- Callback URL points to school payment callback page

---

### 10. School Payment Webhook
**Endpoint:** `POST /api/webhook/paystack/school`  
**Controller:** `SchoolController@handlePaymentWebhook`  
**Middleware:** None (Public, signature verified)  
**Description:** Handle school registration payment webhooks

#### Headers
```
x-paystack-signature: {signature_hash}
```

#### Request Body (Paystack Format)
```json
{
  "event": "charge.success",
  "data": {
    "reference": "SCHOOL_20240117_ABC456",
    "amount": 50000,
    "status": "success",
    "metadata": {
      "registration_id": 1,
      "payment_type": "school_registration"
    }
  }
}
```

#### Success Response (200)
```json
{
  "message": "Webhook received"
}
```

#### Business Logic Notes
- Verifies webhook signature
- Updates registration status to 'processing'
- Stores payment data
- Only handles 'charge.success' event

---

## Order Status Values

### Status Types
- `pending`: Order created, awaiting payment
- `paid`: Payment confirmed
- `processing`: Order being prepared
- `shipped`: Order in transit
- `delivered`: Order completed
- `cancelled`: Order cancelled

### Status Transitions
```
pending → paid → processing → shipped → delivered
   ↓
cancelled (from pending or paid)
```

---

## Payment Integration Notes

### Paystack Configuration
- Currency: NGN (Nigerian Naira)
- Amount Format: Kobo (1 NGN = 100 kobo)
- Environment: Set in .env file

### Reference Format
- Order: `ORDER_YYYYMMDD_RANDOM`
- School: `SCHOOL_YYYYMMDD_RANDOM`

### Webhook Security
- Signature verification required
- Uses HMAC SHA512
- Secret key from environment

### Error Handling
- Failed payments logged but not auto-retried
- Users must initiate new payment attempt
- Payment data preserved for reconciliation

---

## Business Rules

1. **Order Creation**: Must have at least 1 approved product
2. **Payment**: Order must be paid before processing
3. **Tracking**: Available immediately after order creation
4. **Delivery Time**: Estimated 5 business days
5. **Cancellation**: Possible before shipping
6. **Price Lock**: Unit prices saved at order creation
7. **Notifications**: Sent on order creation and status changes
