# Screen ↔ API Mapping (Flutter App)

This folder documents **which API endpoints power which Flutter screens**, and how data should flow through the app.

Sources:
- Laravel API documentation: `docs/api_docs/**`
- New AI backend plan: `docs/NODE_AI_BACKEND_SIMPLE_PLAN.md`
- Gemini implementation guide: `docs/GEMINI_IMPLEMENTATION_GUIDE.md`

## Files
- `screen_inventory.md` — current routes/screens and what they do
- `laravel_endpoint_catalog.md` — extracted endpoint catalog (non-admin + key admin)
- `screen_to_laravel_api.md` — per-screen mapping to Laravel endpoints
- `ai_backend_feature_to_screens.md` — AI features: which screens change, which new screens are needed, and Node.js AI endpoints to call

## Important notes about current code
- The current Flutter UI appears to be **mostly static**: there are **no `dio` calls** in `lib/**` yet.
- This mapping therefore describes the **intended integration** (what each screen should call once wired).
