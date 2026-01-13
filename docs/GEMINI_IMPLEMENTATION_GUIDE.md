# Google Gemini (Vertex AI) Implementation Guide

## 🚀 Setup Gemini in Node.js

### 1. Install Dependencies
```bash
npm install @google-cloud/vertexai
npm install pg axios jsonwebtoken express sharp
```

### 2. Google Cloud Setup

#### Create Service Account:
```bash
# 1. Go to Google Cloud Console: https://console.cloud.google.com
# 2. Create new project or select existing
# 3. Enable Vertex AI API
# 4. Go to IAM & Admin → Service Accounts
# 5. Create Service Account with roles:
#    - Vertex AI User
#    - Vertex AI Service Agent
# 6. Create JSON key → Download
```

### 3. Configuration Files

#### `config/gemini.js`
```javascript
const { VertexAI } = require('@google-cloud/vertexai');

// Initialize Vertex AI
const vertexAI = new VertexAI({
  project: process.env.GOOGLE_CLOUD_PROJECT,
  location: process.env.VERTEX_AI_LOCATION || 'us-central1'
});

// Get Gemini Pro model
const geminiPro = vertexAI.getGenerativeModel({
  model: 'gemini-1.5-pro',
  generationConfig: {
    maxOutputTokens: 2048,
    temperature: 0.7,
    topP: 0.8,
    topK: 40
  }
});

// Get Gemini Flash model (faster, cheaper)
const geminiFlash = vertexAI.getGenerativeModel({
  model: 'gemini-1.5-flash',
  generationConfig: {
    maxOutputTokens: 2048,
    temperature: 0.7,
    topP: 0.8,
    topK: 40
  }
});

// Get Gemini Pro Vision model (for images)
const geminiProVision = vertexAI.getGenerativeModel({
  model: 'gemini-1.5-pro-vision',
});

module.exports = { geminiPro, geminiFlash, geminiProVision };
```

#### `config/database.js`
```javascript
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  },
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test connection
pool.on('connect', () => {
  console.log('Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('Unexpected database error:', err);
});

module.exports = pool;
```

---

## 🤖 Gemini Service Implementation

### `services/gemini.js`
```javascript
const { geminiPro, geminiFlash, geminiProVision } = require('../config/gemini');

/**
 * Call Gemini Pro for complex reasoning tasks
 */
async function callGeminiPro(prompt) {
  try {
    const result = await geminiPro.generateContent(prompt);
    const response = result.response;
    return response.text();
  } catch (error) {
    console.error('Gemini Pro error:', error);
    throw new Error('AI service temporarily unavailable');
  }
}

/**
 * Call Gemini Flash for faster, simpler tasks (cheaper)
 */
async function callGeminiFlash(prompt) {
  try {
    const result = await geminiFlash.generateContent(prompt);
    const response = result.response;
    return response.text();
  } catch (error) {
    console.error('Gemini Flash error:', error);
    throw new Error('AI service temporarily unavailable');
  }
}

/**
 * Call Gemini Pro Vision for image analysis
 */
async function callGeminiVision(prompt, imageData) {
  try {
    const request = {
      contents: [{
        role: 'user',
        parts: [
          { text: prompt },
          { 
            inlineData: {
              mimeType: 'image/jpeg',
              data: imageData // Base64 encoded image
            }
          }
        ]
      }]
    };
    
    const result = await geminiProVision.generateContent(request);
    const response = result.response;
    return response.text();
  } catch (error) {
    console.error('Gemini Vision error:', error);
    throw new Error('Image analysis service temporarily unavailable');
  }
}

/**
 * Smart function that chooses right model based on task complexity
 */
async function callGemini(prompt, options = {}) {
  const { 
    complex = false,  // Use Pro for complex tasks
    image = null,      // Image data for vision tasks
    parseJSON = false  // Parse response as JSON
  } = options;
  
  let response;
  
  if (image) {
    response = await callGeminiVision(prompt, image);
  } else if (complex) {
    response = await callGeminiPro(prompt);
  } else {
    response = await callGeminiFlash(prompt);
  }
  
  if (parseJSON) {
    try {
      // Extract JSON from markdown code blocks if present
      const jsonMatch = response.match(/```json\n([\s\S]*?)\n```/);
      if (jsonMatch) {
        return JSON.parse(jsonMatch[1]);
      }
      return JSON.parse(response);
    } catch (error) {
      console.error('Failed to parse JSON response:', response);
      throw new Error('Invalid AI response format');
    }
  }
  
  return response;
}

module.exports = { 
  callGemini, 
  callGeminiPro, 
  callGeminiFlash, 
  callGeminiVision 
};
```

---

## 📊 Database Service (Direct Queries)

### `services/database.js`
```javascript
const pool = require('../config/database');

/**
 * Get products from Laravel's public schema
 */
async function getProducts(filters = {}) {
  let query = 'SELECT * FROM public.products WHERE status = $1';
  const params = ['approved'];
  
  if (filters.category) {
    query += ' AND category = $2';
    params.push(filters.category);
  }
  
  if (filters.limit) {
    query += ` LIMIT ${filters.limit}`;
  }
  
  const result = await pool.query(query, params);
  return result.rows;
}

/**
 * Get user from Laravel's public schema
 */
async function getUser(userId) {
  const result = await pool.query(
    'SELECT * FROM public.users WHERE id = $1',
    [userId]
  );
  return result.rows[0];
}

/**
 * Get product reviews from Laravel's public schema
 */
async function getReviews(productId) {
  const result = await pool.query(
    `SELECT r.*, u.firstname, u.lastname 
     FROM public.reviews r
     JOIN public.users u ON r.user_id = u.id
     WHERE r.reviewable_type = 'App\\Models\\Product' 
     AND r.reviewable_id = $1
     ORDER BY r.created_at DESC`,
    [productId]
  );
  return result.rows;
}

/**
 * Get orders from Laravel's public schema
 */
async function getOrders(filters = {}) {
  let query = 'SELECT * FROM public.orders';
  const params = [];
  
  if (filters.user_id) {
    query += ' WHERE user_id = $1';
    params.push(filters.user_id);
  }
  
  if (filters.status) {
    query += params.length ? ' AND' : ' WHERE';
    query += ' status = $' + (params.length + 1);
    params.push(filters.status);
  }
  
  query += ' ORDER BY created_at DESC';
  
  const result = await pool.query(query, params);
  return result.rows;
}

/**
 * Save style profile to AI schema
 */
async function saveStyleProfile(userId, quizAnswers, preferences) {
  const result = await pool.query(
    `INSERT INTO ai_service.style_profiles (user_id, quiz_answers, style_preferences, updated_at)
     VALUES ($1, $2, $3, NOW())
     ON CONFLICT (user_id) 
     DO UPDATE SET quiz_answers = $2, style_preferences = $3, updated_at = NOW()
     RETURNING *`,
    [userId, JSON.stringify(quizAnswers), JSON.stringify(preferences)]
  );
  return result.rows[0];
}

/**
 * Get style profile from AI schema
 */
async function getStyleProfile(userId) {
  const result = await pool.query(
    'SELECT * FROM ai_service.style_profiles WHERE user_id = $1',
    [userId]
  );
  return result.rows[0];
}

/**
 * Save chat history to AI schema
 */
async function saveChatMessage(userId, message, response) {
  const result = await pool.query(
    `INSERT INTO ai_service.chat_history (user_id, message, response)
     VALUES ($1, $2, $3) RETURNING *`,
    [userId, message, response]
  );
  return result.rows[0];
}

/**
 * Get chat history from AI schema
 */
async function getChatHistory(userId, limit = 10) {
  const result = await pool.query(
    `SELECT * FROM ai_service.chat_history 
     WHERE user_id = $1 
     ORDER BY created_at DESC 
     LIMIT $2`,
    [userId, limit]
  );
  return result.rows.reverse(); // Oldest first
}

module.exports = {
  getProducts,
  getUser,
  getReviews,
  getOrders,
  saveStyleProfile,
  getStyleProfile,
  saveChatMessage,
  getChatHistory
};
```

---

## 💡 Example Feature Implementation with Gemini

### Example 1: Style Recommendations
```javascript
const { callGemini } = require('../services/gemini');
const { getProducts, getStyleProfile } = require('../services/database');

async function getPersonalizedRecommendations(userId) {
  // Get data directly from shared database
  const styleProfile = await getStyleProfile(userId);
  const products = await getProducts({ limit: 50 });
  
  const prompt = `
You are a Nigerian fashion AI assistant for Oja Ewa marketplace.

User's style preferences: ${JSON.stringify(styleProfile.style_preferences)}
User's quiz answers: ${JSON.stringify(styleProfile.quiz_answers)}

Available products:
${JSON.stringify(products)}

Recommend 10 products that best match this user's style.

Return ONLY a JSON array of product IDs: [1, 5, 12, 23, ...]
`;

  const recommendations = await callGemini(prompt, { parseJSON: true });
  
  // Get full product details
  const recommendedProducts = products.filter(p => 
    recommendations.includes(p.id)
  );
  
  return recommendedProducts;
}
```

### Example 2: Visual Search
```javascript
const { callGeminiVision } = require('../services/gemini');
const { getProducts } = require('../services/database');
const axios = require('axios');

async function visualSearch(imageUrl) {
  // Download and convert image to base64
  const response = await axios.get(imageUrl, { responseType: 'arraybuffer' });
  const imageBase64 = Buffer.from(response.data).toString('base64');
  
  const prompt = `
Analyze this fashion item image and describe:
1. Type of item (dress, shirt, agbada, etc)
2. Style (traditional, modern, casual, formal)
3. Colors and patterns
4. Cultural elements (Yoruba, Igbo, Hausa styles)
5. Gender (male/female/unisex)

Be specific and use Nigerian fashion terminology.
`;

  const description = await callGeminiVision(prompt, imageBase64);
  
  // Now use description to find similar products
  const products = await getProducts();
  
  const matchPrompt = `
Image shows: ${description}

Available products:
${JSON.stringify(products.slice(0, 100))}

Find 10 most similar products.
Return ONLY JSON array of product IDs: [1, 5, 12, ...]
`;

  const matches = await callGemini(matchPrompt, { parseJSON: true });
  
  return products.filter(p => matches.includes(p.id));
}
```

### Example 3: Chatbot
```javascript
const { callGeminiFlash } = require('../services/gemini');
const { getProducts, saveChatMessage, getChatHistory } = require('../services/database');

async function chatbot(userId, userMessage) {
  // Get context from database
  const products = await getProducts({ limit: 20 });
  const chatHistory = await getChatHistory(userId, 5);
  
  const prompt = `
You are a Nigerian fashion expert assistant for Oja Ewa marketplace.

Chat history:
${chatHistory.map(h => `User: ${h.message}\nAssistant: ${h.response}`).join('\n')}

Available products (sample):
${JSON.stringify(products)}

User's new question: ${userMessage}

Provide helpful, culturally aware advice about Nigerian fashion and our products.
Be conversational and friendly.
`;

  const response = await callGeminiFlash(prompt);
  
  // Save to chat history
  await saveChatMessage(userId, userMessage, response);
  
  return response;
}
```

---

## 💰 Cost Optimization for Gemini

### Model Selection Strategy:
```javascript
// Use Gemini Flash (cheaper) for:
- Simple product recommendations
- Basic chat responses
- Review summaries
- Product descriptions

// Use Gemini Pro (better quality) for:
- Complex outfit generation
- Detailed trend analysis
- Competition analysis
- Customer segmentation

// Use Gemini Pro Vision for:
- Visual search
- Product image analysis
- Beauty product matching (skin tone from selfie)
```

### Pricing (as of 2025):
```
Gemini 1.5 Flash:
- Input: $0.075 per 1M tokens
- Output: $0.30 per 1M tokens

Gemini 1.5 Pro:
- Input: $1.25 per 1M tokens
- Output: $5.00 per 1M tokens

Gemini Pro Vision:
- Input: $1.25 per 1M tokens
- Output: $5.00 per 1M tokens
- Images: ~258 tokens per image
```

### Caching Strategy:
```javascript
const cache = require('./cache');

async function getCachedRecommendations(userId) {
  const cacheKey = `recommendations:${userId}`;
  
  // Check cache first
  const cached = await cache.get(cacheKey);
  if (cached) return JSON.parse(cached);
  
  // Generate with Gemini
  const recommendations = await getPersonalizedRecommendations(userId);
  
  // Cache for 30 minutes
  await cache.setex(cacheKey, 1800, JSON.stringify(recommendations));
  
  return recommendations;
}
```

---

## 🔐 Security & Best Practices

### 1. Service Account Security
```javascript
// Store service account key securely
// Option 1: Railway secret file
// Option 2: Base64 encode and store in env var

if (process.env.GOOGLE_SERVICE_ACCOUNT_BASE64) {
  const credentials = JSON.parse(
    Buffer.from(process.env.GOOGLE_SERVICE_ACCOUNT_BASE64, 'base64').toString()
  );
  process.env.GOOGLE_APPLICATION_CREDENTIALS = '/tmp/sa-key.json';
  require('fs').writeFileSync('/tmp/sa-key.json', JSON.stringify(credentials));
}
```

### 2. Input Sanitization
```javascript
function sanitizeInput(text) {
  // Remove potential injection attempts
  return text
    .replace(/[<>]/g, '') // Remove HTML tags
    .substring(0, 5000);   // Limit length
}

const userMessage = sanitizeInput(req.body.message);
```

### 3. Rate Limiting
```javascript
const rateLimit = require('express-rate-limit');

const aiLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 20, // Max 20 AI requests per hour per user
  message: 'Too many AI requests, please try again later'
});

app.use('/ai/', aiLimiter);
```

---

## 🔗 Connecting to Railway PostgreSQL from Anywhere

### Get Connection Details from Railway:

1. **Go to Railway Dashboard** → Your Project → PostgreSQL Service
2. **Click "Connect" tab**
3. **Copy connection string:**

```
postgresql://postgres:PASSWORD@containers-us-west-123.railway.app:5432/railway
```

### Use in Node.js (Any Platform):

```javascript
// config/database.js
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false  // Required for Railway
  }
});

// Test connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Database connection failed:', err);
  } else {
    console.log('✅ Connected to Railway PostgreSQL:', res.rows[0].now);
  }
});
```

### Connection Works From:
- ✅ Your local machine (development)
- ✅ Vercel (serverless functions)
- ✅ Heroku
- ✅ DigitalOcean
- ✅ AWS
- ✅ Google Cloud
- ✅ Any VPS with internet access

**Important:** Railway PostgreSQL is accessible from the internet, so your Node.js service can run anywhere!

---

## ✅ Deployment Checklist

### Google Cloud Setup:
- [ ] Create Google Cloud project
- [ ] Enable Vertex AI API
- [ ] Create service account with roles: Vertex AI User
- [ ] Download service account JSON key
- [ ] Store key securely (as file or base64 env var)

### Database Setup:
- [ ] Get Railway PostgreSQL connection string
- [ ] Test connection from local machine
- [ ] Create `ai_service` schema
- [ ] Create AI tables (style_profiles, chat_history, etc)
- [ ] Verify can read Laravel tables (public schema)

### Node.js Service:
- [ ] Set all environment variables
- [ ] Test Gemini API connection
- [ ] Test database connection
- [ ] Run locally and test all endpoints
- [ ] Deploy to your chosen platform
- [ ] Test deployed service
- [ ] Monitor logs and errors

### Security:
- [ ] Never commit `.env` file
- [ ] Never commit service account key
- [ ] Use environment variables for all secrets
- [ ] Enable CORS for your frontend domains only
- [ ] Set up rate limiting on AI endpoints
- [ ] Monitor usage and costs

---

## 📊 Development Workflow

### Local Development:
```bash
# 1. Start Node.js service locally
npm run dev  # Runs on localhost:3000

# 2. Connects to Railway PostgreSQL (same as Laravel)
# 3. Calls Gemini API for AI features
# 4. Test endpoints with Postman/curl
```

### Laravel (on Railway):
```
https://your-laravel-app.railway.app
Connected to: Railway PostgreSQL
```

### Node.js AI (localhost):
```
http://localhost:3000
Connected to: Railway PostgreSQL (same database)
Calls: Google Vertex AI (Gemini)
```

### Node.js AI (production):
```
https://your-ai-service.vercel.app (or wherever you deploy)
Connected to: Railway PostgreSQL (same database)
Calls: Google Vertex AI (Gemini)
```

**All three can access the same PostgreSQL database on Railway!**

---

**With Gemini and shared database, your setup is simpler and cheaper than using OpenAI + separate database!**