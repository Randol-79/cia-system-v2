# ANTHROPIC_API_KEY Setup Guide

## 🔑 Setting Up Your Anthropic API Key

The `ANTHROPIC_API_KEY` is **required** for the CIA System to function. This key enables AI-powered recommendations and intelligent insights using Anthropic's Claude AI.

---

## 📋 Getting Your API Key

### Step 1: Create Anthropic Account

1. Go to: https://console.anthropic.com
2. Sign up or log in
3. Verify your email address

### Step 2: Generate API Key

1. Navigate to: https://console.anthropic.com/settings/keys
2. Click "Create Key"
3. Give it a name: `CIA System Production`
4. Copy the key (starts with `sk-ant-`)
5. **Save it securely** - you won't be able to see it again

**Example format:**
```
sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## 🚀 Platform-Specific Setup Instructions

## Platform 1: Render.com

### After Deploying to Render

1. **Go to Render Dashboard**
   - Visit: https://dashboard.render.com

2. **Select Your Backend Service**
   - Click on `cia-backend` service

3. **Navigate to Environment**
   - Click "Environment" in the left sidebar

4. **Add Environment Variable**
   - Click "Add Environment Variable"
   - **Key:** `ANTHROPIC_API_KEY`
   - **Value:** `sk-ant-api03-your-actual-key-here`
   - Click "Save Changes"

5. **Add Required Variables**
   ```
   ANTHROPIC_API_KEY = sk-ant-api03-your-key-here
   NODE_ENV = production
   ```

6. **Optional: Add Integration Keys**
   ```
   SLACK_BOT_TOKEN = xoxb-your-token
   SLACK_SIGNING_SECRET = your-secret
   ACCELO_CLIENT_ID = your-id
   ACCELO_CLIENT_SECRET = your-secret
   GOOGLE_CLIENT_ID = your-id
   GOOGLE_CLIENT_SECRET = your-secret
   FIREFLIES_API_KEY = your-key
   ```

7. **Redeploy Service**
   - Render will automatically redeploy with new environment variables
   - Wait 2-3 minutes for deployment to complete

8. **Verify**
   ```bash
   curl https://cia-backend.onrender.com/health
   ```

---

## Platform 2: Vercel + Railway

### Part A: Railway Backend

1. **Go to Railway Dashboard**
   - Visit: https://railway.app/dashboard

2. **Select Your Project**
   - Click on `cia-system` project

3. **Select Backend Service**
   - Click on the backend service

4. **Navigate to Variables Tab**
   - Click "Variables" tab

5. **Add Environment Variables**
   
   Click "New Variable" and add:
   
   **Required:**
   ```
   ANTHROPIC_API_KEY = sk-ant-api03-your-key-here
   NODE_ENV = production
   CORS_ORIGIN = https://cia-frontend.vercel.app
   PORT = 5000
   ```
   
   **Optional Integrations:**
   ```
   SLACK_BOT_TOKEN = xoxb-your-token
   ACCELO_CLIENT_ID = your-id
   GOOGLE_CLIENT_ID = your-id
   ```

6. **Save and Redeploy**
   - Railway automatically redeploys when variables change
   - Wait 2-3 minutes for deployment

7. **Verify**
   ```bash
   curl https://cia-backend.railway.app/health
   ```

### Part B: Vercel Frontend (No API Key Needed)

The frontend doesn't need the Anthropic API key. It only needs:

```bash
vercel env add REACT_APP_API_URL production
# Enter: https://cia-backend.railway.app

vercel env add REACT_APP_WS_URL production
# Enter: wss://cia-backend.railway.app
```

---

## Platform 3: Self-Hosted Docker

### Step 1: Create .env File

On your server:

```bash
cd /path/to/CIA-System

# Create .env file
nano .env
```

### Step 2: Add Environment Variables

Paste this configuration (replace with your actual values):

```bash
# ============================================================================
# REQUIRED ENVIRONMENT VARIABLES
# ============================================================================

# Node Environment
NODE_ENV=production
PORT=5000

# Database (auto-configured by docker-compose)
DATABASE_URL=postgresql://cia_user:CHANGE_THIS_PASSWORD@postgres:5432/cia_db
REDIS_URL=redis://redis:6379

# Anthropic AI (REQUIRED)
ANTHROPIC_API_KEY=sk-ant-api03-your-actual-key-here

# CORS Configuration
CORS_ORIGIN=https://cia.orangeocean.com
ALLOWED_ORIGINS=https://cia.orangeocean.com,https://www.orangeocean.com

# ============================================================================
# OPTIONAL INTEGRATIONS
# ============================================================================

# Slack Integration
SLACK_BOT_TOKEN=xoxb-your-slack-bot-token
SLACK_SIGNING_SECRET=your-slack-signing-secret
SLACK_CHANNEL_ID=your-default-channel-id

# Accelo CRM
ACCELO_CLIENT_ID=your-accelo-client-id
ACCELO_CLIENT_SECRET=your-accelo-client-secret
ACCELO_ACCESS_TOKEN=your-accelo-access-token
ACCELO_REFRESH_TOKEN=your-accelo-refresh-token
ACCELO_DEPLOYMENT=your-deployment-name

# Google Services
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret
GOOGLE_REDIRECT_URI=https://cia.orangeocean.com/auth/google/callback

# Fireflies.ai
FIREFLIES_API_KEY=your-fireflies-api-key

# Zoom
ZOOM_WEBHOOK_SECRET=your-zoom-webhook-secret

# ============================================================================
# SECURITY (Generate Random Strings)
# ============================================================================

# Generate with: openssl rand -base64 32
SESSION_SECRET=generate_random_32_character_string_here
JWT_SECRET=generate_another_random_32_character_string_here
JWT_EXPIRATION=7d

# ============================================================================
# PERFORMANCE OPTIMIZATION
# ============================================================================

# Database Pool
DB_POOL_MIN=2
DB_POOL_MAX=10
DB_IDLE_TIMEOUT=30000

# Cache TTL (seconds)
CACHE_TTL_SHORT=300
CACHE_TTL_MEDIUM=900
CACHE_TTL_LONG=3600

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# ============================================================================
# FEATURE FLAGS
# ============================================================================

ENABLE_SLACK_NOTIFICATIONS=true
ENABLE_AI_RECOMMENDATIONS=true
ENABLE_WEBHOOK_PROCESSING=true
ENABLE_BACKGROUND_JOBS=true
```

### Step 3: Secure the File

```bash
# Set proper permissions (only owner can read)
chmod 600 .env

# Verify permissions
ls -la .env
# Should show: -rw------- (600)
```

### Step 4: Start Services

```bash
# Start all services with docker-compose
docker compose up -d

# Check logs
docker compose logs -f backend

# Verify environment variables are loaded
docker compose exec backend env | grep ANTHROPIC_API_KEY
```

### Step 5: Verify

```bash
# Check health endpoint
curl https://cia.orangeocean.com/health

# Check if AI is working
curl -X POST https://cia.orangeocean.com/api/ai/test \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}'
```

---

## 🔒 Security Best Practices

### 1. Never Commit API Keys to Git

```bash
# Ensure .env is in .gitignore
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore
echo ".env.production" >> .gitignore

# Verify
git status
# .env should NOT appear in the list
```

### 2. Use Environment-Specific Keys

- **Development:** Use a separate API key with lower rate limits
- **Staging:** Use a different key for testing
- **Production:** Use a dedicated production key

### 3. Rotate Keys Regularly

1. Generate new API key in Anthropic console
2. Update environment variables on all platforms
3. Test thoroughly
4. Delete old key from Anthropic console

### 4. Monitor Usage

1. Check Anthropic console regularly
2. Set up usage alerts
3. Monitor costs
4. Review API logs

### 5. Secure Storage

**For Local Development:**
```bash
# Use a .env file (never commit)
cp .env.example .env
nano .env
```

**For Production:**
- Use platform's secret management (Render, Railway)
- Use environment variables (Docker)
- Use secret managers (AWS Secrets Manager, HashiCorp Vault)

---

## 🧪 Testing Your API Key

### Test 1: Health Check

```bash
# Should return: {"status":"ok","ai":"configured"}
curl https://your-backend-url/health
```

### Test 2: AI Endpoint (if available)

```bash
curl -X POST https://your-backend-url/api/ai/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hello, can you help me?",
    "context": "test"
  }'
```

### Test 3: Check Logs

**Render:**
- Go to backend service → Logs
- Look for: "AI Engine initialized successfully"

**Railway:**
- Click on backend service → Logs
- Look for: "Anthropic API connected"

**Docker:**
```bash
docker compose logs backend | grep -i anthropic
```

---

## ❌ Troubleshooting

### Error: "ANTHROPIC_API_KEY is not set"

**Solution:**
1. Verify the environment variable is set
2. Check for typos in the variable name
3. Restart the service after adding the variable

**Render:**
```
Environment → Add Variable → Save → Redeploy
```

**Railway:**
```
Variables → New Variable → Save (auto-redeploys)
```

**Docker:**
```bash
# Check if variable is in .env
cat .env | grep ANTHROPIC_API_KEY

# Restart services
docker compose down
docker compose up -d
```

### Error: "Invalid API Key"

**Solution:**
1. Verify the key format: `sk-ant-api03-...`
2. Check for extra spaces or newlines
3. Regenerate the key in Anthropic console
4. Update environment variables

### Error: "Rate Limit Exceeded"

**Solution:**
1. Check usage in Anthropic console
2. Upgrade your Anthropic plan
3. Implement caching to reduce API calls
4. Add rate limiting in your application

### Error: "API Key Not Working After Deployment"

**Solution:**
1. Verify environment variables are saved
2. Redeploy the service
3. Check logs for initialization errors
4. Test with curl command

---

## 📊 Environment Variable Checklist

### Required for All Platforms

- [ ] `ANTHROPIC_API_KEY` - Your Anthropic API key
- [ ] `NODE_ENV` - Set to `production`
- [ ] `DATABASE_URL` - PostgreSQL connection (auto-configured on Render/Railway)
- [ ] `REDIS_URL` - Redis connection (auto-configured on Render/Railway)
- [ ] `CORS_ORIGIN` - Your frontend URL

### Recommended

- [ ] `SESSION_SECRET` - Random 32-character string
- [ ] `JWT_SECRET` - Random 32-character string
- [ ] `RATE_LIMIT_MAX_REQUESTS` - Default: 100

### Optional Integrations

- [ ] `SLACK_BOT_TOKEN` - For Slack notifications
- [ ] `ACCELO_CLIENT_ID` - For Accelo CRM integration
- [ ] `GOOGLE_CLIENT_ID` - For Google Analytics
- [ ] `FIREFLIES_API_KEY` - For meeting transcripts

---

## 🎯 Quick Reference

### Get API Key
```
https://console.anthropic.com/settings/keys
```

### Format
```
sk-ant-api03-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Add to Render
```
Dashboard → Backend Service → Environment → Add Variable
Key: ANTHROPIC_API_KEY
Value: sk-ant-api03-your-key
```

### Add to Railway
```
Dashboard → Project → Backend → Variables → New Variable
ANTHROPIC_API_KEY = sk-ant-api03-your-key
```

### Add to Docker
```bash
echo "ANTHROPIC_API_KEY=sk-ant-api03-your-key" >> .env
chmod 600 .env
docker compose up -d
```

### Verify
```bash
curl https://your-backend-url/health
```

---

## ✅ Final Checklist

- [ ] Anthropic account created
- [ ] API key generated and saved securely
- [ ] Environment variable added to platform
- [ ] Service redeployed (if needed)
- [ ] Health check passes
- [ ] AI features working
- [ ] Logs show successful initialization
- [ ] Usage monitoring set up

---

**Your ANTHROPIC_API_KEY is now configured! The CIA System's AI features are ready to use.** 🎉

For additional help, refer to:
- Anthropic Documentation: https://docs.anthropic.com
- Platform-specific guides in DEPLOY_ALL_PLATFORMS.md
