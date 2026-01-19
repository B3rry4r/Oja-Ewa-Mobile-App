# Ojaewa AI Service API Documentation

Welcome to the Ojaewa AI Service API documentation. This service provides AI-powered features for the Ojaewa Nigerian fashion marketplace, including product description generation, image enhancement, pricing optimization, personalized recommendations, and more.

## Base URL
`http://localhost:3000/ai`

## Authentication
Most endpoints require authentication using Ojaewa Laravel Sanctum tokens.

| Header | Value | Description |
|--------|-------|-------------|
| `Authorization` | `Bearer <your_token>` | Required for most seller and buyer endpoints. |

---

## Seller Endpoints

All seller endpoints require authentication and a seller profile.

### 1. Smart Product Descriptions
**POST** `/seller/product/description`
Generates SEO-friendly, culturally aware product descriptions using Nigerian fashion terminology.

- **Request Body:**
  ```json
  {
    "name": "Luxury Silk Ankara Agbada",
    "style": "Agbada",
    "tribe": "Yoruba",
    "gender": "Men",
    "price": 45000,
    "size": "L/XL",
    "materials": "Hand-woven Silk and Ankara",
    "occasion": "Wedding"
  }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "description": "Step into royalty with this Luxury Silk Ankara Agbada. Perfectly tailored for the modern Yoruba man, this piece combines traditional elegance with a contemporary silk finish...",
    "metadata": {
      "productName": "Luxury Silk Ankara Agbada",
      "generatedAt": "2026-01-19T14:00:00Z"
    }
  }
  ```

---

**POST** `/seller/product/description/batch`
Generates descriptions for up to 10 products simultaneously.

- **Request Body:**
  ```json
  {
    "products": [
      { "name": "Buba and Soro Set", "style": "Traditional", "gender": "Men" },
      { "name": "Iro and Buba", "style": "Traditional", "gender": "Women" }
    ]
  }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "results": [
      { "index": 0, "name": "Buba and Soro Set", "success": true, "description": "..." },
      { "index": 1, "name": "Iro and Buba", "success": true, "description": "..." }
    ],
    "summary": { "total": 2, "successful": 2, "failed": 0 }
  }
  ```

---

### 2. Product Photo Enhancement
**POST** `/seller/image/enhance`
Uses AI to improve resolution, adjust lighting, and sharpen product details.

- **Request Body (Multipart or JSON):**
  - `image`: File (via Multipart/form-data)
  OR
  - `imageUrl`: "https://example.com/image.jpg"
- **Success Response:**
  ```json
  {
    "success": true,
    "image": "data:image/jpeg;base64,...",
    "metadata": {
      "original": { "width": 800, "height": 600, "size": 102400 },
      "enhanced": { "width": 1600, "height": 1200, "size": 256000 }
    }
  }
  ```

---

**POST** `/seller/image/remove-bg`
Automatically detects the product and removes the background, returning a clean PNG.

- **Request Body:** Same as `/enhance`
- **Success Response:**
  ```json
  {
    "success": true,
    "image": "data:image/png;base64,...",
    "metadata": { "size": 204800 }
  }
  ```

---

**POST** `/seller/image/optimize`
Compresses images for fast loading and generates a square thumbnail.

- **Request Body:** Same as `/enhance`
- **Success Response:**
  ```json
  {
    "success": true,
    "main": { "image": "...", "width": 1080, "height": 1080, "size": 150000 },
    "thumbnail": { "image": "...", "width": 300, "height": 300, "size": 20000 },
    "savings": { "originalSize": 500000, "optimizedSize": 150000, "reduction": "70%" }
  }
  ```

---

### 3. Pricing Optimization
**POST** `/seller/pricing/suggest/:productId`
Suggests an optimal price based on similar products in the marketplace.

- **Success Response:**
  ```json
  {
    "success": true,
    "product": { "id": 1, "name": "Ankara Dress", "currentPrice": 45000 },
    "marketAnalysis": { "sampleSize": 50, "averagePrice": 42000, "minPrice": 35000, "maxPrice": 55000 },
    "recommendation": {
      "recommendedPrice": 43500,
      "priceRange": { "min": 38000, "optimal": 43500, "max": 48000 },
      "strategy": "competitive",
      "reasoning": "Your product is high quality but slightly priced above the current market average for Adire styles. A reduction to ₦43,500 will increase click-through rates.",
      "tips": ["Offer a bundle deal during Festive periods."]
    }
  }
  ```

---

**POST** `/seller/pricing/analyze`
Provides a deep dive into pricing trends for a category and tribe.

- **Request Body:**
  ```json
  {
    "style": "Traditional",
    "gender": "Women",
    "tribe": "Igbo"
  }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "marketStats": { "count": 100, "avg": 50000, "min": 20000, "max": 150000 },
    "analysis": {
      "positioning": "competitive",
      "competitiveness": 8,
      "observations": ["Price sensitive market"],
      "recommendations": ["Focus on value-add descriptions"]
    }
  }
  ```

---

### 4. Inventory & Trend Prediction
**GET** `/seller/trends/:category`
Identifies which styles within a category are currently gaining momentum.

- **Query Params:** `style=Casual`, `gender=Female`
- **Success Response:**
  ```json
  {
    "success": true,
    "trends": {
      "trendingStyles": [{ "style": "Adire", "score": 9, "growth": "rising" }],
      "emergingTrends": ["Asymmetric necklines"],
      "seasonalInsights": "Owambe season peak in December.",
      "marketSaturation": { "oversaturated": ["Basic Ankara"], "underserved": ["Silk Caftans"] }
    }
  }
  ```

---

**POST** `/seller/inventory/forecast`
Uses sales velocity and seasonal data to predict future stock requirements.

- **Request Body:**
  ```json
  { "timeframe": "30days" }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "forecast": {
      "summary": "Expect a 20% increase in demand for traditional sets.",
      "restock": [{ "product": "Luxury Agbada", "urgency": "high", "quantity": 15 }],
      "slowMoving": [{ "product": "Casual Shirt", "suggestion": "Clearance discount" }],
      "estimatedRevenue": { "optimized": 450000 }
    }
  }
  ```

---

**GET** `/seller/trends/seller/:sellerId`
Compares a seller's specific performance trends against the global marketplace.

---

### 5. Customer Insights
**GET** `/seller/customers/insights/:sellerId`
Aggregated metrics on customer satisfaction, lifetime value, and retention rates.

- **Success Response:**
  ```json
  {
    "success": true,
    "metrics": {
      "totalCustomers": 120,
      "repeatRate": "25%",
      "avgOrderValue": 35000
    },
    "insights": {
      "healthScore": 88,
      "summary": "Strong growth in the Lagos region.",
      "actionItems": ["Offer loyalty points to top 10% of buyers."]
    }
  }
  ```

---

**GET** `/seller/customers/segments/:sellerId`
Categorizes the customer base into VIP, Regular, Casual, and At-Risk segments.

- **Success Response:**
  ```json
  {
    "success": true,
    "segmentCounts": { "vip": 12, "regular": 45, "casual": 30, "atRisk": 13 },
    "analysis": {
      "focus": "Convert Regular-to-VIP",
      "strategies": { "atRisk": "Send 'We Miss You' discount code." }
    }
  }
  ```

---

**GET** `/seller/customers/behavior/:customerId`
A detailed profile of a single customer's style preferences and predicted next purchase.

---

### 6. Marketing Copy Generation
**POST** `/seller/marketing/social-post/:productId`
Generates platform-specific captions and hashtags.

- **Request Body:**
  ```json
  { "platform": "instagram" }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "content": {
      "caption": "Elevate your weekend with our new arrivals! 🇳🇬✨",
      "hashtags": ["NigerianFashion", "OwambeReady"],
      "bestPostingTime": "7:00 PM WAT"
    }
  }
  ```

---

**POST** `/seller/marketing/email-campaign`
Generates full email templates for promotions or seasonal events.

- **Request Body:**
  ```json
  {
    "campaignType": "promotion",
    "products": [1, 2],
    "discount": "10%",
    "occasion": "Christmas Sale"
  }
  ```
- **Success Response:**
  ```json
  { "success": true, "campaign": { "subject": "Merry & Stylish...", "body": "..." } }
  ```

---

**POST** `/seller/marketing/product-tags/:productId`
Generates SEO keywords and meta descriptions for the web storefront.

---

### 7. Return Risk Prediction
**POST** `/seller/returns/predict/:orderId`
Analyzes order history and product category to flag potential return risks.

- **Success Response:**
  ```json
  {
    "success": true,
    "prediction": {
      "riskLevel": "high",
      "riskFactors": ["Frequent sizing issues in this category"],
      "prevention": "Include a handwritten note confirming measurements."
    }
  }
  ```

---

**GET** `/seller/returns/high-risk/:sellerId`
Returns a list of all current orders with a risk score above 60.

---

### 8. Competition Analysis
**GET** `/seller/competition/analysis/:sellerId/:category`
Benchmark your prices and product availability against the top 5 competitors in your category.

- **Success Response:**
  ```json
  {
    "success": true,
    "analysis": {
      "marketPosition": "Premium Tier",
      "competitorPrices": { "competitorA": 32000, "competitorB": 48000 },
      "strength": "Unique Embroidery Style"
    }
  }
  ```

---

**GET** `/seller/competition/gaps/:category`
Identifies "White Space" opportunities where demand is high but availability is low.

---

**POST** `/seller/competition/strategy`
Generates a 30-60-90 day strategic plan based on competitive positioning.

---

### 9. AI Product Photography
**POST** `/seller/photography/generate-model`
Generates professional prompts for AI image generators to create on-model photos.

- **Request Body:**
  ```json
  {
    "productId": 101,
    "modelPreferences": { "gender": "male", "ethnicity": "Yoruba", "vibe": "Royal" }
  }
  ```
- **Success Response:**
  ```json
  { "success": true, "mainPrompt": "Close up shot of a Regal Yoruba man wearing...", "lighting": "Golden Hour" }
  ```

---

**POST** `/seller/photography/lifestyle-scene`
Generates prompts for placing products in realistic Nigerian settings (Weddings, Lagos streets).

---

### 10. Granular Demand Forecasting
**POST** `/seller/demand/forecast-color/:category`
Predicts which colors will trend in the next 3 months.

---

**POST** `/seller/demand/forecast-size/:category`
Predicts the optimal size curve (e.g. 10% S, 40% M, etc.) to minimize overstock.

---

**POST** `/seller/demand/inventory-optimize`
Optimizes a product mix based on a specific procurement budget.

- **Request Body:**
  ```json
  { "budget": 1000000 }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "optimalMix": [
        { "name": "Agbada", "quantity": 10, "cost": 400000 },
        { "name": "Buba Set", "quantity": 25, "cost": 600000 }
    ]
  }
  ```

---

## Buyer Endpoints

### 1. Recommendations & Style Quiz
**POST** `/buyer/style-quiz`
Captures personal style DNA including tribal influence, color preferences, and fit.

- **Request Body:**
  ```json
  {
    "answers": {
      "favorite_color": "Indigo",
      "fit_preference": "Slim",
      "primary_style": "Traditional-Modern",
      "tribe": "Igbo"
    }
  }
  ```
- **Success Response:**
  ```json
  { "success": true, "message": "Style DNA updated successfully." }
  ```

---

**GET** `/buyer/recommendations/:userId`
Returns personalized product suggestions based on Style DNA and browsing history.

- **Success Response:**
  ```json
  {
    "success": true,
    "recommendations": [
        { "productId": 1, "matchScore": 95, "reason": "Matches your preference for Igbo traditional wear." }
    ]
  }
  ```

---

### 2. Smart Visual Search
**POST** `/buyer/visual-search`
Upload an image to find identical or similar products in the marketplace.

- **Request Body:**
  ```json
  { "imageBase64": "..." }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "matches": [{ "productId": 15, "similarity": 0.92, "thumbnail": "..." }]
  }
  ```

---

### 3. Cultural AI Assistant (Chatbot)
**POST** `/buyer/chat`
Ask fashion and cultural questions (e.g., "What should I wear to a Kano wedding?").

- **Request Body:**
  ```json
  { "message": "Can you explain the significance of the Gele in Yoruba culture?" }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "reply": "The Gele is more than just a head-tie; it represents a woman's social status and elegance. For weddings, a more elaborate...",
    "suggestedProducts": [{ "id": 44, "name": "Silk Gele" }]
  }
  ```

---

**GET** `/buyer/chat/history/:userId`
Retrieves previous conversations to maintain context.

---

### 4. Smart Review Analysis
**GET** `/buyer/reviews/summary/:productId`
AI summarizes 100s of reviews into 5 key bullet points (Pros/Cons).

- **Success Response:**
  ```json
  {
    "success": true,
    "summary": {
      "overallSentiment": "Positive",
      "highlights": ["Fabric is authentic", "Colors don't fade"],
      "concerns": ["Sizing runs small"]
    }
  }
  ```

---

**GET** `/buyer/reviews/sentiment/:productId`
Deep dive into the emotional tone of reviews (Excitement, Satisfaction, Frustrated).

---

### 5. Beauty Product Matching
**POST** `/buyer/beauty/match-foundation`
Analyzes skin tone via photo to recommend the closest foundation shades.

- **Request Body:**
  ```json
  { "imageBase64": "...", "skinType": "Combination" }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "matches": { "tone": "Rich Dark", "undertone": "Warm", "shadeCodes": ["F01", "F03"] }
  }
  ```

---

**POST** `/buyer/beauty/color-season`
Analyzes facial features to determine your "Color Season" (e.g., Deep Autumn).

---

### 6. Size Prediction & Fit Analysis
**POST** `/buyer/sizing/predict`
Predicts the best size for a specific product based on your measurements.

- **Request Body:**
  ```json
  {
    "productId": 202,
    "measurements": { "chest": 42, "waist": 36, "height": "180cm" }
  }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "prediction": { "size": "XL", "fit": "Tapered", "confidence": 89 }
  }
  ```

---

**POST** `/buyer/sizing/save-measurements`
Persists body measurements to the user profile for one-click size prediction.

---

### 7. Outfit Generator
**POST** `/buyer/outfits/generate-from-items`
Takes a list of items and generates stylish combination options.

- **Request Body:**
  ```json
  { "items": ["Blue Suit", "White Shirt"], "occasion": "Wedding" }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "outfits": [
        { "combination": "Blue Suit with Silk Tie", "stylingTip": "Add a pocket square." }
    ]
  }
  ```

---

**POST** `/buyer/outfits/occasion`
Suggests complete outfits from the marketplace for a specific occasion and budget.

---

### 8. Complete Look Builder
**POST** `/buyer/looks/wedding-guest`
Builds a curated event look: Main outfit, shoes, accessories, and head-tie.

- **Request Body:**
  ```json
  { "weddingType": "Traditional", "tribe": "Hausa", "budget": 150000 }
  ```
- **Success Response:**
  ```json
  {
    "success": true,
    "look": {
        "outfit": "Baban Riga",
        "accessories": "Leather Sandals, Embroidered Cap",
        "totalEstimate": 145000
    }
  }
  ```

---

### 9. Sustainability Matching
**GET** `/buyer/sustainability/alternatives/:productId`
Finds similar items made from sustainable fabrics or ethical sources.

- **Success Response:**
  ```json
  {
    "success": true,
    "recommendations": [{ "productId": 9, "score": 90, "fabric": "Organic Cotton Adire" }]
  }
  ```

---

**GET** `/buyer/sustainability/score/:productId`
A rating of the item's environmental impact (1-100).

---

### 10. Weather-Based Recommendations
**GET** `/buyer/weather/recommendations/:userId`
Suggests outfits based on the current weather in your location.

- **Query Params:** `location=Lagos`
- **Success Response:**
  ```json
  {
    "success": true,
    "weather": "Sunny, Humid",
    "advice": "Wear light linens or breezy cottons today.",
    "topPicks": [{ "productId": 77, "reason": "Breathable fabric" }]
  }
  ```

---

**GET** `/buyer/weather/outfit/:userId/:occasion`
Creates a weather-appropriate outfit for an event (e.g. Rainy day wedding).

---

### 11. Personal Trend Forecasting
**GET** `/buyer/trends/personal/:userId`
Predicts what styles you will love next based on your evolving taste.

- **Success Response:**
  ```json
  { "success": true, "prediction": "Your style is shifting toward Minimalist Traditional." }
  ```

---

**POST** `/buyer/trends/analyze`
General report on what is hot in Nigeria right now (Lagos vs. Abuja vs. Kano).

---

## Error Responses
The API uses standard HTTP status codes.

| Code | Meaning | Description |
|------|---------|-------------|
| `200` | Success | Request was successful. |
| `400` | Bad Request | Missing or invalid parameters. |
| `401` | Unauthorized | Token is missing or expired. |
| `403` | Forbidden | Authenticated but lack 'seller' permissions. |
| `404` | Not Found | Resource (product, user, order) does not exist. |
| `429` | Too Many Requests | Rate limit exceeded. |
| `500` | Server Error | An internal problem occurred. |

**Error Payload:**
```json
{
  "success": false,
  "error": "Detailed error message describing what went wrong."
}
```
