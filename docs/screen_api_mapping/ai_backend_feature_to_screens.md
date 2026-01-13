# Node.js AI Backend (Gemini) → Screens & Flows

Source: `docs/NODE_AI_BACKEND_SIMPLE_PLAN.md`.

The Node.js AI backend is a separate service:
- Laravel: `https://ojaewa-laravel.railway.app` (existing)
- AI service: `https://ojaewa-ai.railway.app` (new)

Frontend should send the **same Bearer token** to both services.

## Buyer AI features: what screens change / what new screens are needed

### 1) Style DNA Quiz → Personalized Recommendations
Node endpoints:
- `POST /ai/style-quiz`
- `GET /ai/recommendations/:userId`
- `POST /ai/outfits/generate`

Recommended UI additions:
- **New screen:** `StyleDnaQuizScreen` (entry from onboarding and/or Account)
- **New screen:** `PersonalizedRecommendationsScreen` (or a Home section)
- **Update:** `HomeScreen` to show a "For You" carousel (calls recommendations)
- **Update:** `ProductListingScreen` to support a "Recommended" mode

### 2) Smart Visual Search
Node endpoints:
- `POST /ai/visual-search`
- `GET /ai/similar/:productId`

Recommended UI additions:
- **Update:** `SearchScreen` add a camera/gallery button
- **New screen:** `VisualSearchCaptureScreen` (camera/gallery, upload)
- **New screen/state:** search results populated from AI response (product IDs) then hydrate via Laravel `GET /api/products/{id}` or `GET /api/products` + filter
- **Update:** `ProductDetailScreen` add "Similar items" section (AI similar endpoint)

### 3) Cultural AI Assistant (Chatbot)
Node endpoints:
- `POST /ai/chat`
- `GET /ai/chat/history/:userId`

Recommended UI additions:
- **New screen:** `AiAssistantChatScreen` (entry from Home and Account)
- **Update:** `ConnectToUsScreen` optionally add "Chat with OjaEwa AI" entry
- **Update:** `FaqsScreen` optionally add "Ask AI" search fallback

### 4) Smart Review Analysis
Node endpoints:
- `GET /ai/reviews/summary/:productId`
- `GET /ai/reviews/sentiment/:productId`

Recommended UI additions:
- **Update:** `ProductDetailScreen` reviews tab/section to include:
  - AI summary block
  - sentiment breakdown (positive/neutral/negative)

### 5) Beauty Product Matching (skin tone / color season)
Node endpoints:
- `POST /ai/beauty/match-foundation`
- `POST /ai/beauty/color-season`
- `GET /ai/beauty/recommendations/:userId`

Recommended UI additions:
- **Update:** `BeautyScreen` add "Find my shade" CTA
- **New screen:** `BeautyAnalysisScreen` (capture selfie / select photo)
- **New screen:** `BeautyRecommendationsScreen`

### 6) Size Prediction & Fit Analysis
Node endpoints:
- `POST /ai/sizing/predict`
- `GET /ai/sizing/fit-feedback/:productId`
- `POST /ai/sizing/returns-analysis`

Recommended UI additions:
- **Update:** `ProductDetailScreen` add "Find my size" button
- **New UI component:** `SizePredictionBottomSheet`
- **New screen (optional):** `MeasurementsProfileScreen` (store user measurements locally or via Laravel profile extension)

### 7) Outfit Generator / Style board
Node endpoints:
- `POST /ai/outfits/generate-from-items`
- `POST /ai/outfits/complete-look`
- `POST /ai/outfits/occasion`
- `GET /ai/outfits/style-board/:userId`

Recommended UI additions:
- **New tab or Home section:** "Outfits" / "Style board"
- **New screen:** `StyleBoardScreen`
- **New screen:** `OutfitGeneratorScreen` (select items from wishlist/orders)

### 8) Complete Look Builder (occasion-based)
Node endpoints:
- `POST /ai/looks/wedding-guest`
- `POST /ai/looks/business-casual`
- `POST /ai/looks/traditional-event`
- `POST /ai/looks/party`

Recommended UI additions:
- **New screen:** `OccasionLookBuilderScreen`
- Entry points: `HomeScreen` (banner) + `SearchScreen` filters

### 9) Sustainability Matching
Node endpoints:
- `GET /ai/sustainability/alternatives/:productId`
- `GET /ai/sustainability/score/:productId`
- `GET /ai/sustainability/brands`
- `POST /ai/sustainability/analyze`

Recommended UI additions:
- **Update:** `ProductDetailScreen` add sustainability score and "eco alternatives" carousel
- **Update:** `SustainabilityScreen` to show:
  - sustainable brands list
  - curated sustainable alternatives

### 10) Weather-based recommendations
Node endpoints:
- `GET /ai/weather/recommendations/:userId`
- `GET /ai/weather/outfit/:userId/:occasion`

Recommended UI additions:
- **Update:** `HomeScreen` optional "Weather picks" section
- **Update:** `OccasionLookBuilderScreen` to factor weather

### 11) Personal trend forecasting
Node endpoints:
- `GET /ai/trends/personal/:userId`
- `GET /ai/trends/upcoming/:category`
- `POST /ai/trends/analyze`

Recommended UI additions:
- **New screen:** `TrendsScreen` (could live under Home or Blog)
- **Update:** `HomeScreen` add "Trending for you" section

---

## Seller AI features: what screens change / what new screens are needed

These mostly attach to **Your Shop** (`ShopDashboardScreen`) and product creation/editing.

### Seller Feature 1: Smart Product Descriptions
Node endpoints:
- `POST /ai/product/description`

UI changes:
- **Update:** Add/Edit product flow to include "Generate description" (fills description field).

### Seller Feature 2: Product Photo Enhancement
Node endpoints:
- `POST /ai/image/enhance`
- `POST /ai/image/remove-bg`

UI changes:
- **Update:** Add/Edit product flow to include "Enhance photo" and "Remove background" actions.

### Seller Feature 3: Pricing Optimization
Node endpoints:
- `POST /ai/pricing/suggest/:productId`

UI changes:
- **Update:** Add/Edit product flow to include "Suggest price".
- **Update:** Product management views to show "AI suggested price" vs current.

### Seller Feature 4: Inventory & Trend Prediction
Node endpoints:
- `GET /ai/trends/:category`
- `POST /ai/inventory/forecast`

UI changes:
- **New screen:** `SellerTrendsScreen` (category trend insights)
- **New screen:** `InventoryForecastScreen`

### Seller Feature 5: Customer Insights
Node endpoints:
- `GET /ai/customers/insights/:sellerId`
- `GET /ai/customers/segments/:sellerId`

UI changes:
- **New screen:** `CustomerInsightsScreen`

### Seller Feature 6: Marketing Copy Generation
Node endpoints:
- `POST /ai/marketing/social-post/:productId`
- `POST /ai/marketing/ad-copy/:productId`
- `POST /ai/marketing/email-campaign`
- `POST /ai/marketing/product-tags/:productId`

UI changes:
- **New screen:** `MarketingStudioScreen` (select product → generate posts/ads/tags)

### Seller Feature 7: Return Risk Prediction
Node endpoints:
- `POST /ai/returns/predict/:orderId`
- `POST /ai/returns/analyze-product/:productId`

UI changes:
- **Update:** Seller orders screens (in `lib/features/your_shop/subfeatures/orders/`) to show "Return risk".
- **New screen:** `ReturnsInsightsScreen`

### Seller Feature 8: Competition Analysis
Node endpoints:
- `GET /ai/competition/analysis/:sellerId/:category`
- `GET /ai/competition/positioning/:sellerId`
- `GET /ai/competition/gaps/:category`
- `POST /ai/competition/strategy`

UI changes:
- **New screen:** `CompetitionInsightsScreen`

### Seller Feature 9: AI Product Photography (model generation)
Node endpoints:
- `POST /ai/image/generate-model`
- `POST /ai/image/lifestyle-scene`
- `POST /ai/image/background-variants`
- `POST /ai/image/product-angles`

UI changes:
- **New screen:** `AiProductPhotographyStudioScreen` (image generation workflow)

### Seller Feature 10: Granular Demand Forecasting
Node endpoints:
- `POST /ai/demand/forecast-color/:category`
- `POST /ai/demand/forecast-size/:category`
- `POST /ai/demand/forecast-style/:category`
- `GET  /ai/demand/seasonal/:sellerId`
- `POST /ai/demand/inventory-optimize/:sellerId`

UI changes:
- **New screen:** `DemandForecastScreen`
- **New screen:** `InventoryOptimizerScreen`

### Suggested navigation placement
- Add an "AI Insights" entry tile in `ShopDashboardScreen` that links to the screens above.

---

## Integration notes (frontend)

1. **Two HTTP clients**
   - Laravel `baseUrl = https://ojaewa-laravel.railway.app`
   - AI `baseUrl = https://ojaewa-ai.railway.app`

2. **Auth propagation**
   - Store the login token once.
   - Send as `Authorization: Bearer <token>` to both.

3. **Hydration pattern for AI responses**
   Many AI endpoints return **product IDs**.
   The app should then fetch product details from Laravel:
   - either `GET /api/products/{id}` per id, or
   - `GET /api/products` and filter in-memory (only for small lists), or
   - a future Laravel batch endpoint (recommended if IDs are many).

