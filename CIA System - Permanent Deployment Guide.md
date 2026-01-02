# CIA System - Permanent Deployment Guide

## 🚀 Deploy to Permanent Hosting in 10 Minutes

This guide will help you deploy the CIA System to permanent cloud hosting with your own custom domain.

---

## ⚡ Quick Deploy (Recommended)

### Option 1: Automated Script

Run the automated deployment script:

```bash
cd /home/ubuntu/CIA-System
./deploy-to-render.sh
```

This script will:
1. Authenticate with GitHub
2. Create a repository
3. Push your code
4. Guide you through Render deployment

---

### Option 2: Manual Deployment to Render.com

#### Step 1: Create GitHub Repository

```bash
cd /home/ubuntu/CIA-System

# Initialize git (already done)
git status

# Create repository on GitHub
# Go to: https://github.com/new
# Repository name: cia-system
# Make it public or private
# Don't initialize with README

# Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/cia-system.git
git branch -M main
git push -u origin main
```

#### Step 2: Deploy on Render.com

1. **Go to Render Dashboard**
   - Visit: https://render.com
   - Sign up/Login with GitHub

2. **Deploy with Blueprint**
   - Click "New +" → "Blueprint"
   - Connect your GitHub account
   - Select repository: `cia-system`
   - Render will detect `render.yaml`

3. **Configure Environment Variables**
   
   Click on each service and add:
   
   **Backend Service:**
   ```
   ANTHROPIC_API_KEY=sk-ant-your-key-here
   NODE_ENV=production
   ```
   
   **Optional Integrations:**
   ```
   SLACK_BOT_TOKEN=xoxb-your-token
   SLACK_SIGNING_SECRET=your-secret
   ACCELO_CLIENT_ID=your-id
   ACCELO_CLIENT_SECRET=your-secret
   GOOGLE_CLIENT_ID=your-id
   GOOGLE_CLIENT_SECRET=your-secret
   FIREFLIES_API_KEY=your-key
   ```

4. **Apply and Deploy**
   - Click "Apply"
   - Wait 5-10 minutes for deployment

5. **Get Your URLs**
   - Frontend: `https://cia-frontend.onrender.com`
   - Backend: `https://cia-backend.onrender.com`

---

## 🌐 Add Custom Domain (orangeocean.com)

### Step 1: Configure Custom Domain in Render

1. **Go to Frontend Service**
   - Click on `cia-frontend` service
   - Go to "Settings" → "Custom Domains"
   - Click "Add Custom Domain"
   - Enter: `cia.orangeocean.com`

2. **Get DNS Records**
   - Render will show you the DNS records to add
   - Example: CNAME record pointing to `cia-frontend.onrender.com`

### Step 2: Update DNS Settings

1. **Log into your domain registrar** (where you bought orangeocean.com)

2. **Add DNS Records**
   
   Add a CNAME record:
   ```
   Type: CNAME
   Name: cia
   Value: cia-frontend.onrender.com
   TTL: 3600 (or Auto)
   ```

3. **Wait for DNS Propagation** (5-30 minutes)

4. **Verify**
   - Visit: https://cia.orangeocean.com
   - SSL certificate will be automatically provisioned

### Step 3: Update Backend CORS

1. **Go to Backend Service** in Render
2. **Update Environment Variable**
   ```
   CORS_ORIGIN=https://cia.orangeocean.com
   ```
3. **Redeploy** the backend service

---

## 🔧 Alternative: Deploy to Vercel + Railway

### Frontend on Vercel

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Deploy Frontend**
   ```bash
   cd /home/ubuntu/CIA-System/frontend
   vercel
   ```

3. **Follow Prompts**
   - Link to existing project or create new
   - Set build command: `npm run build`
   - Set output directory: `build`

4. **Add Environment Variables**
   ```bash
   vercel env add REACT_APP_API_URL production
   # Enter: https://your-backend-url.railway.app
   
   vercel env add REACT_APP_WS_URL production
   # Enter: wss://your-backend-url.railway.app
   ```

5. **Deploy to Production**
   ```bash
   vercel --prod
   ```

### Backend on Railway

1. **Visit Railway**
   - Go to: https://railway.app
   - Sign up with GitHub

2. **Create New Project**
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose `cia-system` repository

3. **Add PostgreSQL**
   - Click "+" → "Database" → "Add PostgreSQL"
   - Railway automatically sets `DATABASE_URL`

4. **Add Redis**
   - Click "+" → "Database" → "Add Redis"
   - Railway automatically sets `REDIS_URL`

5. **Configure Backend Service**
   - Click on the backend service
   - Settings → Root Directory: `backend`
   - Settings → Start Command: `node server.js`

6. **Add Environment Variables**
   ```
   ANTHROPIC_API_KEY=your-key
   NODE_ENV=production
   CORS_ORIGIN=https://your-vercel-url.vercel.app
   ```

7. **Generate Domain**
   - Settings → Generate Domain
   - Get URL like: `cia-backend.railway.app`

8. **Update Frontend Environment**
   - Go back to Vercel
   - Update `REACT_APP_API_URL` with Railway backend URL
   - Redeploy frontend

---

## 🐳 Alternative: Self-Hosted with Docker

### Requirements
- VPS (DigitalOcean, Linode, AWS EC2, etc.)
- Ubuntu 22.04 or similar
- Domain pointed to your server IP

### Step 1: Prepare Server

```bash
# SSH into your server
ssh root@your-server-ip

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose-plugin -y

# Install Nginx
apt install nginx -y

# Install Certbot for SSL
apt install certbot python3-certbot-nginx -y
```

### Step 2: Upload Application

```bash
# From your local machine
cd /home/ubuntu
tar -czf cia-system.tar.gz CIA-System/
scp cia-system.tar.gz root@your-server-ip:/opt/

# On the server
ssh root@your-server-ip
cd /opt
tar -xzf cia-system.tar.gz
cd CIA-System
```

### Step 3: Configure Environment

```bash
# Create .env file
cat > .env << 'EOF'
NODE_ENV=production
DATABASE_URL=postgresql://cia_user:cia_password_change_me@postgres:5432/cia_db
REDIS_URL=redis://redis:6379
ANTHROPIC_API_KEY=your-key-here
CORS_ORIGIN=https://cia.orangeocean.com
EOF
```

### Step 4: Start Services

```bash
# Start with Docker Compose
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### Step 5: Configure Nginx

```bash
# Create Nginx config
cat > /etc/nginx/sites-available/cia-system << 'EOF'
server {
    listen 80;
    server_name cia.orangeocean.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /socket.io {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Enable site
ln -s /etc/nginx/sites-available/cia-system /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

### Step 6: Enable SSL

```bash
# Get SSL certificate
certbot --nginx -d cia.orangeocean.com

# Auto-renewal is configured automatically
certbot renew --dry-run
```

---

## 📊 Post-Deployment Checklist

### Verify Deployment

- [ ] Frontend loads at custom domain
- [ ] Backend API responds to health checks
- [ ] Database connection is working
- [ ] Redis cache is operational
- [ ] WebSocket connections work
- [ ] SSL certificate is active
- [ ] All integrations are configured

### Test Endpoints

```bash
# Health check
curl https://cia-backend.onrender.com/health

# API root
curl https://cia-backend.onrender.com/

# Frontend
curl -I https://cia-frontend.onrender.com/
```

### Initialize Database

If using Render or Railway, the database schema should auto-initialize. If not:

```bash
# Connect to your database
psql $DATABASE_URL

# Run schema
\i database/schema.sql

# Verify tables
\dt
```

---

## 🔐 Security Configuration

### Environment Variables

**Never commit these to Git:**
- `ANTHROPIC_API_KEY`
- `DATABASE_URL`
- `REDIS_URL`
- `SESSION_SECRET`
- `JWT_SECRET`
- Integration API keys

### CORS Configuration

Update backend environment:
```
CORS_ORIGIN=https://cia.orangeocean.com
ALLOWED_ORIGINS=https://cia.orangeocean.com,https://www.orangeocean.com
```

### Rate Limiting

Already configured in the backend:
- 100 requests per 15 minutes per IP
- Separate limits for webhooks

---

## 📈 Monitoring Setup

### Uptime Monitoring

1. **UptimeRobot** (Free)
   - Visit: https://uptimerobot.com
   - Add monitor for: `https://cia.orangeocean.com`
   - Add monitor for: `https://cia-backend.onrender.com/health`

2. **Pingdom** (Paid)
   - More detailed monitoring
   - Performance tracking

### Error Tracking

1. **Sentry**
   ```bash
   npm install @sentry/node @sentry/react
   ```
   
   Add to backend:
   ```javascript
   const Sentry = require("@sentry/node");
   Sentry.init({ dsn: "your-sentry-dsn" });
   ```

2. **LogRocket**
   - Session replay
   - User behavior tracking

---

## 🔄 CI/CD Setup

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Render

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Trigger Render Deploy
        run: |
          curl -X POST https://api.render.com/deploy/srv-${{ secrets.RENDER_SERVICE_ID }}?key=${{ secrets.RENDER_API_KEY }}
```

Add secrets in GitHub:
- `RENDER_SERVICE_ID`
- `RENDER_API_KEY`

---

## 💰 Cost Estimation

### Render.com (Recommended)

**Free Tier:**
- Web Services: 750 hours/month
- PostgreSQL: 1GB storage
- Redis: 25MB storage
- **Total: $0/month**

**Paid (Starter):**
- Web Services: $7/month each
- PostgreSQL: $7/month
- Redis: $10/month
- **Total: ~$31/month**

### Vercel + Railway

**Free Tier:**
- Vercel: 100GB bandwidth
- Railway: $5 credit/month
- **Total: ~$0-5/month**

**Paid:**
- Vercel Pro: $20/month
- Railway: ~$10-20/month
- **Total: ~$30-40/month**

### Self-Hosted VPS

**DigitalOcean Droplet:**
- Basic: $6/month (1GB RAM)
- Standard: $12/month (2GB RAM)
- **Total: $6-12/month**

---

## 🎯 Quick Start Commands

### Deploy to Render (Automated)
```bash
cd /home/ubuntu/CIA-System
./deploy-to-render.sh
```

### Deploy to Vercel + Railway
```bash
# Frontend
cd frontend && vercel --prod

# Backend
# Use Railway dashboard to deploy
```

### Self-Host with Docker
```bash
cd /home/ubuntu/CIA-System
docker compose up -d
```

---

## 📞 Support & Troubleshooting

### Common Issues

**Issue: Database not connecting**
```bash
# Check DATABASE_URL format
echo $DATABASE_URL
# Should be: postgresql://user:pass@host:5432/dbname
```

**Issue: CORS errors**
```bash
# Update backend CORS_ORIGIN
# Redeploy backend service
```

**Issue: WebSocket not connecting**
```bash
# Ensure WS_URL uses wss:// (not ws://)
# Check firewall allows WebSocket connections
```

### Get Help

- **Render Docs**: https://render.com/docs
- **Railway Docs**: https://docs.railway.app
- **Docker Docs**: https://docs.docker.com

---

## ✅ Deployment Complete!

Once deployed, your CIA System will be accessible at:

**Production URLs:**
- Frontend: https://cia.orangeocean.com
- Backend: https://api.cia.orangeocean.com (or cia-backend.onrender.com)

**Next Steps:**
1. Test all features
2. Set up monitoring
3. Configure backups
4. Launch to users!

---

**Deployed with seamless functionality!** 🚀
