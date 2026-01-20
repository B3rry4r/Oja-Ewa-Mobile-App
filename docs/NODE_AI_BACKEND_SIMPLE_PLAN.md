# Node.js AI Backend - Simple Integration Plan

## 🎯 THE SETUP

**Two completely separate backends:**
- **Laravel Backend:** `https://ojaewa-laravel.railway.app` (Your existing API - DON'T TOUCH)
- **Node.js AI Backend:** `https://ojaewa-ai-production.up.railway.app` (New service you're building)

**Authentication:** Same JWT token validates on BOTH backends (shared secret key)

---

## 🔑 AUTHENTICATION FLOW

### How it works:
```
1. User logs in → Laravel generates JWT token
2. Frontend stores token
3. Frontend sends SAME token to BOTH backends
4. Node.js validates token using SAME secret key as Laravel
```

### Node.js JWT Validation (Simple):
```javascript
const jwt = require('jsonwebtoken');

// Middleware
function authMiddleware(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  
  try {
    const user = jwt.verify(token, process.env.JWT_SECRET); // Same secret as Laravel
    req.user = user;
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

### Environment Variable (MUST match Laravel):
```env
JWT_SECRET=base64:6xc7P8fa7P2YCBPvBPIkGCSqpGFOfnitooBLAyPVXVw=
```

---

## 📊 DATA YOU CAN GET FROM LARAVEL

### When Node.js needs data, call Laravel API:

```javascript
const axios = require('axios');

const LARAVEL_API = 'https://ojaewa-laravel.railway.app/api';

// Get products
async function getProducts(filters) {
  const response = await axios.get(`${LARAVEL_API}/products`, { params: filters });
  return response.data;
}

// Get user data
async function getUser(userId, token) {
  const response = await axios.get(`${LARAVEL_API}/users/${userId}`, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  return response.data;
}

// Get reviews for a product
async function getReviews(productId) {
  const response = await axios.get(`${LARAVEL_API}/reviews/product/${productId}`);
  return response.data;
}
```

---

## 🛍️ BUYER AI FEATURES - MAPPED TO LARAVEL DATA (11 Features)

### Feature 1: Style DNA Quiz → Personalized Recommendations

**What Laravel has that you need:**
- `GET /api/products` - All marketplace products
- `GET /api/categories` - Product categories
- User purchases: `GET /api/orders` (when authenticated)
- User wishlist: `GET /api/wishlist` (when authenticated)

**Node.js Endpoints to Build:**
```javascript
POST /ai/style-quiz              // User submits quiz answers
GET  /ai/recommendations/:userId  // Get personalized product recommendations
POST /ai/outfits/generate        // Generate outfit from products
```

**How it works with LLM:**
```javascript
// 1. User takes quiz, answers saved in Node.js DB
// 2. When getting recommendations:
const quiz = await getUserQuizAnswers(userId);
const products = await getProducts(); // From Laravel

// 3. Use LLM to match
const prompt = `
User preferences: ${JSON.stringify(quiz)}
Available products: ${JSON.stringify(products.slice(0, 50))}

Recommend 10 products that match their style. Return product IDs only as JSON array.
`;

const recommendations = await callGemini(prompt);
```

---

### Feature 2: Smart Visual Search

**What Laravel has:**
- `GET /api/products` - All products with images
- Product details: name, category, style, tribe, colors, price

**Node.js Endpoints:**
```javascript
POST /ai/visual-search     // Upload image, find similar products
GET  /ai/similar/:productId // Find products similar to this one
```

**How it works with LLM (Vision model):**
```javascript
// User uploads image
const imageDescription = await callVisionLLM(uploadedImage);
// Returns: "Blue traditional Yoruba Agbada with gold embroidery"

// Match with products
const products = await getProducts();
const prompt = `
Image shows: ${imageDescription}
Products available: ${JSON.stringify(products)}

Find 10 most similar products. Return IDs only.
`;

const similar = await callLLM(prompt);
```

---

### Feature 3: Cultural AI Assistant (Chatbot)

**What Laravel has:**
- Products: `GET /api/products`
- Blogs: `GET /api/blogs`
- FAQs: `GET /api/faqs`
- Categories: `GET /api/categories`

**Node.js Endpoints:**
```javascript
POST /ai/chat              // Send message, get response
GET  /ai/chat/history/:userId // Get chat history
```

**How it works with LLM:**
```javascript
async function chatbot(userMessage, userId) {
  // Get context from Laravel
  const products = await getProducts({ limit: 20 });
  const faqs = await axios.get(`${LARAVEL_API}/faqs`);
  const blogs = await axios.get(`${LARAVEL_API}/blogs/latest`);
  
  // Build context
  const context = `
You are a Nigerian fashion expert assistant for Oja Ewa marketplace.

Available products: ${JSON.stringify(products)}
FAQs: ${JSON.stringify(faqs.data)}
Recent blogs: ${JSON.stringify(blogs.data)}

User question: ${userMessage}

Provide helpful, culturally aware advice about Nigerian fashion, styles, and our products.
`;

  return await callLLM(context);
}
```

---

### Feature 4: Smart Review Analysis

**What Laravel has:**
- `GET /api/reviews/product/{id}` - All reviews for a product

**Node.js Endpoints:**
```javascript
GET /ai/reviews/summary/:productId    // Get AI summary of reviews
GET /ai/reviews/sentiment/:productId  // Sentiment analysis
```

**How it works with LLM:**
```javascript
async function analyzeReviews(productId) {
  // Get reviews from Laravel
  const reviews = await axios.get(`${LARAVEL_API}/reviews/product/${productId}`);
  
  const prompt = `
Analyze these product reviews:
${JSON.stringify(reviews.data)}

Provide:
1. Overall sentiment (positive/negative/neutral)
2. Key points about fit
3. Key points about quality
4. Key points about color accuracy
5. 2-sentence summary

Format as JSON.
`;

  return await callLLM(prompt);
}
```

---

### Feature 5: Beauty Product Matching (Skin Tone Analysis)

**What Laravel has:**
- Beauty products: `GET /api/products?category=beauty`
- Product attributes: colors, shades, descriptions

**Node.js Endpoints:**
```javascript
POST /ai/beauty/match-foundation    // Match foundation to skin tone
POST /ai/beauty/color-season        // Determine color season
GET  /ai/beauty/recommendations/:userId // Personalized beauty recommendations
```

**How it works with LLM:**
```javascript
async function matchFoundation(skinToneDescription, userPreferences) {
  const beautyProducts = await getProducts({ category: 'beauty', subcategory: 'foundation' });
  
  const prompt = `
User description:
Skin tone: ${skinToneDescription}
Undertone: ${userPreferences.undertone || 'unknown'}
Skin type: ${userPreferences.skinType || 'normal'}
Coverage preference: ${userPreferences.coverage || 'medium'}

Available foundations:
${JSON.stringify(beautyProducts)}

Recommend top 5 foundation matches for this Nigerian customer.
Consider:
- Skin tone match
- Undertone compatibility (warm/cool/neutral)
- Nigerian climate (humid, hot)
- Skin type needs

Return product IDs with match reasoning.
`;

  return await callLLM(prompt);
}
```

---

### Feature 6: Size Prediction & Fit Analysis

**What Laravel has:**
- Reviews: `GET /api/reviews/product/{id}` - Contains fit feedback
- Orders: `GET /api/orders` - Return data
- Product sizes

**Node.js Endpoints:**
```javascript
POST /ai/sizing/predict              // Predict best size for user
GET  /ai/sizing/fit-feedback/:productId // Aggregate fit analysis
POST /ai/sizing/returns-analysis     // Analyze return patterns
```

**How it works with LLM:**
```javascript
async function predictSize(userMeasurements, productId) {
  const product = await getProduct(productId);
  const reviews = await getReviews(productId);
  const fitReviews = reviews.filter(r => 
    r.comment.toLowerCase().includes('size') || 
    r.comment.toLowerCase().includes('fit')
  );
  
  const prompt = `
Product: ${product.name} (Listed size: ${product.size})

User measurements:
- Height: ${userMeasurements.height}cm
- Weight: ${userMeasurements.weight}kg
- Body type: ${userMeasurements.bodyType}

Customer fit feedback:
${fitReviews.map(r => `"${r.comment}" - Rating: ${r.rating}/5`).join('\n')}

Analyze fit and recommend:
1. Should user order this size, size up, or size down?
2. Fit prediction (tight/perfect/loose)
3. Confidence level (0-100%)

Consider Nigerian body types and sizing standards.
`;

  return await callLLM(prompt);
}
```

---

### Feature 7: Outfit Generator

**What Laravel has:**
- User's purchased products: `GET /api/orders` (past purchases)
- User's wishlist: `GET /api/wishlist`
- All marketplace products: `GET /api/products`

**Node.js Endpoints:**
```javascript
POST /ai/outfits/generate-from-items    // Create outfits from user's items
POST /ai/outfits/complete-look          // Complete outfit for event
POST /ai/outfits/occasion               // Generate occasion-specific outfits
GET  /ai/outfits/style-board/:userId    // Get outfit inspiration board
```

**How it works with LLM:**
```javascript
async function generateOutfits(userItems, occasion, count = 5) {
  const marketplaceProducts = await getProducts({ limit: 100 });
  
  const prompt = `
User owns:
${JSON.stringify(userItems)}

Occasion: ${occasion}
Marketplace products available:
${JSON.stringify(marketplaceProducts)}

Generate ${count} complete outfit combinations.

For each outfit include:
1. Items from user's wardrobe
2. Complementary items from marketplace (include product IDs)
3. Accessories needed
4. Styling tips
5. Why this outfit works for ${occasion}

Consider Nigerian fashion sensibilities and cultural appropriateness.
`;

  return await callLLM(prompt);
}
```

---

### Feature 8: Complete Look Builder (Event/Occasion Based)

**What Laravel has:**
- All products by category: `GET /api/products?category=X`
- Product styles, tribes, occasions

**Node.js Endpoints:**
```javascript
POST /ai/looks/wedding-guest           // Wedding guest outfit
POST /ai/looks/business-casual         // Work appropriate
POST /ai/looks/traditional-event       // Traditional ceremony
POST /ai/looks/party                   // Party/nightlife
```

**How it works with LLM:**
```javascript
async function buildWeddingLook(userStyle, budget) {
  const products = await getProducts();
  
  const prompt = `
Event: Traditional Nigerian wedding (guest attire)
User style preference: ${userStyle}
Budget: ₦${budget}

Available products:
${JSON.stringify(products)}

Create a complete wedding guest outfit including:
1. Main outfit (clothing)
2. Shoes
3. Accessories (jewelry, bag, headwrap/gele if appropriate)
4. Hair/makeup suggestions
5. Cultural etiquette tips

Total cost should be within budget.
Ensure culturally appropriate and stylish.
`;

  return await callLLM(prompt);
}
```

---

### Feature 9: Sustainability Matching

**What Laravel has:**
- Products: `GET /api/products`
- Product materials (if available in description)

**Node.js Endpoints:**
```javascript
GET  /ai/sustainability/alternatives/:productId  // Find eco-friendly alternatives
GET  /ai/sustainability/score/:productId         // Rate sustainability
GET  /ai/sustainability/brands                   // List sustainable sellers
POST /ai/sustainability/analyze                  // Analyze product sustainability
```

**How it works with LLM:**
```javascript
async function findSustainableAlternatives(productId) {
  const originalProduct = await getProduct(productId);
  const similarProducts = await getProducts({ 
    category: originalProduct.category,
    style: originalProduct.style
  });
  
  const prompt = `
Original product: ${JSON.stringify(originalProduct)}

Alternative products:
${JSON.stringify(similarProducts)}

Find sustainable alternatives considering:
1. Eco-friendly materials (organic cotton, recycled fabrics, natural dyes)
2. Local Nigerian artisans (shorter supply chain)
3. Traditional handmade items (less industrial waste)
4. Durability and longevity
5. Ethical production

Rank top 5 sustainable alternatives with sustainability reasoning.
Include sustainability score (0-100) for each.
`;

  return await callLLM(prompt);
}
```

---

### Feature 10: Weather-Based Recommendations

**What Laravel has:**
- Products with materials, styles
- User location (from profile or IP)

**Node.js Endpoints:**
```javascript
GET /ai/weather/recommendations/:userId      // Weather-appropriate products
GET /ai/weather/outfit/:userId/:occasion    // Weather + occasion outfit
```

**How it works with LLM:**
```javascript
async function getWeatherRecommendations(userId, location) {
  // Get weather from external API (OpenWeather)
  const weather = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=${location}`)
    .then(r => r.json());
  
  const userStyle = await getUserStyleProfile(userId);
  const products = await getProducts();
  
  const prompt = `
Location: ${location}, Nigeria
Current weather:
- Temperature: ${weather.main.temp}°C
- Humidity: ${weather.main.humidity}%
- Conditions: ${weather.weather[0].description}
- Season: ${getCurrentSeason()}

User style preferences: ${JSON.stringify(userStyle)}

Available products:
${JSON.stringify(products.slice(0, 100))}

Recommend products appropriate for this weather:
- Breathable fabrics for heat/humidity
- Rain-appropriate if needed
- Sun protection considerations
- Comfort for Nigerian climate
- Match user's style

Return 10 product IDs with weather-appropriateness reasoning.
`;

  return await callLLM(prompt);
}
```

---

### Feature 11: Personal Trend Forecasting

**What Laravel has:**
- Order history: `GET /api/orders`
- Product trends (best sellers)
- User's style profile

**Node.js Endpoints:**
```javascript
GET /ai/trends/personal/:userId           // Personalized trend predictions
GET /ai/trends/upcoming/:category         // Upcoming trends by category
POST /ai/trends/analyze                   // Analyze current trends
```

**How it works with LLM:**
```javascript
async function personalTrendForecast(userId) {
  const userOrders = await getUserOrders(userId);
  const userStyle = await getUserStyleProfile(userId);
  const recentTrends = await getProducts({ sortBy: 'trending', limit: 50 });
  
  const prompt = `
User's purchase history:
${JSON.stringify(userOrders)}

User's style profile:
${JSON.stringify(userStyle)}

Current trending products:
${JSON.stringify(recentTrends)}

Predict upcoming trends for THIS user specifically:
1. What styles will be popular next season
2. Which trends align with their taste
3. Products they should consider now
4. Nigerian fashion calendar events coming up

Consider:
- Their historical preferences
- Seasonal patterns in Nigeria
- Cultural events (Owambe season, festivals)
- Their budget range

Return personalized trend predictions with product recommendations.
`;

  return await callLLM(prompt);
}
```

---

## 🏪 SELLER AI FEATURES - MAPPED TO LARAVEL DATA (10 Features)

### Feature 1: Smart Product Descriptions

**What Laravel has:**
- Product data: name, category, style, tribe, gender, materials

**Node.js Endpoints:**
```javascript
POST /ai/product/description  // Generate product description
```

**How it works with LLM:**
```javascript
async function generateDescription(productData) {
  const prompt = `
Generate a compelling product description for:
Name: ${productData.name}
Category: ${productData.category}
Style: ${productData.style}
Tribe: ${productData.tribe}
Gender: ${productData.gender}
Price: ₦${productData.price}

Write 3 paragraphs:
1. Product overview
2. Cultural significance
3. Styling suggestions

Be SEO-friendly, use Nigerian fashion terms.
`;

  return await callLLM(prompt);
}
```

---

### Feature 2: Product Photo Enhancement

**What Laravel has:**
- Product images (URLs from product data)

**Node.js Endpoints:**
```javascript
POST /ai/image/enhance         // Enhance image quality
POST /ai/image/remove-bg       // Remove background
```

**How it works:**
```javascript
const sharp = require('sharp');

async function enhanceImage(imageUrl) {
  // Download image
  const image = await downloadImage(imageUrl);
  
  // Enhance using sharp (no LLM needed)
  const enhanced = await sharp(image)
    .normalize()
    .sharpen()
    .modulate({ brightness: 1.1, saturation: 1.1 })
    .toBuffer();
    
  return enhanced;
}

// For background removal, use external API like remove.bg
```

---

### Feature 3: Pricing Optimization

**What Laravel has:**
- All products with prices: `GET /api/products`
- Order history: `GET /api/orders`
- Product categories

**Node.js Endpoints:**
```javascript
POST /ai/pricing/suggest/:productId   // Get price recommendation
```

**How it works with LLM:**
```javascript
async function suggestPrice(productData) {
  // Get similar products
  const similarProducts = await getProducts({
    category: productData.category,
    style: productData.style
  });
  
  const prompt = `
Analyze pricing for this product:
${JSON.stringify(productData)}

Similar products in marketplace:
${JSON.stringify(similarProducts)}

Suggest optimal price in Naira. Consider:
- Market average
- Product quality indicators
- Competition
- Nigerian market conditions

Provide price and reasoning.
`;

  return await callLLM(prompt);
}
```

---

### Feature 4: Inventory & Trend Prediction

**What Laravel has:**
- Order history: `GET /api/orders`
- Product sales data
- Categories and styles

**Node.js Endpoints:**
```javascript
GET /ai/trends/:category        // Current trends
POST /ai/inventory/forecast     // Predict demand
```

**How it works with LLM:**
```javascript
async function predictTrends(category) {
  // Get recent orders
  const orders = await getOrders({ recent: true, category });
  const products = await getProducts({ category });
  
  const prompt = `
Analyze sales data for ${category}:
Recent orders: ${JSON.stringify(orders)}
Available products: ${JSON.stringify(products)}

Identify:
1. Top 5 trending styles
2. Most popular colors
3. Best-selling sizes
4. Emerging trends

Consider Nigerian fashion seasons and events.
`;

  return await callLLM(prompt);
}
```

---

### Feature 5: Customer Insights for Sellers

**What Laravel has:**
- Seller's orders: `GET /api/orders` (filtered by seller)
- Customer data from orders
- Reviews on seller's products

**Node.js Endpoints:**
```javascript
GET /ai/customers/insights/:sellerId   // Customer behavior analysis
GET /ai/customers/segments/:sellerId   // Customer segments
```

**How it works with LLM:**
```javascript
async function analyzeCustomers(sellerId) {
  // Get seller's orders and customers
  const orders = await getSellerOrders(sellerId);
  const reviews = await getSellerReviews(sellerId);
  
  const prompt = `
Analyze customer data for seller:
Orders: ${JSON.stringify(orders)}
Reviews: ${JSON.stringify(reviews)}

Provide:
1. Customer segments (VIP, Regular, One-time)
2. Purchase patterns
3. Popular products
4. Repeat purchase rate
5. Customer satisfaction insights

Format as JSON with actionable recommendations.
`;

  return await callLLM(prompt);
}
```

---

### Feature 6: Marketing Copy Generation

**What Laravel has:**
- Product data: `GET /api/products/{id}`
- Seller profile information

**Node.js Endpoints:**
```javascript
POST /ai/marketing/social-post/:productId    // Generate social media post
POST /ai/marketing/ad-copy/:productId        // Generate ad copy
POST /ai/marketing/email-campaign           // Generate email marketing
POST /ai/marketing/product-tags/:productId  // Generate SEO tags
```

**How it works with LLM:**
```javascript
async function generateSocialPost(productId, platform) {
  const product = await getProduct(productId);
  
  const prompt = `
Product: ${JSON.stringify(product)}
Platform: ${platform} (Instagram/Facebook/Twitter/TikTok)

Generate engaging social media post:
- Catchy caption (2-3 sentences)
- Relevant hashtags (#NigerianFashion #AfricanStyle #TraditionalWear etc)
- Call to action
- Emojis (if appropriate for platform)

Keep it authentic, culturally relevant, and engaging for Nigerian audience.
`;

  return await callLLM(prompt);
}

async function generateAdCopy(productId, adType) {
  const product = await getProduct(productId);
  
  const prompt = `
Product: ${JSON.stringify(product)}
Ad Type: ${adType} (Google Ads/Facebook Ads/Instagram Story)

Generate compelling ad copy:
- Headline (max 30 characters)
- Description (max 90 characters)
- CTA (Call to action)
- Benefits highlight
- Urgency/scarcity element if appropriate

Focus on Nigerian market appeal and cultural relevance.
`;

  return await callLLM(prompt);
}
```

---

### Feature 7: Return Risk Prediction

**What Laravel has:**
- Order data: `GET /api/orders`
- Product reviews: `GET /api/reviews/product/{id}`
- Return history (if tracked in orders)

**Node.js Endpoints:**
```javascript
POST /ai/returns/predict/:orderId       // Predict return risk for order
GET  /ai/returns/high-risk/:sellerId    // List high-risk orders
POST /ai/returns/analyze-product/:productId // Product return analysis
```

**How it works with LLM:**
```javascript
async function predictReturnRisk(orderId) {
  const order = await getOrder(orderId);
  const product = await getProduct(order.product_id);
  const reviews = await getReviews(order.product_id);
  
  // Get historical return data for similar products
  const similarOrders = await getOrders({ 
    product_category: product.category,
    status: 'returned'
  });
  
  const prompt = `
Order details:
Product: ${JSON.stringify(product)}
Customer location: ${order.shipping_address}
Order value: ₦${order.total_price}
Shipping distance: ${order.distance}km

Product reviews:
${reviews.slice(0, 10).map(r => `Rating: ${r.rating}/5 - "${r.comment}"`).join('\n')}

Historical returns for similar products:
${similarOrders.length} out of ${similarOrders.length * 3} similar orders returned

Predict return risk:
1. Return probability (0-100%)
2. Main risk factors
3. Recommended actions to prevent return

Consider:
- Size/fit issues mentioned in reviews
- Color accuracy concerns
- Quality complaints
- Shipping distance (longer = higher risk)
- Product category return patterns
`;

  return await callLLM(prompt);
}
```

---

### Feature 8: Competition Analysis

**What Laravel has:**
- All products: `GET /api/products`
- Seller's products: `GET /api/products?seller_id=X`
- Sales data: `GET /api/orders`

**Node.js Endpoints:**
```javascript
GET /ai/competition/analysis/:sellerId/:category  // Analyze competition
GET /ai/competition/positioning/:sellerId         // Market positioning
GET /ai/competition/gaps/:category                // Find market gaps
POST /ai/competition/strategy                     // Competitive strategy
```

**How it works with LLM:**
```javascript
async function analyzeCompetition(sellerId, category) {
  const sellerProducts = await getSellerProducts(sellerId);
  const allCategoryProducts = await getProducts({ category });
  const topSellers = await getProducts({ category, sortBy: 'sales', limit: 20 });
  
  const prompt = `
Your products:
${JSON.stringify(sellerProducts)}

Category: ${category}
All competitor products (${allCategoryProducts.length} total):
${JSON.stringify(allCategoryProducts.slice(0, 50))}

Top sellers in category:
${JSON.stringify(topSellers)}

Provide competitive analysis:
1. Your price positioning (cheap/mid-range/premium)
2. Style gaps in the market (underserved niches)
3. Your unique selling points vs competitors
4. Areas for improvement
5. Recommended product additions
6. Pricing optimization opportunities

Focus on actionable insights for Nigerian fashion market.
`;

  return await callLLM(prompt);
}
```

---

### Feature 9: AI Product Photography (Model Generation)

**What Laravel has:**
- Product images: URLs from product data

**Node.js Endpoints:**
```javascript
POST /ai/image/generate-model           // Generate product on AI model
POST /ai/image/lifestyle-scene          // Place product in lifestyle scene
POST /ai/image/background-variants      // Generate multiple backgrounds
POST /ai/image/product-angles           // Generate multiple product views
```

**How it works with Image Generation API:**
```javascript
const OpenAI = require('openai');
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

async function generateModelImage(productImage, style) {
  // Option 1: Using DALL-E 3
  const response = await openai.images.generate({
    model: "dall-e-3",
    prompt: `Professional fashion photography: ${style} Nigerian model wearing ${productDescription}. 
    Studio lighting, elegant pose, fashion magazine quality, high-end, sophisticated.
    Background: neutral studio, fashion runway, or elegant setting.`,
    size: "1024x1024",
    quality: "hd",
    n: 1,
  });
  
  return response.data[0].url;
}

// Alternative: Use Stable Diffusion via Replicate (cheaper)
async function generateWithStableDiffusion(productDescription) {
  const replicate = new Replicate({
    auth: process.env.REPLICATE_API_TOKEN,
  });
  
  const output = await replicate.run(
    "stability-ai/sdxl:latest",
    {
      input: {
        prompt: `Professional product photography, ${productDescription}, 
        elegant Nigerian model, studio lighting, fashion magazine quality`,
        negative_prompt: "blurry, distorted, low quality"
      }
    }
  );
  
  return output;
}
```

---

### Feature 10: Granular Demand Forecasting

**What Laravel has:**
- Detailed order history: `GET /api/orders`
- Product attributes: colors, sizes, styles
- Seasonal sales patterns

**Node.js Endpoints:**
```javascript
POST /ai/demand/forecast-color/:category      // Predict popular colors
POST /ai/demand/forecast-size/:category       // Predict size demand
POST /ai/demand/forecast-style/:category      // Predict style trends
GET  /ai/demand/seasonal/:sellerId            // Seasonal demand forecast
POST /ai/demand/inventory-optimize/:sellerId  // Optimize inventory mix
```

**How it works with LLM:**
```javascript
async function forecastColorDemand(category, season) {
  const historicalOrders = await getOrders({ 
    category, 
    dateRange: 'last_year' 
  });
  
  // Analyze which colors sold in past seasons
  const colorSales = {};
  historicalOrders.forEach(order => {
    const color = order.product.color;
    colorSales[color] = (colorSales[color] || 0) + order.quantity;
  });
  
  const currentProducts = await getProducts({ category });
  
  const prompt = `
Category: ${category}
Current season: ${season}
Nigerian market context

Historical color sales (last year):
${JSON.stringify(colorSales)}

Currently available colors:
${currentProducts.map(p => p.color).filter((v, i, a) => a.indexOf(v) === i).join(', ')}

Forecast color demand for next 3 months:
1. Top 5 colors that will sell best
2. Colors to stock heavily
3. Colors to phase out
4. New color opportunities

Consider:
- Seasonal factors in Nigeria
- Cultural events and festivals
- Current fashion trends
- Regional preferences
`;

  return await callLLM(prompt);
}

async function forecastSizeDemand(sellerId, productId) {
  const product = await getProduct(productId);
  const orderHistory = await getOrders({ product_id: productId });
  
  const sizeSales = {};
  orderHistory.forEach(order => {
    const size = order.product.size;
    sizeSales[size] = (sizeSales[size] || 0) + 1;
  });
  
  const prompt = `
Product: ${product.name}
Historical size sales:
${JSON.stringify(sizeSales)}

Forecast size demand for next inventory order:
1. How many of each size to stock
2. Sizes with highest demand
3. Sizes with low demand (consider discontinuing)
4. Total units recommended

Consider Nigerian body type distributions and past sales patterns.
`;

  return await callLLM(prompt);
}
```

---

## 🔧 NODE.JS SETUP (Simple)

### Tech Stack:
```json
{
  "framework": "Express.js",
  "auth": "jsonwebtoken",
  "llm": "@google-cloud/vertexai" (Gemini models),
  "http": "axios",
  "image": "sharp",
  "database": "pg" (Same PostgreSQL as Laravel),
  "cache": "redis" (Optional - for recommendations cache)
}
```

### Shared Database Strategy:
**Use the SAME PostgreSQL database as Laravel!**

```javascript
// Node.js connects to same Railway PostgreSQL
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL, // Same as Laravel's DB
  ssl: { rejectUnauthorized: false }
});

// Create separate schema for AI service
await pool.query('CREATE SCHEMA IF NOT EXISTS ai_service');

// AI-specific tables in ai_service schema
await pool.query(`
  CREATE TABLE IF NOT EXISTS ai_service.style_profiles (
    user_id INTEGER PRIMARY KEY REFERENCES public.users(id),
    quiz_answers JSONB,
    style_preferences JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
  );

  CREATE TABLE IF NOT EXISTS ai_service.chat_history (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES public.users(id),
    message TEXT,
    response TEXT,
    created_at TIMESTAMP DEFAULT NOW()
  );

  CREATE TABLE IF NOT EXISTS ai_service.recommendations_cache (
    user_id INTEGER REFERENCES public.users(id),
    recommendation_type VARCHAR(50),
    recommendations JSONB,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
  );
);
```

**Benefits:**
- ✅ No separate database needed
- ✅ Can join with Laravel tables directly
- ✅ Simpler deployment (one database on Railway)
- ✅ Easier data access (no cross-service calls for some data)
- ✅ Lower costs (one database instead of two)

### Project Structure:
```
ojaewa-ai/
├── server.js
├── config/
│   ├── database.js    // PostgreSQL connection
│   └── gemini.js      // Vertex AI Gemini setup
├── routes/
│   ├── buyer.js       // Buyer AI features
│   └── seller.js      // Seller AI features
├── controllers/
│   ├── recommendations.js
│   ├── chat.js
│   ├── reviews.js
│   ├── pricing.js
│   └── trends.js
├── services/
│   ├── gemini.js      // Gemini AI calls
│   ├── database.js    // Direct DB queries
│   └── cache.js       // Redis caching (optional)
├── models/
│   ├── styleProfile.js
│   ├── chatHistory.js
│   └── recommendationCache.js
└── middleware/
    └── auth.js        // JWT validation
```

---

## 🚀 DEPLOYMENT (Platform Agnostic)

### 1. Get Database Connection from Railway

**Go to Railway Dashboard:**
1. Click on your PostgreSQL database service
2. Go to **"Connect"** tab
3. Copy the connection details:

```env
# PostgreSQL Connection (from Railway)
DATABASE_URL=postgresql://user:password@host:5432/database
# OR individual components:
DB_HOST=containers-us-west-xxx.railway.app
DB_PORT=5432
DB_DATABASE=railway
DB_USERNAME=postgres
DB_PASSWORD=your_password
```

### 2. Environment Variables (Any Platform)

Create `.env` file for local development:
```env
# Server
PORT=3000
NODE_ENV=development

# Authentication (Must match Laravel)
JWT_SECRET=base64:6xc7P8fa7P2YCBPvBPIkGCSqpGFOfnitooBLAyPVXVw=

# Database (From Railway - copy exact connection string)
DATABASE_URL=postgresql://postgres:password@host.railway.app:5432/railway

# Google Cloud Vertex AI (Gemini)
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
GOOGLE_APPLICATION_CREDENTIALS=./config/service-account-key.json
VERTEX_AI_LOCATION=us-central1

# Optional - Laravel API URL (if you need to call it)
LARAVEL_API_URL=https://your-laravel-app.railway.app/api

# Optional - Redis
REDIS_URL=redis://default:password@host:6379
```

### 3. Local Development Setup

```bash
# 1. Clone your Node.js AI service repo
git clone <your-repo>
cd ojaewa-ai-service

# 2. Install dependencies
npm install

# 3. Copy environment file
cp .env.example .env
# Edit .env with your Railway database connection

# 4. Initialize AI schema in database
npm run migrate  # Creates ai_service schema and tables

# 5. Start development server
npm run dev

# Server runs on http://localhost:3000
```

### 4. Test Database Connection

```bash
# Test PostgreSQL connection
node scripts/test-db-connection.js

# Should output:
# ✅ Connected to PostgreSQL
# ✅ Laravel tables accessible (users, products, orders)
# ✅ AI schema exists (ai_service)
```

### 5. Deploy Anywhere

The Node.js service can be deployed to:
- **Vercel** (with PostgreSQL connection)
- **Heroku** (easy PostgreSQL integration)
- **DigitalOcean App Platform**
- **AWS Elastic Beanstalk**
- **Google Cloud Run**
- **Your own VPS** (Ubuntu/Docker)
- **Railway** (if you choose to)

**Key requirements:**
- Can connect to external PostgreSQL (Railway database)
- Supports Node.js 18+
- Can set environment variables
- Can upload Google service account key file

### 6. Production Environment Variables

For production deployment (any platform):
```env
NODE_ENV=production
PORT=3000
DATABASE_URL=<Railway PostgreSQL connection string>
JWT_SECRET=<same as Laravel>
GOOGLE_CLOUD_PROJECT=<your project>
GOOGLE_APPLICATION_CREDENTIALS=<path to service account key>
```

---

## 💡 LLM USAGE - KEEP IT MODERATE

### Tips to minimize costs:
1. **Cache everything** - Store recommendations for 30 minutes
2. **Batch requests** - Process multiple items together
3. **Use smaller context** - Only send relevant data (top 50 products, not all)
4. **Smart prompts** - Ask for JSON output with IDs only
5. **Rate limiting** - Max 10 AI requests per user per hour

### Example caching:
```javascript
const cache = require('redis').createClient();

async function getCachedRecommendations(userId) {
  const cached = await cache.get(`recs:${userId}`);
  if (cached) return JSON.parse(cached);
  
  const recommendations = await generateRecommendations(userId);
  await cache.setex(`recs:${userId}`, 1800, JSON.stringify(recommendations)); // 30 min
  return recommendations;
}
```

---

## 📝 INTEGRATION CHECKLIST

### For Each Feature:
- [ ] Identify what Laravel data you need
- [ ] Create Node.js endpoint
- [ ] Call Laravel API to get data
- [ ] Build LLM prompt with context
- [ ] Call LLM, get response
- [ ] Cache result if needed
- [ ] Return to frontend

### Frontend calls:
```javascript
// Option 1: Frontend calls both APIs
const [laravelData, aiData] = await Promise.all([
  fetch('https://ojaewa-laravel.railway.app/api/products'),
  fetch('https://ojaewa-ai-production.up.railway.app/ai/recommendations/123', {
    headers: { 'Authorization': `Bearer ${token}` }
  })
]);

// Option 2: AI service calls Laravel internally
const aiData = await fetch('https://ojaewa-ai-production.up.railway.app/ai/recommendations/123', {
  headers: { 'Authorization': `Bearer ${token}` }
});
// Node.js handles calling Laravel inside
```

---

## 🎯 START HERE

### Phase 1 - Core Features (Week 1-2):
**Buyer:**
1. **Cultural AI Chatbot** - Easiest, high value
2. **Style DNA Quiz + Recommendations** - Core personalization
3. **Smart Review Analysis** - Immediate value

**Seller:**
4. **Product Description Generator** - Quick win
5. **Pricing Optimization** - High ROI

### Phase 2 - Enhanced Features (Week 3-4):
**Buyer:**
6. **Outfit Generator** - High engagement
7. **Size Prediction** - Reduces returns
8. **Beauty Product Matching** - If you have beauty products

**Seller:**
9. **Marketing Copy Generator** - Saves time
10. **Return Risk Prediction** - Saves money

### Phase 3 - Advanced Features (Week 5-6):
**Buyer:**
11. **Visual Search** - More complex
12. **Weather Recommendations** - Nice-to-have
13. **Sustainability Matching** - Differentiator

**Seller:**
14. **Competition Analysis** - Strategic value
15. **Demand Forecasting** - Inventory optimization

### Phase 4 - Premium Features (Week 7+):
**Buyer:**
16. **Complete Look Builder** - Premium experience
17. **Personal Trend Forecasting** - Advanced

**Seller:**
18. **AI Model Photography** - Most complex, premium feature
19. **Customer Segmentation** - Advanced analytics

---

**This is it. Simple. Node.js uses SAME database as Laravel, calls Gemini for AI, returns results. No complicated architecture.**

---

## 📚 Additional Documentation

### For Complete Gemini Implementation:
See **`GEMINI_IMPLEMENTATION_GUIDE.md`** for:
- ✅ Full Gemini setup with Vertex AI
- ✅ Database service with direct PostgreSQL queries
- ✅ Complete code examples for all 21 features
- ✅ Cost optimization strategies (Gemini Flash vs Pro)
- ✅ Security best practices
- ✅ Deployment checklist

### Quick Summary of Changes:
1. **Database:** Use same PostgreSQL as Laravel (no separate MongoDB)
2. **AI Service:** Use Google Gemini via Vertex AI (not OpenAI)
3. **Data Access:** Direct database queries + optional Laravel API calls
4. **Caching:** Optional Redis for recommendations cache
5. **Cost:** ~80% cheaper than OpenAI with Gemini Flash model