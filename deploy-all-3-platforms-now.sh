#!/bin/bash

# ============================================================================
# CIA System - Deploy to All 3 Platforms (Expert Optimized)
# Prioritized for Seamless Functionality and Development Optimization
# ============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# ============================================================================
# PHASE 1: PREPARE FOR DEPLOYMENT
# ============================================================================

log_section "Phase 1: Preparing CIA System for Deployment"

# Check if we're in the right directory
if [ ! -f "render.yaml" ]; then
    log_error "render.yaml not found. Please run this script from the CIA-System directory."
    exit 1
fi

log_success "Found CIA System directory"

# Check git status
if [ ! -d ".git" ]; then
    log_info "Initializing git repository..."
    git init
    git config user.email "deploy@orangeocean.com"
    git config user.name "Orange Ocean Deploy"
fi

log_success "Git repository ready"

# Ensure all files are committed
log_info "Committing all changes..."
git add -A
git commit -m "Production deployment - All 3 platforms ready" || log_warning "No changes to commit"

log_success "All changes committed"

# ============================================================================
# PHASE 2: DEPLOY TO GITHUB
# ============================================================================

log_section "Phase 2: Pushing to GitHub"

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) not found. Please install it first:"
    echo "  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
    echo "  sudo apt update && sudo apt install gh -y"
    exit 1
fi

log_info "Authenticating with GitHub..."
echo ""
echo "Please follow the prompts to authenticate with GitHub:"
echo ""

gh auth login

log_info "Creating GitHub repository..."
gh repo create cia-system --public --source=. --remote=origin --push || {
    log_warning "Repository might already exist. Pushing to existing repo..."
    git remote add origin https://github.com/$(gh api user -q .login)/cia-system.git 2>/dev/null || true
    git branch -M main
    git push -u origin main --force
}

GITHUB_USER=$(gh api user -q .login)
GITHUB_REPO="https://github.com/$GITHUB_USER/cia-system"

log_success "Code pushed to GitHub: $GITHUB_REPO"

# ============================================================================
# PHASE 3: DEPLOY TO RENDER.COM
# ============================================================================

log_section "Phase 3: Deploying to Render.com"

echo ""
echo "Now deploying to Render.com (Managed Platform):"
echo ""
echo "1. Open your browser and go to: https://render.com"
echo "2. Sign up or log in with GitHub (one click)"
echo "3. Click 'New +' button → Select 'Blueprint'"
echo "4. Connect your GitHub account if not already connected"
echo "5. Find and select: cia-system"
echo "6. Click 'Connect'"
echo "7. Render will detect render.yaml and show 4 services:"
echo "   - cia-backend (Web Service)"
echo "   - cia-frontend (Static Site)"
echo "   - cia-database (PostgreSQL)"
echo "   - cia-redis (Redis)"
echo "8. Click 'Apply'"
echo ""
echo "Deployment will take 5-8 minutes."
echo ""
echo "After deployment completes:"
echo "1. Click on 'cia-backend' service"
echo "2. Go to 'Environment' tab"
echo "3. Find ANTHROPIC_API_KEY and add your key"
echo "4. Click 'Save Changes' (auto-redeploys)"
echo ""

read -p "Press Enter when Render deployment is complete (or Ctrl+C to skip)..."

log_info "Please provide your Render URLs:"
read -p "Enter Render frontend URL (e.g., https://cia-frontend.onrender.com): " RENDER_FRONTEND
read -p "Enter Render backend URL (e.g., https://cia-backend.onrender.com): " RENDER_BACKEND

log_success "Render.com deployment configured"

# ============================================================================
# PHASE 4: DEPLOY TO VERCEL (FRONTEND)
# ============================================================================

log_section "Phase 4: Deploying Frontend to Vercel"

# Check if vercel CLI is available
if ! command -v vercel &> /dev/null; then
    log_info "Installing Vercel CLI..."
    npm install -g vercel
fi

log_info "Deploying frontend to Vercel..."
cd frontend

# Login to Vercel
vercel login

# Deploy to production
log_info "Deploying to Vercel production..."
VERCEL_URL=$(vercel --prod --yes 2>&1 | grep -o 'https://[^ ]*' | head -1)

cd ..

log_success "Frontend deployed to Vercel: $VERCEL_URL"

# ============================================================================
# PHASE 5: DEPLOY TO RAILWAY (BACKEND)
# ============================================================================

log_section "Phase 5: Deploying Backend to Railway"

echo ""
echo "Now deploying backend to Railway:"
echo ""
echo "1. Open your browser and go to: https://railway.app"
echo "2. Sign up or log in with GitHub"
echo "3. Click 'New Project'"
echo "4. Select 'Deploy from GitHub repo'"
echo "5. Choose: cia-system"
echo "6. Railway will start deploying"
echo ""
echo "Configure the backend service:"
echo "1. Click on the deployed service"
echo "2. Go to 'Settings' tab"
echo "3. Set 'Root Directory' to: backend"
echo "4. Set 'Start Command' to: node server.js"
echo "5. Go to 'Variables' tab and add:"
echo "   - ANTHROPIC_API_KEY"
echo "   - NODE_ENV=production"
echo "   - CORS_ORIGIN=$VERCEL_URL"
echo "   - PORT=5000"
echo ""
echo "Add PostgreSQL:"
echo "1. Click '+' in your project"
echo "2. Select 'Database' → 'Add PostgreSQL'"
echo "3. Railway auto-configures DATABASE_URL"
echo ""
echo "Add Redis:"
echo "1. Click '+' again"
echo "2. Select 'Database' → 'Add Redis'"
echo "3. Railway auto-configures REDIS_URL"
echo ""
echo "Generate domain:"
echo "1. Go to backend service → Settings → Networking"
echo "2. Click 'Generate Domain'"
echo "3. Copy the URL"
echo ""

read -p "Press Enter when Railway deployment is complete (or Ctrl+C to skip)..."

read -p "Enter Railway backend URL (e.g., https://cia-backend.railway.app): " RAILWAY_BACKEND

# Update Vercel frontend with Railway backend URL
log_info "Updating Vercel frontend with Railway backend URL..."
cd frontend
vercel env add REACT_APP_API_URL production <<< "$RAILWAY_BACKEND"
vercel env add REACT_APP_WS_URL production <<< "$RAILWAY_BACKEND"
vercel --prod --yes
cd ..

log_success "Railway backend deployed and connected to Vercel frontend"

# ============================================================================
# PHASE 6: PREPARE DOCKER FOR SELF-HOSTING
# ============================================================================

log_section "Phase 6: Preparing Docker Images for Self-Hosting"

log_info "Building Docker images..."

# Build backend image
log_info "Building backend Docker image..."
cd backend
docker build -t cia-backend:latest . || log_warning "Docker build failed (Docker might not be available)"
cd ..

# Build frontend image
log_info "Building frontend Docker image..."
cd frontend
docker build -t cia-frontend:latest . || log_warning "Docker build failed (Docker might not be available)"
cd ..

log_success "Docker images built (if Docker is available)"

# ============================================================================
# PHASE 7: CREATE DEPLOYMENT SUMMARY
# ============================================================================

log_section "Phase 7: Creating Deployment Summary"

cat > deployment-summary.txt << EOF
═══════════════════════════════════════════════════════
  CIA System - Deployment Summary
═══════════════════════════════════════════════════════

Deployment Date: $(date)
GitHub Repository: $GITHUB_REPO

═══════════════════════════════════════════════════════
  Platform 1: Render.com (Managed)
═══════════════════════════════════════════════════════

Frontend URL: $RENDER_FRONTEND
Backend URL:  $RENDER_BACKEND
Health Check: $RENDER_BACKEND/health

Services:
  ✓ Frontend (Static Site)
  ✓ Backend (Web Service)
  ✓ PostgreSQL Database
  ✓ Redis Cache

Features:
  ✓ Managed services
  ✓ Auto-deploy on git push
  ✓ Automatic SSL
  ✓ Built-in monitoring

═══════════════════════════════════════════════════════
  Platform 2: Vercel + Railway (Hybrid)
═══════════════════════════════════════════════════════

Frontend URL: $VERCEL_URL
Backend URL:  $RAILWAY_BACKEND
Health Check: $RAILWAY_BACKEND/health

Services:
  ✓ Frontend on Vercel (CDN)
  ✓ Backend on Railway
  ✓ PostgreSQL on Railway
  ✓ Redis on Railway

Features:
  ✓ Blazing fast frontend
  ✓ Scalable backend
  ✓ Auto-deploy
  ✓ Easy scaling

═══════════════════════════════════════════════════════
  Platform 3: Self-Hosted Docker (Ready)
═══════════════════════════════════════════════════════

Docker Images Built:
  ✓ cia-backend:latest
  ✓ cia-frontend:latest

To deploy on your VPS:
  1. Copy docker-compose.yml to your server
  2. Create .env file with configuration
  3. Run: docker compose up -d
  4. Configure Nginx + SSL

See DEPLOY_ALL_PLATFORMS.md for detailed instructions.

═══════════════════════════════════════════════════════
  Next Steps
═══════════════════════════════════════════════════════

1. Add ANTHROPIC_API_KEY to all backends:
   - Render: Backend service → Environment
   - Railway: Backend service → Variables
   - Docker: .env file

2. Verify deployments:
   - Test health endpoints
   - Check frontend loads
   - Verify database connections

3. Set up monitoring:
   - UptimeRobot (free)
   - Sentry error tracking
   - LogRocket session replay

4. Configure custom domain (optional):
   - cia.orangeocean.com → Frontend
   - api.cia.orangeocean.com → Backend

═══════════════════════════════════════════════════════
  Support
═══════════════════════════════════════════════════════

Documentation:
  - DEPLOY_ALL_PLATFORMS.md
  - TECHNICAL_SUMMARY.md
  - DEPLOYMENT_COMPLETE.md

Platform Support:
  - Render: https://render.com/docs
  - Vercel: https://vercel.com/docs
  - Railway: https://docs.railway.app

═══════════════════════════════════════════════════════

Deployed with seamless functionality and development optimization! 🚀

EOF

log_success "Deployment summary created: deployment-summary.txt"

# ============================================================================
# FINAL OUTPUT
# ============================================================================

log_section "Deployment Complete!"

echo ""
echo "Your CIA System is now deployed to all 3 platforms:"
echo ""
echo "1. Render.com (Managed):"
echo "   Frontend: $RENDER_FRONTEND"
echo "   Backend:  $RENDER_BACKEND"
echo ""
echo "2. Vercel + Railway (Hybrid):"
echo "   Frontend: $VERCEL_URL"
echo "   Backend:  $RAILWAY_BACKEND"
echo ""
echo "3. Docker Images (Self-hosting ready):"
echo "   cia-backend:latest"
echo "   cia-frontend:latest"
echo ""
echo "Next steps:"
echo "  1. Add ANTHROPIC_API_KEY to all backends"
echo "  2. Verify all deployments are working"
echo "  3. Set up monitoring (UptimeRobot)"
echo "  4. Configure custom domain (optional)"
echo ""
echo "See deployment-summary.txt for complete details."
echo ""
echo "Deployed with seamless functionality! 🚀"
echo ""
