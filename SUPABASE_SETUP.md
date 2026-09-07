# AgriGuard AI — Supabase Setup Guide

## Quick Start (5 minutes)

### Step 1: Create Supabase Project

1. Go to **https://supabase.com** and sign up (free tier available)
2. Click **"New Project"**
3. Fill in:
   - **Organization**: Create new or use existing
   - **Project name**: `agriguard-ai`
   - **Database password**: Choose a strong password (save it!)
   - **Region**: Choose closest to your users (e.g., Mumbai for India)
4. Click **"Create new project"**
5. Wait 1-2 minutes for project to be ready

### Step 2: Get Your Credentials

1. In your project dashboard, go to **Settings** (gear icon) → **API**
2. Copy these two values:
   - **Project URL** (looks like: `https://xxxxxxxx.supabase.co`)
   - **Anon public key** (starts with `eyJ...`)

### Step 3: Configure Environment Variables

1. Open `agriguard/.env` file
2. Replace the placeholder values:

```env
# Supabase Configuration
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here

# AI Provider Keys (already configured)
VITE_GEMINI_API_KEY=your-gemini-key
VITE_OPENAI_API_KEY=your-openai-key
```

### Step 4: Set Up Database Tables

1. In Supabase dashboard, go to **SQL Editor**
2. Copy and run this SQL:

```sql
-- ============================================================
-- AgriGuard AI — Database Schema
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. Profiles Table (extends auth.users)
-- ============================================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  role TEXT CHECK (role IN ('farmer', 'expert', 'government')) DEFAULT 'farmer',
  phone TEXT,
  avatar_url TEXT,
  language TEXT DEFAULT 'en',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================
-- 2. Farms Table
-- ============================================================
CREATE TABLE farms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  location TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  area_hectares DECIMAL(10, 2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE farms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own farms" ON farms
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own farms" ON farms
  FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- 3. Crops Table
-- ============================================================
CREATE TABLE crops (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  farm_id UUID REFERENCES farms(id) ON DELETE CASCADE,
  crop_type TEXT CHECK (crop_type IN ('tomato', 'rice', 'potato', 'maize', 'apple')) NOT NULL,
  variety TEXT,
  stage TEXT,
  planting_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE crops ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view crops on own farms" ON crops
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM farms WHERE farms.id = crops.farm_id AND farms.user_id = auth.uid())
  );

CREATE POLICY "Users can manage crops on own farms" ON crops
  FOR ALL USING (
    EXISTS (SELECT 1 FROM farms WHERE farms.id = crops.farm_id AND farms.user_id = auth.uid())
  );

-- ============================================================
-- 4. Disease Reports Table
-- ============================================================
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id),
  farm_id UUID REFERENCES farms(id),
  image_url TEXT,
  crop_type TEXT CHECK (crop_type IN ('tomato', 'rice', 'potato', 'maize', 'apple')),
  disease TEXT,
  confidence DECIMAL(5, 2),
  severity TEXT CHECK (severity IN ('low', 'moderate', 'high', 'critical')),
  risk_score INTEGER,
  symptoms JSONB DEFAULT '[]',
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  location TEXT,
  ai_result JSONB,
  expert_status TEXT CHECK (expert_status IN ('pending', 'confirmed', 'corrected', 'needs_image')) DEFAULT 'pending',
  expert_id UUID REFERENCES profiles(id),
  expert_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own reports" ON reports
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own reports" ON reports
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Experts can view all reports" ON reports
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'expert')
  );

CREATE POLICY "Experts can update reports" ON reports
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'expert')
  );

CREATE POLICY "Government can view all reports" ON reports
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'government')
  );

-- ============================================================
-- 5. Expert Reviews Table
-- ============================================================
CREATE TABLE expert_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  report_id UUID REFERENCES reports(id) ON DELETE CASCADE,
  expert_id UUID REFERENCES profiles(id),
  diagnosis TEXT,
  status TEXT CHECK (status IN ('pending', 'confirmed', 'corrected', 'needs_image')),
  comments TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE expert_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Experts can manage own reviews" ON expert_reviews
  FOR ALL USING (auth.uid() = expert_id);

CREATE POLICY "Users can view reviews on own reports" ON expert_reviews
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM reports WHERE reports.id = expert_reviews.report_id AND reports.user_id = auth.uid())
  );

-- ============================================================
-- 6. Notifications Table
-- ============================================================
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT CHECK (type IN ('risk', 'weather', 'expert', 'hotspot')),
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================================
-- 7. Function to handle new user signup
-- ============================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'role', 'farmer')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- 8. Updated_at trigger function
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_reports_updated_at
  BEFORE UPDATE ON reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- 9. Storage Buckets (run in Supabase Dashboard → Storage)
-- ============================================================
-- Create these buckets in the Supabase Dashboard:
-- 1. Go to Storage in your project
-- 2. Create bucket: "crop-images" (public)
-- 3. Create bucket: "avatars" (public)
```

### Step 5: Create Storage Buckets

1. In Supabase dashboard, go to **Storage**
2. Click **"New bucket"**
3. Create:
   - **Name**: `crop-images`
   - **Public**: ✅ Yes
4. Create another:
   - **Name**: `avatars`
   - **Public**: ✅ Yes

### Step 6: Enable Email Auth

1. Go to **Authentication** → **Providers**
2. Make sure **Email** is enabled
3. (Optional) Disable "Confirm email" for faster testing

### Step 7: Test Your Setup

1. Run the app:
   ```bash
   cd agriguard
   npm run dev
   ```

2. Go to http://localhost:5173/signup
3. Create an account with your email
4. Check your email for verification (if enabled)
5. Login and test the app!

## Troubleshooting

### "Invalid API key" error
- Double-check your `.env` file has correct Supabase URL and key
- Make sure the URL starts with `https://` and ends with `.supabase.co`

### Can't create account
- Check if Email auth is enabled in Supabase
- Check the browser console for error messages

### Data not saving
- Run the SQL schema again in SQL Editor
- Check Table Editor to see if tables exist

### Images not uploading
- Verify storage buckets are created
- Check bucket permissions are set to public

## Free Tier Limits

Supabase free tier includes:
- ✅ 500MB database
- ✅ 1GB file storage
- ✅ 50,000 monthly active users
- ✅ 500MB bandwidth
- ✅ 2 projects

This is more than enough for development and small-scale production!

## Next Steps

Once Supabase is working:
1. Test signup/login flow
2. Test crop scanning with real AI
3. Add more features (real-time updates, etc.)
4. Deploy to production (Vercel, Netlify, etc.)
