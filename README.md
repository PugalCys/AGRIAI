# AgriGuard AI

AgriGuard AI is a production-style hackathon prototype for early crop disease warning. It combines a voice-first farmer journey with crop image analysis, live-weather integration, transparent disease-risk scoring, geospatial hotspots, expert verification, and a government command dashboard.

## Experience

- Farmer interface with large touch targets, camera-first scanning, speech input, spoken guidance, and English, Tamil, Hindi, and Marathi copy.
- Safe structured crop analysis that clearly presents predictions rather than guaranteed diagnoses.
- Rule-based seven-day disease-risk forecasting designed to be replaced by a trained model later.
- Leaflet/OpenStreetMap disease hotspots with a simplified nearby-alert experience for farmers.
- Agriculture expert report review, diagnosis correction, image requests, and verification.
- Government dashboard with maps, trends, crop distribution, high-risk districts, and a report registry.
- Reliable Demo Mode whenever AI, database, weather, or browser voice services are unavailable.

## Technology

- React 19, TypeScript, TanStack Start, Tailwind CSS
- Chart.js and React Chart.js 2
- Leaflet with OpenStreetMap tiles
- Netlify Functions for server-side AI, weather, reports, and reviews
- Google Gemini through the server-side SDK
- Open-Meteo for current weather and forecast data
- Netlify Database (managed Postgres) with Drizzle ORM

## Local Setup

1. Install dependencies with `pnpm install`.
2. Copy `.env.example` to `.env` if external services are needed.
3. Add `GEMINI_API_KEY` in local or Netlify server-side environment variables. The Supabase variables are optional compatibility placeholders; persistent production data uses Netlify Database.
4. Run with Netlify local emulation using `netlify dev --port 8889`.

The application works without any keys. In Demo Mode, crop scans return a curated Tomato Early Blight result, weather uses realistic fallback data, and database actions remain demonstrable.

## Safety

The prototype only claims demo coverage for Tomato Early Blight, Rice Leaf Blast, Potato Late Blight, Maize Leaf Disease, and Apple Scab. Advisories avoid pesticide dosage and chemical concentrations. Farmers are directed to locally approved guidance and agriculture experts before treatment.
