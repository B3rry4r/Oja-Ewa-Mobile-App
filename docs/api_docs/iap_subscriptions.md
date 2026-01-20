# Ojaewa IAP & Subscriptions - Backend API Specification

> **Version:** 1.0  
> **Last Updated:** January 2026  
> **Purpose:** Backend API endpoints required for In-App Purchase (IAP) subscription management

---

## Overview

This document specifies the backend API endpoints required to support yearly subscriptions for Sellers and Business Profiles in the Ojaewa app. Subscriptions are processed through Apple App Store and Google Play Store, with the backend responsible for:

1. **Verification** - Validating purchase receipts with Apple/Google
2. **Storage** - Storing subscription details and status
3. **Access Control** - Determining feature access based on subscription status
4. **Webhook Handling** - Processing subscription lifecycle events (renewals, cancellations, etc.)

---

## Subscription Products

### Product IDs (Use these exactly in App Store Connect & Google Play Console)

| Product ID | Platform | Type | Duration | Description |
|------------|----------|------|----------|-------------|
| `ojaewa_seller_pro_yearly` | Both | Auto-Renewable | 1 Year | Seller Pro subscription |
| `ojaewa_business_premium_yearly` | Both | Auto-Renewable | 1 Year | Business Premium subscription |

### Subscription Tiers

#### 1. Free Tier (Default)
- Basic seller features
- Limited product listings (e.g., 10 products)
- No AI features
- Standard support

#### 2. Seller Pro (₦49,999/year) - `ojaewa_seller_pro_yearly`
- Unlimited product listings
- AI Product Descriptions
- Basic Analytics
- Priority support
- Verified seller badge

#### 3. Business Premium (₦99,999/year) - `ojaewa_business_premium_yearly`
- Everything in Seller Pro
- Full AI Analytics Dashboard
- Trend Predictions
- Inventory Forecasting
- Customer Insights
- Featured placement
- Premium support

---

## Database Schema

### Table: `subscriptions`

```sql
CREATE TABLE subscriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    
    -- Subscription Details
    product_id VARCHAR(100) NOT NULL,           -- e.g., 'ojaewa_seller_pro_yearly'
    tier VARCHAR(50) NOT NULL,                   -- 'seller_pro' | 'business_premium'
    platform VARCHAR(20) NOT NULL,               -- 'ios' | 'android'
    
    -- Store Transaction Info
    store_transaction_id VARCHAR(255) NOT NULL,  -- Original transaction ID from store
    store_product_id VARCHAR(100) NOT NULL,      -- Product ID from store
    purchase_token TEXT NULL,                    -- Google Play purchase token
    receipt_data TEXT NULL,                      -- Apple receipt data (base64)
    
    -- Status & Dates
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- 'active' | 'expired' | 'cancelled' | 'grace_period' | 'paused'
    starts_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    cancelled_at TIMESTAMP NULL,
    
    -- Renewal Info
    is_auto_renewing BOOLEAN DEFAULT TRUE,
    will_renew BOOLEAN DEFAULT TRUE,
    renewal_price DECIMAL(10, 2) NULL,
    renewal_currency VARCHAR(3) DEFAULT 'NGN',
    
    -- Metadata
    environment VARCHAR(20) DEFAULT 'production', -- 'sandbox' | 'production'
    raw_data JSON NULL,                          -- Full response from store for debugging
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_transaction (store_transaction_id, platform),
    INDEX idx_user_status (user_id, status),
    INDEX idx_expires (expires_at),
    INDEX idx_product (product_id)
);
```

### Table: `subscription_history`

```sql
CREATE TABLE subscription_history (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    subscription_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    
    event_type VARCHAR(50) NOT NULL,  -- See event types below
    event_data JSON NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_subscription (subscription_id),
    INDEX idx_user (user_id)
);
```

**Event Types:**
- `purchased` - Initial purchase
- `renewed` - Auto-renewal successful
- `cancelled` - User cancelled (will expire at period end)
- `expired` - Subscription expired
- `reactivated` - User resubscribed after expiry
- `upgraded` - Upgraded to higher tier
- `downgraded` - Downgraded to lower tier
- `refunded` - Purchase refunded
- `grace_period_started` - Payment failed, grace period started
- `grace_period_ended` - Grace period ended
- `paused` - Subscription paused (Android only)
- `resumed` - Subscription resumed from pause

---

## API Endpoints

### Base URL
```
https://api.ojaewa.com/api/v1
```

### Authentication
All endpoints require Bearer token authentication:
```
Authorization: Bearer {sanctum_token}
```

---

### 1. Verify & Store Purchase

**Endpoint:** `POST /subscriptions/verify`

Called by the app after a successful purchase to verify with Apple/Google and store the subscription.

**Request:**
```json
{
    "platform": "ios",                              // "ios" | "android"
    "product_id": "ojaewa_seller_pro_yearly",       // Product ID
    "transaction_id": "1000000123456789",           // Store transaction ID
    "receipt_data": "MIIbngYJKoZIhvc...",          // iOS: Base64 receipt | Android: purchase token
    "environment": "production"                     // "sandbox" | "production"
}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "message": "Subscription verified and activated",
    "data": {
        "subscription": {
            "id": 123,
            "product_id": "ojaewa_seller_pro_yearly",
            "tier": "seller_pro",
            "status": "active",
            "starts_at": "2026-01-18T00:00:00Z",
            "expires_at": "2027-01-18T00:00:00Z",
            "is_auto_renewing": true,
            "platform": "ios"
        },
        "features": {
            "unlimited_products": true,
            "ai_descriptions": true,
            "ai_analytics": false,
            "trend_predictions": false,
            "inventory_forecasting": false,
            "verified_badge": true,
            "priority_support": true
        }
    }
}
```

**Response (Invalid Receipt - 400):**
```json
{
    "success": false,
    "message": "Invalid receipt",
    "error": {
        "code": "INVALID_RECEIPT",
        "details": "Receipt verification failed with store"
    }
}
```

**Response (Already Processed - 409):**
```json
{
    "success": false,
    "message": "Transaction already processed",
    "error": {
        "code": "DUPLICATE_TRANSACTION",
        "details": "This transaction has already been verified"
    }
}
```

---

### 2. Get Current Subscription Status

**Endpoint:** `GET /subscriptions/status`

Returns the current user's subscription status and entitled features.

**Response (Active Subscription):**
```json
{
    "success": true,
    "data": {
        "has_subscription": true,
        "subscription": {
            "id": 123,
            "product_id": "ojaewa_seller_pro_yearly",
            "tier": "seller_pro",
            "tier_name": "Seller Pro",
            "status": "active",
            "platform": "ios",
            "starts_at": "2026-01-18T00:00:00Z",
            "expires_at": "2027-01-18T00:00:00Z",
            "days_remaining": 365,
            "is_auto_renewing": true,
            "will_renew": true
        },
        "features": {
            "unlimited_products": true,
            "ai_descriptions": true,
            "ai_analytics": false,
            "trend_predictions": false,
            "inventory_forecasting": false,
            "customer_insights": false,
            "verified_badge": true,
            "priority_support": true,
            "featured_placement": false,
            "max_products": -1
        }
    }
}
```

**Response (No Subscription):**
```json
{
    "success": true,
    "data": {
        "has_subscription": false,
        "subscription": null,
        "features": {
            "unlimited_products": false,
            "ai_descriptions": false,
            "ai_analytics": false,
            "trend_predictions": false,
            "inventory_forecasting": false,
            "customer_insights": false,
            "verified_badge": false,
            "priority_support": false,
            "featured_placement": false,
            "max_products": 10
        }
    }
}
```

**Response (Expired):**
```json
{
    "success": true,
    "data": {
        "has_subscription": false,
        "subscription": {
            "id": 123,
            "product_id": "ojaewa_seller_pro_yearly",
            "tier": "seller_pro",
            "status": "expired",
            "expires_at": "2026-01-15T00:00:00Z",
            "days_since_expiry": 3,
            "can_restore": true
        },
        "features": {
            // Free tier features
        }
    }
}
```

---

### 3. Get Subscription Plans

**Endpoint:** `GET /subscriptions/plans`

Returns available subscription plans with pricing (for display in app).

**Response:**
```json
{
    "success": true,
    "data": {
        "plans": [
            {
                "product_id": "ojaewa_seller_pro_yearly",
                "name": "Seller Pro",
                "description": "Unlock powerful selling tools and AI features",
                "tier": "seller_pro",
                "duration": "yearly",
                "price": {
                    "amount": 49999,
                    "currency": "NGN",
                    "formatted": "₦49,999/year"
                },
                "features": [
                    "Unlimited product listings",
                    "AI Product Descriptions",
                    "Basic Analytics",
                    "Verified Seller Badge",
                    "Priority Support"
                ],
                "popular": true
            },
            {
                "product_id": "ojaewa_business_premium_yearly",
                "name": "Business Premium",
                "description": "Full suite of AI-powered business tools",
                "tier": "business_premium",
                "duration": "yearly",
                "price": {
                    "amount": 99999,
                    "currency": "NGN",
                    "formatted": "₦99,999/year"
                },
                "features": [
                    "Everything in Seller Pro",
                    "Full AI Analytics Dashboard",
                    "Trend Predictions",
                    "Inventory Forecasting",
                    "Customer Insights",
                    "Featured Placement",
                    "Premium Support"
                ],
                "popular": false
            }
        ],
        "free_tier": {
            "name": "Free",
            "features": [
                "Up to 10 product listings",
                "Basic seller tools",
                "Standard support"
            ]
        }
    }
}
```

---

### 4. Restore Purchases

**Endpoint:** `POST /subscriptions/restore`

Called when user taps "Restore Purchases" - verifies and restores any active subscriptions.

**Request:**
```json
{
    "platform": "ios",
    "receipt_data": "MIIbngYJKoZIhvc...",   // iOS: Full receipt | Android: Not needed (use Play Billing API)
    "purchase_tokens": [                      // Android only: List of purchase tokens to verify
        "token1...",
        "token2..."
    ]
}
```

**Response (Restored):**
```json
{
    "success": true,
    "message": "Subscription restored successfully",
    "data": {
        "restored": true,
        "subscription": {
            // Same as verify response
        }
    }
}
```

**Response (Nothing to Restore):**
```json
{
    "success": true,
    "message": "No active subscriptions found",
    "data": {
        "restored": false,
        "subscription": null
    }
}
```

---

### 5. Get Subscription History

**Endpoint:** `GET /subscriptions/history`

Returns the user's subscription history.

**Response:**
```json
{
    "success": true,
    "data": {
        "history": [
            {
                "id": 1,
                "event_type": "purchased",
                "product_id": "ojaewa_seller_pro_yearly",
                "tier": "seller_pro",
                "created_at": "2026-01-18T10:30:00Z"
            },
            {
                "id": 2,
                "event_type": "renewed",
                "product_id": "ojaewa_seller_pro_yearly",
                "tier": "seller_pro",
                "created_at": "2027-01-18T10:30:00Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "per_page": 20,
            "total": 2
        }
    }
}
```

---

### 6. Cancel Subscription Info

**Endpoint:** `GET /subscriptions/cancel-info`

Returns information about cancelling (subscriptions are cancelled through App Store/Play Store).

**Response:**
```json
{
    "success": true,
    "data": {
        "cancellation_url": {
            "ios": "https://apps.apple.com/account/subscriptions",
            "android": "https://play.google.com/store/account/subscriptions"
        },
        "current_subscription": {
            "expires_at": "2027-01-18T00:00:00Z",
            "will_lose_access_on": "2027-01-18T00:00:00Z"
        },
        "message": "You can cancel anytime. You'll keep access until your current period ends."
    }
}
```

---

## Webhook Endpoints

### Apple App Store Server Notifications (V2)

**Endpoint:** `POST /webhooks/apple/subscriptions`

**Headers:**
```
Content-Type: application/json
```

**Notification Types to Handle:**
- `SUBSCRIBED` - New subscription
- `DID_RENEW` - Successful renewal
- `DID_FAIL_TO_RENEW` - Renewal failed
- `DID_CHANGE_RENEWAL_STATUS` - Auto-renew toggled
- `EXPIRED` - Subscription expired
- `GRACE_PERIOD_EXPIRED` - Grace period ended
- `REFUND` - Purchase refunded
- `REVOKE` - Family sharing revoked

**Implementation Notes:**
1. Verify the `signedPayload` using Apple's certificates
2. Decode the JWS to get the notification data
3. Update subscription status accordingly
4. Log to `subscription_history`

---

### Google Play Real-time Developer Notifications

**Endpoint:** `POST /webhooks/google/subscriptions`

**Setup:** Configure Pub/Sub topic in Google Play Console

**Notification Types:**
- `SUBSCRIPTION_PURCHASED` (1)
- `SUBSCRIPTION_RENEWED` (2)
- `SUBSCRIPTION_RECOVERED` (3) - From account hold
- `SUBSCRIPTION_CANCELED` (4)
- `SUBSCRIPTION_ON_HOLD` (5)
- `SUBSCRIPTION_IN_GRACE_PERIOD` (6)
- `SUBSCRIPTION_RESTARTED` (7)
- `SUBSCRIPTION_PRICE_CHANGE_CONFIRMED` (8)
- `SUBSCRIPTION_DEFERRED` (9)
- `SUBSCRIPTION_PAUSED` (10)
- `SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED` (11)
- `SUBSCRIPTION_REVOKED` (12)
- `SUBSCRIPTION_EXPIRED` (13)

**Implementation Notes:**
1. Verify the Pub/Sub message authenticity
2. Decode the `data` field (base64)
3. Use Google Play Developer API to get full subscription details
4. Update subscription status accordingly

---

## Receipt Verification

### Apple App Store

Use the App Store Server API (recommended) or legacy `verifyReceipt` endpoint:

**Production:** `https://api.storekit.itunes.apple.com/inApps/v1/`
**Sandbox:** `https://api.storekit-sandbox.itunes.apple.com/inApps/v1/`

### Google Play

Use the Google Play Developer API:

```
GET https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{packageName}/purchases/subscriptions/{subscriptionId}/tokens/{token}
```

---

## Feature Flags by Tier

```php
// Example Laravel implementation
class SubscriptionFeatures
{
    const FEATURES = [
        'free' => [
            'max_products' => 10,
            'unlimited_products' => false,
            'ai_descriptions' => false,
            'ai_analytics' => false,
            'trend_predictions' => false,
            'inventory_forecasting' => false,
            'customer_insights' => false,
            'verified_badge' => false,
            'priority_support' => false,
            'featured_placement' => false,
        ],
        'seller_pro' => [
            'max_products' => -1, // unlimited
            'unlimited_products' => true,
            'ai_descriptions' => true,
            'ai_analytics' => false,
            'trend_predictions' => false,
            'inventory_forecasting' => false,
            'customer_insights' => false,
            'verified_badge' => true,
            'priority_support' => true,
            'featured_placement' => false,
        ],
        'business_premium' => [
            'max_products' => -1,
            'unlimited_products' => true,
            'ai_descriptions' => true,
            'ai_analytics' => true,
            'trend_predictions' => true,
            'inventory_forecasting' => true,
            'customer_insights' => true,
            'verified_badge' => true,
            'priority_support' => true,
            'featured_placement' => true,
        ],
    ];
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| `INVALID_RECEIPT` | Receipt verification failed |
| `RECEIPT_EXPIRED` | Receipt is for expired subscription |
| `DUPLICATE_TRANSACTION` | Transaction already processed |
| `INVALID_PRODUCT` | Unknown product ID |
| `PLATFORM_MISMATCH` | Receipt platform doesn't match |
| `USER_MISMATCH` | Receipt belongs to different user |
| `STORE_ERROR` | Error communicating with App Store/Play Store |
| `WEBHOOK_INVALID` | Invalid webhook signature |

---

## Testing

### Sandbox Testing

**iOS:**
1. Use Sandbox Apple ID accounts
2. Subscriptions renew quickly (1 year = 1 hour in sandbox)
3. Set `environment: "sandbox"` in verify request

**Android:**
1. Add test accounts in Google Play Console
2. Use license testing for faster renewals
3. Test with `purchase_token` from test purchases

### Test Product IDs
Use the same product IDs - the stores differentiate sandbox vs production automatically.

---

## Security Considerations

1. **Always verify receipts server-side** - Never trust client-side validation alone
2. **Store raw receipt data** - Useful for debugging and re-verification
3. **Validate webhook signatures** - Both Apple and Google sign their webhooks
4. **Use HTTPS** - All endpoints must be HTTPS
5. **Rate limit** - Protect verification endpoints from abuse
6. **Audit logging** - Log all subscription changes to `subscription_history`

---

## Checklist for Backend Implementation

- [ ] Create `subscriptions` table
- [ ] Create `subscription_history` table
- [ ] Implement `POST /subscriptions/verify`
- [ ] Implement `GET /subscriptions/status`
- [ ] Implement `GET /subscriptions/plans`
- [ ] Implement `POST /subscriptions/restore`
- [ ] Implement `GET /subscriptions/history`
- [ ] Implement `GET /subscriptions/cancel-info`
- [ ] Set up Apple webhook endpoint
- [ ] Set up Google webhook endpoint
- [ ] Configure Apple App Store Server API credentials
- [ ] Configure Google Play Developer API credentials
- [ ] Implement feature flags/gates based on subscription tier
- [ ] Add subscription status to user profile response
- [ ] Test with sandbox accounts
- [ ] Set up monitoring for webhook failures

---

## Questions for Discussion

1. **Grace Period:** How long should users retain access after payment failure? (Suggested: 7 days)
2. **Downgrade Policy:** When user doesn't renew, immediate downgrade or at period end?
3. **Refund Handling:** Auto-revoke access on refund or manual review?
4. **Family Sharing:** Support iOS Family Sharing for subscriptions?
5. **Promo Codes:** Will you offer promotional pricing?
