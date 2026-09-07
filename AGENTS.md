# AgriGuard AI Architecture

## Structure

- `src/routes/index.tsx` contains the single-page prototype journey and all major screen state transitions.
- `src/styles.css` contains the responsive organic AgriTech visual system for farmer and command-center experiences.
- `src/components/HotspotMap.tsx` owns client-only Leaflet initialization and its card fallback.
- `src/lib/i18n.ts` contains curated farmer-facing translations and speech language codes.
- `src/lib/demo-data.ts` contains realistic hackathon demonstration records, hotspots, forecasts, and curated advisories.
- `src/lib/risk-engine.ts` is the replaceable transparent disease-risk module.
- `netlify/functions/` contains server-only crop analysis, weather, report, and expert-review endpoints.
- `db/schema.ts` defines the managed Postgres schema; migrations live in `netlify/database/migrations/`.

## Conventions

- Keep farmer screens voice-first, image-first, icon-first, and limited to one dominant action.
- Never show raw service errors or technical language to farmers; retain curated Demo Mode fallbacks.
- Keep agricultural advisories curated. Do not generate pesticide dosage, chemical concentrations, regulations, or certifications.
- Treat every AI result as a prediction and route low-confidence results toward another image or expert review.
- Keep API keys and environment checks inside server functions only.
- Preserve the `calculateDiseaseRisk` interface so a trained model can replace the rule engine without rewriting the UI.
- Add database schema changes through Drizzle and generate a migration for every change.

## Non-obvious Decisions

Netlify Database is used instead of direct Supabase access because this project deploys on Netlify and requires platform-native persistent storage. It is managed PostgreSQL and maps directly to the requested relational model. The requested Supabase environment variable names remain documented as optional compatibility placeholders, but are never exposed to frontend code.
