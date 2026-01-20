# Ojaewa AI Features Implementation Guide

> **Branch:** `feature/ai-integration`  
> **Last Updated:** January 2026

## Overview

This document describes the implementation of 4 major AI features integrated into the Ojaewa mobile app. All features connect to a separate Node.js AI backend API.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Feature 1: Smart Product Descriptions](#feature-1-smart-product-descriptions)
3. [Feature 2: Cultural Context AI Chat](#feature-2-cultural-context-ai-chat)
4. [Feature 3: Client Relationship & Personalization](#feature-3-client-relationship--personalization)
5. [Feature 4: Smart Inventory & Trend Prediction](#feature-4-smart-inventory--trend-prediction)
6. [Configuration](#configuration)
7. [API Endpoints Reference](#api-endpoints-reference)
8. [File Structure](#file-structure)
9. [Integration Points](#integration-points)

---

## Architecture Overview

### Tech Stack
- **Frontend:** Flutter with Riverpod state management
- **AI Backend:** Separate Node.js API (configurable URL)
- **Main Backend:** Laravel API (existing)

### Network Layer
```
lib/core/network/dio_clients.dart
├── laravelDioProvider  → Main backend API
└── aiDioProvider       → AI backend API
```

### AI Feature Structure
```
lib/features/ai/
├── domain/
│   └── ai_models.dart          # All data models
├── data/
│   ├── ai_api.dart             # API service
│   └── ai_repository.dart      # Repository layer
├── presentation/
│   ├── controllers/            # State management
│   ├── screens/                # UI screens
│   └── widgets/                # Reusable widgets
```

---

## Feature 1: Smart Product Descriptions

### Purpose
Generates AI-powered, culturally-rich product descriptions for sellers using Nigerian fashion terminology.

### User Flow
```
Add/Edit Product Screen
    ↓
Fill in: Name, Style, Tribe, Price
    ↓
Tap "AI Description Generator" (expandable)
    ↓
Tap "Generate Description"
    ↓
AI-generated description fills the description field
    ↓
Seller can edit before saving
```

### Entry Points
| Location | Component |
|----------|-----------|
| Add/Edit Product Screen | `AiDescriptionGenerator` widget |

### Files
- **Widget:** `lib/features/ai/presentation/widgets/ai_description_generator.dart`
- **Controller:** `lib/features/ai/presentation/controllers/ai_description_controller.dart`

### API Endpoint
```
POST /ai/seller/product/description
```

**Request Body:**
```json
{
  "name": "Elegant Agbada Set",
  "style": "Traditional",
  "tribe": "Yoruba",
  "gender": "male",
  "price": 75000,
  "materials": "Aso-Oke",
  "occasion": "Wedding"
}
```

**Response:**
```json
{
  "description": "Step into elegance with this exquisite Yoruba Agbada set...",
  "title": "Premium Yoruba Agbada Set",
  "tags": ["agbada", "yoruba", "wedding", "traditional"],
  "seoKeywords": ["nigerian wedding attire", "agbada for sale"]
}
```

### Usage Example
```dart
final description = await ref
    .read(aiDescriptionControllerProvider.notifier)
    .generateDescription(
      name: 'Elegant Agbada',
      style: 'Traditional',
      tribe: 'Yoruba',
      gender: 'male',
      price: 75000,
    );

if (description != null) {
  _descriptionController.text = description.description;
}
```

---

## Feature 2: Cultural Context AI Chat

### Purpose
AI assistant with deep knowledge of Nigerian fashion culture, helping buyers with styling advice, cultural context, and product recommendations.

### User Flow
```
Home Screen (FAB) / Account Menu / Product Detail / FAQ
    ↓
AI Chat Screen
    ↓
Type question or tap suggested question
    ↓
AI responds with culturally-aware advice
    ↓
Optional: View suggested products
```

### Entry Points
| Location | UI Element |
|----------|------------|
| Home Screen | Floating Action Button "Ask AI" |
| Account Screen | AI Features → "Cultural AI Assistant" |
| Product Detail Screen | "Ask AI about this item" button |
| FAQ Screen | AI fallback when no FAQs found |
| FAQ Screen | "Can't find what you're looking for?" button |

### Files
- **Screen:** `lib/features/ai/presentation/screens/ai_chat_screen.dart`
- **Controller:** `lib/features/ai/presentation/controllers/ai_chat_controller.dart`

### API Endpoints
```
POST /ai/buyer/chat           # Send message
GET  /ai/buyer/chat/history/:userId  # Get chat history
```

**Request Body:**
```json
{
  "message": "What should I wear to a Yoruba wedding?",
  "userId": "123"
}
```

**Response:**
```json
{
  "response": "For a Yoruba wedding, the traditional attire depends on your role...",
  "suggestions": [
    "What colors are appropriate?",
    "Tell me about Aso-Ebi"
  ],
  "products": [
    {
      "id": "456",
      "name": "Aso-Oke Agbada Set",
      "price": 85000,
      "imageUrl": "https://..."
    }
  ]
}
```

### Default Suggested Questions
```dart
final defaultChatSuggestions = [
  'What traditional Nigerian outfit should I wear to a wedding?',
  'Tell me about Yoruba fashion styles',
  'What colors are trending for Ankara designs?',
  'How do I style an Agbada for a formal event?',
  'What is the significance of Aso-Oke?',
];
```

---

## Feature 3: Client Relationship & Personalization

### Purpose
Captures user style preferences through a quiz and provides personalized product recommendations.

### User Flow
```
Account → "Your Style Profile" / Home → "For You"
    ↓
Style DNA Quiz (7 questions)
    ↓
Submit answers
    ↓
Style profile created
    ↓
View personalized recommendations with match scores
```

### Entry Points
| Location | UI Element |
|----------|------------|
| Home Screen | "For You" banner (logged-in users) |
| Account Screen | AI Features → "Your Style Profile" |
| Account Screen | AI Features → "For You" |

### Files
- **Quiz Screen:** `lib/features/ai/presentation/screens/style_dna_quiz_screen.dart`
- **Recommendations Screen:** `lib/features/ai/presentation/screens/personalized_recommendations_screen.dart`
- **Controller:** `lib/features/ai/presentation/controllers/ai_personalization_controller.dart`

### Style Quiz Questions
1. What style resonates with you most?
2. Which cultural styles interest you?
3. What occasions do you usually dress for?
4. What colors do you gravitate towards?
5. What fabrics do you prefer?
6. What's your fashion goal?
7. What's your typical budget for an outfit?

### API Endpoints
```
POST /ai/buyer/style-quiz              # Submit quiz
GET  /ai/buyer/recommendations/:userId # Get recommendations
GET  /ai/buyer/style-profile/:userId   # Get style profile
```

**Quiz Request:**
```json
{
  "userId": "123",
  "answers": [
    {"questionId": "style_preference", "answer": "Traditional"},
    {"questionId": "tribe_interest", "answer": "Yoruba"},
    ...
  ]
}
```

**Recommendations Response:**
```json
{
  "recommendations": [
    {
      "id": "789",
      "name": "Ankara Maxi Dress",
      "price": 35000,
      "matchScore": 0.92,
      "reason": "Matches your love for bold prints",
      "imageUrl": "https://..."
    }
  ]
}
```

---

## Feature 4: Smart Inventory & Trend Prediction

### Purpose
Provides sellers with AI-powered analytics including trend predictions, inventory forecasting, and performance insights.

### User Flow
```
Shop Dashboard → "AI Analytics" button
    ↓
Analytics Dashboard with 3 tabs:
├── Trends (styles, colors, cultures)
├── Inventory (forecasts, restock alerts)
└── Performance (sales, market position)
```

### Entry Points
| Location | UI Element |
|----------|------------|
| Shop Dashboard | "AI Analytics" gradient button |
| Account Screen | AI Features → links to relevant screens |

### Files
- **Screen:** `lib/features/ai/presentation/screens/seller_analytics_screen.dart`
- **Controller:** `lib/features/ai/presentation/controllers/ai_analytics_controller.dart`

### API Endpoints
```
GET  /ai/seller/trends/:category           # Category trends
POST /ai/seller/inventory/forecast         # Inventory forecast
GET  /ai/seller/trends/seller/:sellerId    # Seller performance
POST /ai/seller/demand/forecast-color/:cat # Color predictions
POST /ai/seller/demand/forecast-size/:cat  # Size predictions
```

### Dashboard Tabs

**Trends Tab:**
- Trending Styles (ranked list with growth %)
- Trending Colors
- Popular Cultures/Tribes
- Color Forecast
- Size Demand Predictions

**Inventory Tab:**
- Product-level forecasts
- Current stock vs predicted demand
- Recommended stock levels
- Restock alerts

**Performance Tab:**
- Total Sales
- Average Rating
- Market Position (percentile)
- Top Products
- AI Suggestions

---

## Configuration

### AI API URL

Configure in `lib/core/constants/app_urls.dart`:

```dart
static String get aiBaseUrl {
  if (_aiOverride.isNotEmpty) return _aiOverride;

  switch (AppEnv.current) {
    case AppEnvironment.dev:
      return 'https://your-dev-ai-api.com';
    case AppEnvironment.staging:
      return 'https://your-staging-ai-api.com';
    case AppEnvironment.prod:
      return 'https://your-prod-ai-api.com';
  }
}
```

**Or via dart-define:**
```bash
flutter run --dart-define=AI_BASE_URL=https://your-ai-api.com
```

### Authentication

The AI API uses the same Sanctum Bearer token as the main Laravel API. The `AuthTokenInterceptor` automatically attaches the token to all AI requests.

---

## API Endpoints Reference

### Buyer Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/ai/buyer/chat` | Send chat message |
| GET | `/ai/buyer/chat/history/:userId` | Get chat history |
| POST | `/ai/buyer/style-quiz` | Submit style quiz |
| GET | `/ai/buyer/recommendations/:userId` | Get recommendations |
| GET | `/ai/buyer/style-profile/:userId` | Get style profile |
| GET | `/ai/buyer/trends/personal/:userId` | Personal trends |

### Seller Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/ai/seller/product/description` | Generate description |
| POST | `/ai/seller/product/description/batch` | Batch descriptions |
| GET | `/ai/seller/trends/:category` | Category trends |
| POST | `/ai/seller/inventory/forecast` | Inventory forecast |
| GET | `/ai/seller/trends/seller/:sellerId` | Seller performance |
| POST | `/ai/seller/demand/forecast-color/:cat` | Color predictions |
| POST | `/ai/seller/demand/forecast-size/:cat` | Size predictions |
| GET | `/ai/seller/customer/profile/:customerId` | Customer insights |

---

## File Structure

```
lib/features/ai/
├── domain/
│   └── ai_models.dart
│       ├── AiChatMessage
│       ├── AiSuggestedProduct
│       ├── AiProductDescription
│       ├── ProductDescriptionRequest
│       ├── StyleDnaProfile
│       ├── StyleQuizAnswer
│       ├── PersonalizedRecommendation
│       ├── TrendData
│       ├── TrendItem
│       ├── InventoryForecast
│       ├── DemandPrediction
│       ├── DemandPredictionItem
│       ├── SellerPerformance
│       ├── TopProduct
│       └── MarketComparison
│
├── data/
│   ├── ai_api.dart              # Raw API calls
│   └── ai_repository.dart       # Repository with providers
│
├── presentation/
│   ├── controllers/
│   │   ├── ai_description_controller.dart
│   │   ├── ai_chat_controller.dart
│   │   ├── ai_personalization_controller.dart
│   │   └── ai_analytics_controller.dart
│   │
│   ├── screens/
│   │   ├── ai_chat_screen.dart
│   │   ├── style_dna_quiz_screen.dart
│   │   ├── personalized_recommendations_screen.dart
│   │   └── seller_analytics_screen.dart
│   │
│   └── widgets/
│       └── ai_description_generator.dart
```

---

## Integration Points

### Routes Added (`lib/app/router/app_router.dart`)
```dart
static const aiChat = '/ai-chat';
static const styleDnaQuiz = '/style-dna-quiz';
static const personalizedRecommendations = '/personalized-recommendations';
static const sellerAnalytics = '/seller-analytics';
```

### Modified Files
| File | Changes |
|------|---------|
| `lib/features/home/presentation/home_screen.dart` | FAB + For You section |
| `lib/features/account/presentation/account.dart` | AI Features menu section |
| `lib/features/product_detail/presentation/product_detail_screen.dart` | Ask AI button |
| `lib/features/your_shop/presentation/shop_dashboard.dart` | AI Analytics button |
| `lib/features/your_shop/subfeatures/add_edit_product/add_edit_product.dart` | AI Description Generator |
| `lib/features/account/subfeatures/faq/faq.dart` | AI fallback |

---

## Error Handling

All AI controllers use AsyncNotifier with graceful error handling:

```dart
try {
  final result = await repository.someAiCall();
  state = AsyncData(state.value!.copyWith(data: result));
} catch (e) {
  state = AsyncData(state.value!.copyWith(
    error: 'Failed to load: ${e.toString()}',
  ));
}
```

### Offline Behavior
- AI features degrade gracefully when offline
- Error messages guide users to try again later
- Core app functionality remains unaffected

---

## Testing Checklist

### Smart Product Descriptions
- [ ] Generator widget appears in Add Product screen
- [ ] Validation prevents generation without required fields
- [ ] Generated description populates text field
- [ ] User can edit generated description

### Cultural AI Chat
- [ ] FAB visible on home screen
- [ ] Chat initializes with welcome screen
- [ ] Suggested questions work
- [ ] Messages send and receive correctly
- [ ] Chat history loads for returning users

### Personalization
- [ ] Quiz progresses through all questions
- [ ] Quiz can be submitted
- [ ] Profile created after quiz
- [ ] Recommendations load with match scores
- [ ] Category filters work

### Seller Analytics
- [ ] Dashboard loads with 3 tabs
- [ ] Category selector changes data
- [ ] Trends display with rankings
- [ ] Inventory forecasts show restock alerts
- [ ] Performance metrics display correctly

---

## Future Enhancements

1. **Visual Search** - Upload image to find similar products
2. **Beauty Analysis** - Color season matching for beauty products
3. **Outfit Generator** - AI-powered look builder
4. **Weather-based Recommendations** - Location-aware suggestions
5. **Advanced Demand Forecasting** - ML-powered predictions

---

## Support

For issues with AI features, check:
1. AI API URL is configured correctly
2. User is authenticated (token present)
3. Network connectivity
4. AI backend service is running

Contact the development team for backend-related issues.
