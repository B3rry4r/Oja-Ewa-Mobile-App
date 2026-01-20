# Ojaewa IAP Subscriptions API (Laravel)

Base URL: `https://api.ojaewa.com/api`

Authentication: Bearer token (Sanctum)

---

---

## Notes

- Only `ojaewa_pro` is supported
- `POST /subscriptions/verify` only stores purchase data (no verification yet)
- Verification with Apple/Google will be added later
- If `transaction_id + platform` already exists, subscription is updated

---

## Subscription Products

### Product ID (Use this exactly in App Store Connect & Google Play Console)

| Product ID | Platform | Type | Duration | Description |
|------------|----------|------|----------|-------------|
| `ojaewa_pro` | Both | Auto-Renewable | 1 Year | Ojaewa Pro subscription |

### Subscription Tiers

#### 1. Free Tier (Default)
- Basic seller features
- Limited product listings (e.g., 10 products)
- No AI features
- Standard support

#### 2. Ojaewa Pro (Yearly) - `ojaewa_pro`
- Unlimited product listings
- AI Product Descriptions
- AI Analytics Dashboard
- Trend Predictions
- Inventory Forecasting
- Customer Insights
- Featured placement
- Priority support
- Verified seller badge

---

## Database Schema

### Table: `subscriptions`

```sql
CREATE TABLE subscriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    
    -- Subscription Details
    product_id VARCHAR(100) NOT NULL,           -- e.g., 'ojaewa_pro'
    tier VARCHAR(50) NOT NULL,                   -- 'ojaewa_pro' | 'free'
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

### 1) Store Subscription (No Verification Yet)

**Endpoint:** `POST /subscriptions/verify`

This endpoint only stores the purchase data. Receipt verification will be added later.

**Request Body**
```json
{
  "platform": "ios",
  "product_id": "ojaewa_pro",
  "transaction_id": "1000000123456789",
  "receipt_data": "MIIbngYJKoZIhvc...",
  "environment": "sandbox"
}
```

**Response (200)**
```json
{
  "success": true,
  "message": "Subscription verified and activated",
  "data": {
    "subscription": {
      "id": 4,
      "product_id": "ojaewa_pro",
      "tier": "ojaewa_pro",
      "status": "active",
      "starts_at": "2026-01-20T17:57:54.000000Z",
      "expires_at": "2027-01-20T17:57:54.000000Z",
      "is_auto_renewing": true,
      "platform": "ios"
    }
  }
}
```

---

### 2) Get Subscription Status

**Endpoint:** `GET /subscriptions/status`

**Response (No Subscription)**
```json
{
  "success": true,
  "data": {
    "has_subscription": false,
    "subscription": null
  }
}
```

**Response (Active Subscription)**
```json
{
  "success": true,
  "data": {
    "has_subscription": true,
    "subscription": {
      "id": 4,
      "product_id": "ojaewa_pro",
      "tier": "ojaewa_pro",
      "status": "active",
      "platform": "ios",
      "starts_at": "2026-01-20T17:57:54.000000Z",
      "expires_at": "2027-01-20T17:57:54.000000Z",
      "days_remaining": 364,
      "is_auto_renewing": true,
      "will_renew": true
    }
  }
}
```

---

## Notes

- Only `ojaewa_pro` is currently supported
- Verification with Apple/Google will be added later
- If `transaction_id + platform` already exists, subscription is updated


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
        'ojaewa_pro' => [
            'max_products' => -1, // unlimited
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
