# Screen → Laravel API Mapping

This file maps **current Flutter screens** to the Laravel API endpoints they should call.

Legend:
- **Load**: called when screen opens
- **Action**: called on button click / user action

## Auth flow

### `SplashScreen` (`/splash`)
- Load: none (should eventually check auth state + token validity)

### `OnboardingScreen` (`/onboarding`)
- Load: `GET /api/blogs/latest` (optional: show featured content)

### `SignInScreen` (`/sign-in`)
- Action: `POST /api/auth/login`
- Action (optional): `POST /api/auth/google`

### `CreateAccountScreen` (`/create-account`)
- Action: `POST /api/auth/register`

### `ResetPasswordScreen` (`/reset-password`)
- Action: `POST /api/auth/forgot-password`

### `VerificationCodeScreen` (`/verification-code`)
- Depends on backend approach; API docs only show reset-password, so verification may be implicit.

### `NewPasswordScreen` (`/new-password`)
- Action: `POST /api/auth/reset-password`

### Sign out (from Account)
- Action: `POST /api/auth/logout`

---

## Home / Category browsing

### `HomeScreen` (tab)
Typically needs a "home feed" (not explicitly documented). With available endpoints:
- Load: `GET /api/categories` (for category tiles)
- Load: `GET /api/products` (featured / trending)
- Load: `GET /api/blogs/latest`

### `MarketScreen`, `BeautyScreen`, `BrandsScreen`, `MusicScreen` (category routes)
- Load: `GET /api/categories?type=...` (documented example shows `type=market`)
- Load: `GET /api/products/search?...` or `GET /api/products?category=...` depending on backend filters

### `SchoolsScreen` (`/schools`)
- Load: `GET /api/schools`

### `SchoolDetailScreen` (navigated via `MaterialPageRoute`)
- Load: `GET /api/schools/{id}`

### `SchoolRegistrationForm` (navigated via `MaterialPageRoute`)
- Action: `POST /api/schools/register`
- Action: `POST /api/schools/payment`

### `SustainabilityScreen` (`/sustainability`)
- Load: likely `GET /api/products/search?...` with sustainability tags once backend supports

---

## Product discovery & detail

### `SearchScreen` (tab)
- Load: `GET /api/products/suggestions` (optional)
- Action: `GET /api/products/search?q=...` (+ filters)

### `ProductListingScreen` (not in router)
- Load: `GET /api/products/search` (if listing is search-based)
- Load: `GET /api/products` (if listing is category-based)

### `ProductDetailScreen` (not in router)
- Load: `GET /api/products/{id}`
- Load: `GET /api/reviews/product/{id}`
- Action: `POST /api/wishlist` or `DELETE /api/wishlist`
- Action: add-to-bag is local for now (no cart endpoints documented)

### `WishlistScreen` (tab)
- Load: `GET /api/wishlist`
- Action: `DELETE /api/wishlist`

---

## Shopping bag / checkout / orders

### `ShoppingBagScreen` (`/shopping-bag`)
No cart endpoints are documented; recommended flow using Orders API:
- Action: `POST /api/orders` (create order from bag items)
- Action: `POST /api/payments/initialize` (Paystack init)
- Action: `GET /api/payments/verify/{reference}` (after payment)

### `OrderConfirmationScreen` (`/order-confirmation`)
- Load: `GET /api/orders/{id}`

### `OrdersScreen` (`/orders`)
- Load: `GET /api/orders`

### `OrderDetailsScreen` (`/order-details`)
- Load: `GET /api/orders/{id}`
- Action (if user can cancel/return): depends on backend support (not explicitly documented)

### `TrackingOrderScreen` (`/tracking-order`)
- Load: `GET /api/orders/{id}/tracking`

### `ReviewSubmissionScreen` (`/review-submission`)
- Action: `POST /api/reviews`

---

## Notifications

### `NotificationsScreen` (`/notifications`)
- Load: `GET /api/notifications`
- Action: `PUT /api/notifications/{id}/read`
- Action: `PUT /api/notifications/read-all`
- Action: `DELETE /api/notifications/{id}`
- Load (badge): `GET /api/notifications/unread-count`

### `NotificationsSettingsScreen` (`/notifications-settings`)
The API docs provide two similar preference endpoints:
- Load: `GET /api/notifications/preferences` OR `GET /api/user/notification-preferences`
- Action: `PUT /api/notifications/preferences` OR `PUT /api/user/notification-preferences`

---

## Blog

### `BlogScreen` (tab)
- Load: `GET /api/blogs`
- Action: `GET /api/blogs/search?query=...`
- Action: `POST /api/blogs/favorites` / `DELETE /api/blogs/favorites`

### `SingleBlogScreen`
- Load: `GET /api/blogs/{id}`

---

## Account / profile

### `AccountScreen` (tab)
- Load: `GET /api/user`
- Entry points:
  - Addresses → `AddressesScreen`
  - Orders → `OrdersScreen`
  - Notifications settings → `NotificationsSettingsScreen`
  - Business/Seller flows → see below

### `EditProfileScreen` (`/edit-profile`)
- Load: `GET /api/user`
- Action: `PUT /api/user/profile`

### `ChangePasswordScreen` (`/change-password`)
- Action: `PUT /api/user/password`

### `AddressesScreen` (`/addresses`)
- Load: `GET /api/addresses`

### `AddEditAddressScreen` (`/add-edit-address`)
- Load (edit): `GET /api/addresses/{id}`
- Action (create): `POST /api/addresses`
- Action (update): `PUT /api/addresses/{id}`
- Action (delete): `DELETE /api/addresses/{id}`

### `FaqsScreen` (`/faq`)
- Load: `GET /api/faqs`
- Action: `GET /api/faqs/search?query=...`

### `ConnectToUsScreen` (`/connect-to-us`)
- Load: `GET /api/connect`

---

## Business / seller

### Business onboarding screens
These screens should create/update a Business entity and potentially upload documents.

- `BusinessOnboardingScreen` → informational
- `BusinessCategoryScreen`:
  - Load: `GET /api/business/categories`
- Category forms (`BeautyBusinessDetailsScreen`, etc.):
  - Action: `POST /api/business`
  - Action: `POST /api/upload/business-document` (if required)
- `BusinessSettingsScreen` / `EditBusinessScreen`:
  - Load: `GET /api/business/{id}`
  - Action: `PUT /api/business/{id}`
- `DeactivateShopScreen` / `DeleteShopScreen`:
  - Action: `DELETE /api/business/{id}` or `DELETE /api/seller/profile` depending on what is being deactivated

### Seller profile
- `ShopDashboardScreen` (`/your-shop-dashboard`):
  - Load: `GET /api/seller/profile`
  - Load: `GET /api/products` (filtered to seller’s products; backend needs seller filter)
- `ManageShopScreen`:
  - Load/Action: `PUT /api/seller/profile`

### Seller product CRUD (not fully wired in UI yet)
- Create product: `POST /api/products`
- Update product: `PUT /api/products/{id}`
- Delete product: `DELETE /api/products/{id}`
- Upload images: `POST /api/upload/product-image`

