# AgriGuard AI — Netlify Deployment Guide

## Deploy to Netlify (Free)

### Step 1: Push to GitHub

```bash
cd agriguard

# Initialize git (if not already)
git init
git add .
git commit -m "AgriGuard AI - Full stack with auth & real-time"

# Create GitHub repo and push
gh repo create agriguard-ai --public
git remote add origin https://github.com/YOUR_USERNAME/agriguard-ai.git
git push -u origin main
```

### Step 2: Connect to Netlify

1. Go to **https://app.netlify.com** and sign up with GitHub
2. Click **"Add new site"** → **"Import an existing project"**
3. Select **GitHub** and authorize
4. Search and select your `agriguard-ai` repository
5. Click **"Deploy site"**

### Step 3: Configure Environment Variables

In Netlify dashboard → **Site settings** → **Environment variables**, click **"Add a variable"** and add:

| Key | Value |
|-----|-------|
| `VITE_SUPABASE_URL` | `https://your-project.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | `your-anon-key` |
| `VITE_GEMINI_API_KEY` | `your-gemini-key` |
| `VITE_OPENAI_API_KEY` | `your-openai-key` |

### Step 4: Trigger Redeploy

After adding variables:
1. Go to **Deploys** tab
2. Click **"Trigger deploy"** → **"Deploy site"**
3. Wait 1-2 minutes

Your app is now live at `https://your-site-name.netlify.app`!

### Step 5: Custom Domain (Optional)

1. Go to **Domain settings**
2. Click **"Add custom domain"**
3. Enter your domain and follow DNS instructions

---

## Quick Deploy with CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Initialize
cd agriguard
netlify init

# Deploy
netlify deploy --prod
```

---

## Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `VITE_SUPABASE_URL` | ✅ Yes | Supabase project URL |
| `VITE_SUPABASE_ANON_KEY` | ✅ Yes | Supabase anonymous key |
| `VITE_GEMINI_API_KEY` | Optional | Google Gemini API key |
| `VITE_OPENAI_API_KEY` | Optional | OpenAI API key |

---

## Post-Deployment Checklist

- [ ] Test login/signup flow
- [ ] Test crop scanning with AI
- [ ] Verify real-time notifications work
- [ ] Check location detection
- [ ] Test on mobile devices
- [ ] Verify all routes work (refresh doesn't 404)

---

## Troubleshooting

### Build fails
- Check all environment variables are set
- Ensure Node.js version is 18+

### Routes 404 on refresh
- The `netlify.toml` redirects handle this
- Make sure the file is in the project root

### Supabase errors
- Verify URL and keys are correct
- Check CORS settings in Supabase:
  - Go to Supabase → Settings → API
  - Add your Netlify URL to "Site URL"

### Environment variables not working
- After adding variables, you MUST redeploy
- Variables starting with `VITE_` are exposed to the browser

---

## Updating the App

After making changes:

```bash
git add .
git commit -m "Update: description"
git push
```

Netlify auto-deploys on every push to main branch!

---

## Netlify Free Tier Limits

✅ **100GB** bandwidth/month
✅ **300** build minutes/month
✅ **Unlimited** sites
✅ **Unlimited** deployments
✅ **Custom domains** (free SSL)

This is **completely free** for small to medium usage!

---

## Useful Netlify Features

### Branch Deploys
- Every branch gets its own preview URL
- Great for testing before merge

### Deploy Previews
- PRs automatically get preview links
- Share with team for review

### Forms (Optional)
- Add contact forms without backend
- Submissions stored in Netlify

### Identity (Optional)
- Built-in user authentication
- Can replace Supabase Auth if needed
