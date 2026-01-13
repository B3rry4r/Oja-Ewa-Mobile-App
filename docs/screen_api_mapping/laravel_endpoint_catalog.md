# Laravel API Endpoint Catalog (from `docs/api_docs`)

This is a **curated** catalog focused on the mobile app (non-admin). For the authoritative reference, see `docs/api_docs/**`.

Base rules (from `docs/api_docs/README.md`):
- User endpoints: `/api/{endpoint}`
- Admin endpoints: `/api/admin/{endpoint}`
- Auth header: `Authorization: Bearer {token}`

## Authentication (`docs/api_docs/auth/authentication_endpoints.md`)
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`
- `POST /api/auth/google`

Admin auth (mobile app likely not using):
- `POST /api/admin/login`
- `POST /api/admin/create`
- `GET /api/admin/profile`
- `POST /api/admin/logout`

## User profile & addresses (`docs/api_docs/user_management/user_endpoints.md`)
Profile:
- `GET /api/user`
- `PUT /api/user/profile`
- `PUT /api/user/password`

Addresses:
- `GET /api/addresses`
- `POST /api/addresses`
- `GET /api/addresses/{id}`
- `PUT /api/addresses/{id}`
- `DELETE /api/addresses/{id}`

Notification preferences:
- `GET /api/user/notification-preferences`
- `PUT /api/user/notification-preferences`

## Products & categories (`docs/api_docs/product_management/product_endpoints.md`)
Products:
- `GET /api/products`
- `GET /api/products/{id}`
- `POST /api/products` (seller)
- `PUT /api/products/{id}` (seller)
- `DELETE /api/products/{id}` (seller)

Discovery:
- `GET /api/products/search` (documented example: `/api/products/search?q=...`)
- `GET /api/products/suggestions`

Categories:
- `GET /api/categories`

## Content & features (`docs/api_docs/content_management/content_features_endpoints.md`)
Blogs:
- `GET /api/blogs`
- `GET /api/blogs/{id}`
- `GET /api/blogs/latest`
- `GET /api/blogs/search`

Blog favorites:
- `GET /api/blogs/favorites`
- `POST /api/blogs/favorites`
- `DELETE /api/blogs/favorites`

FAQs:
- `GET /api/faqs`
- `GET /api/faqs/search`

Wishlist:
- `GET /api/wishlist`
- `POST /api/wishlist`
- `DELETE /api/wishlist`

Subscription:
- `GET /api/subscription`
- `POST /api/subscription/subscribe`
- `POST /api/subscription/cancel`

## Orders & payments (`docs/api_docs/order_management/order_payment_endpoints.md`)
Orders:
- `GET /api/orders`
- `POST /api/orders`
- `GET /api/orders/{id}`
- `PUT /api/orders/{id}/status`

Payments (Paystack):
- `POST /api/payments/initialize`
- `GET /api/payments/verify/{reference}`

Tracking:
- `GET /api/orders/{id}/tracking`

Reviews:
- `GET /api/reviews/product/{id}`
- `POST /api/reviews`

## Notifications (`docs/api_docs/notifications/notification_endpoints.md`)
- `GET /api/notifications`
- `GET /api/notifications/unread-count`
- `PUT /api/notifications/{id}/read`
- `PUT /api/notifications/read-all`
- `DELETE /api/notifications/{id}`
- `GET /api/notifications/filter`
- `GET /api/notifications/preferences`
- `PUT /api/notifications/preferences`

## Business & seller (`docs/api_docs/business_management/business_seller_endpoints.md`)
Business:
- `POST /api/business`
- `GET /api/business/{id}`
- `PUT /api/business/{id}`
- `DELETE /api/business/{id}`

Seller:
- `GET /api/seller/profile`
- `PUT /api/seller/profile`
- `DELETE /api/seller/profile`

Uploads:
- `POST /api/upload/business-document`
- `POST /api/upload/product-image`

Business categories:
- `GET /api/business/categories`

## Connect & schools (`docs/api_docs/features/connect_school_endpoints.md`)
Connect:
- `GET /api/connect`

Schools:
- `GET /api/schools`
- `GET /api/schools/{id}`
- `POST /api/schools/register`
- `POST /api/schools/payment`

