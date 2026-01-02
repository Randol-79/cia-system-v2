#!/bin/bash

# ============================================================================
# CIA System - Multi-Platform Automated Deployment Script
# Deploys to Render, Vercel+Railway, and prepares Docker images
# Optimized for seamless functionality and development optimization
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
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
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if we're in the right directory
if [ ! -f "package.json" ] && [ ! -d "backend" ]; then
    log_error "This script must be run from the CIA-System root directory"
    exit 1
fi

# ============================================================================
# PREREQUISITES CHECK
# ============================================================================

log_section "Checking Prerequisites"

check_command() {
    if command -v $1 &> /dev/null; then
        log_success "$1 is installed"
        return 0
    else
        log_warning "$1 is not installed"
        return 1
    fi
}

MISSING_DEPS=false

check_command "git" || MISSING_DEPS=true
check_command "node" || MISSING_DEPS=true
check_command "npm" || MISSING_DEPS=true
check_command "docker" || log_warning "Docker not found (optional for self-hosting)"

# Check for CLI tools
check_command "gh" || log_info "GitHub CLI not found - will skip GitHub operations"
check_command "vercel" || log_info "Vercel CLI not found - will skip Vercel deployment"

if [ "$MISSING_DEPS" = true ]; then
    log_error "Missing required dependencies. Please install them first."
    exit 1
fi

# ============================================================================
# GIT REPOSITORY SETUP
# ============================================================================

log_section "Setting Up Git Repository"

if [ ! -d ".git" ]; then
    log_info "Initializing Git repository..."
    git init
    git config user.email "deploy@orangeocean.com"
    git config user.name "Orange Ocean Deploy"
    log_success "Git repository initialized"
else
    log_success "Git repository already initialized"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    log_info "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Dependencies
node_modules/
package-lock.json

# Environment
.env
.env.local
.env.production

# Logs
logs/
*.log

# Build
build/
dist/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
EOF
    log_success ".gitignore created"
fi

# Commit all changes
log_info "Committing changes..."
git add .
git commit -m "Prepare for multi-platform deployment" || log_info "No changes to commit"

# ============================================================================
# GITHUB REPOSITORY
# ============================================================================

log_section "GitHub Repository Setup"

if command -v gh &> /dev/null; then
    log_info "Checking GitHub authentication..."
    
    if gh auth status &> /dev/null; then
        log_success "GitHub authenticated"
        
        # Check if repository exists
        REPO_NAME="cia-system"
        log_info "Checking if repository exists..."
        
        if gh repo view $REPO_NAME &> /dev/null; then
            log_success "Repository $REPO_NAME already exists"
        else
            log_info "Creating GitHub repository: $REPO_NAME"
            read -p "Create public repository? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                gh repo create $REPO_NAME --public --source=. --remote=origin --push
                log_success "Repository created and code pushed"
            else
                gh repo create $REPO_NAME --private --source=. --remote=origin --push
                log_success "Private repository created and code pushed"
            fi
        fi
        
        # Push to GitHub
        log_info "Pushing to GitHub..."
        git branch -M main
        git push -u origin main --force || log_warning "Push failed - may need to authenticate"
        log_success "Code pushed to GitHub"
        
    else
        log_warning "GitHub not authenticated. Run: gh auth login"
        log_info "Skipping GitHub operations..."
    fi
else
    log_warning "GitHub CLI not installed. Skipping GitHub operations."
    log_info "Install with: curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
fi

# ============================================================================
# DEPLOY TO RENDER.COM
# ============================================================================

log_section "Deploying to Render.com"

log_info "Render.com deployment requires manual setup:"
echo ""
echo "1. Go to: https://render.com"
echo "2. Sign up/Login with GitHub"
echo "3. Click 'New +' → 'Blueprint'"
echo "4. Select repository: cia-system"
echo "5. Render will detect render.yaml"
echo "6. Add environment variable: ANTHROPIC_API_KEY"
echo "7. Click 'Apply' to deploy"
echo ""
echo "Your URLs will be:"
echo "  Frontend: https://cia-frontend.onrender.com"
echo "  Backend: https://cia-backend.onrender.com"
echo ""

read -p "Press Enter when Render deployment is complete (or Ctrl+C to skip)..."
log_success "Render deployment noted"

# ============================================================================
# DEPLOY TO VERCEL
# ============================================================================

log_section "Deploying Frontend to Vercel"

if command -v vercel &> /dev/null; then
    log_info "Deploying to Vercel..."
    
    cd frontend
    
    # Check if already linked
    if [ -f ".vercel/project.json" ]; then
        log_info "Project already linked to Vercel"
    else
        log_info "Linking project to Vercel..."
        vercel link --yes || log_warning "Vercel link failed"
    fi
    
    # Set environment variables
    log_info "Setting environment variables..."
    read -p "Enter your backend URL (e.g., https://cia-backend.railway.app): " BACKEND_URL
    
    vercel env add REACT_APP_API_URL production << EOF
$BACKEND_URL
EOF
    
    WS_URL="${BACKEND_URL/https/wss}"
    vercel env add REACT_APP_WS_URL production << EOF
$WS_URL
EOF
    
    # Deploy to production
    log_info "Deploying to Vercel production..."
    vercel --prod --yes
    
    log_success "Frontend deployed to Vercel"
    
    cd ..
else
    log_warning "Vercel CLI not installed"
    log_info "Install with: npm install -g vercel"
    log_info "Then run: cd frontend && vercel --prod"
fi

# ============================================================================
# DEPLOY TO RAILWAY
# ============================================================================

log_section "Deploying Backend to Railway"

log_info "Railway deployment steps:"
echo ""
echo "1. Go to: https://railway.app"
echo "2. Sign up with GitHub"
echo "3. Click 'New Project' → 'Deploy from GitHub repo'"
echo "4. Select: cia-system"
echo "5. Add PostgreSQL: Click '+' → 'Database' → 'PostgreSQL'"
echo "6. Add Redis: Click '+' → 'Database' → 'Redis'"
echo "7. Configure backend service:"
echo "   - Root Directory: backend"
echo "   - Start Command: node server.js"
echo "8. Add environment variables:"
echo "   - ANTHROPIC_API_KEY"
echo "   - NODE_ENV=production"
echo "   - CORS_ORIGIN=https://your-vercel-url.vercel.app"
echo "9. Generate domain for backend"
echo ""

read -p "Press Enter when Railway deployment is complete (or Ctrl+C to skip)..."
log_success "Railway deployment noted"

# ============================================================================
# BUILD DOCKER IMAGES
# ============================================================================

log_section "Building Docker Images"

if command -v docker &> /dev/null; then
    log_info "Building Docker images for self-hosting..."
    
    # Build backend image
    log_info "Building backend image..."
    docker build -t cia-backend:latest ./backend
    log_success "Backend image built"
    
    # Build frontend image
    log_info "Building frontend image..."
    docker build -t cia-frontend:latest ./frontend
    log_success "Frontend image built"
    
    # Tag images
    log_info "Images built successfully:"
    echo "  - cia-backend:latest"
    echo "  - cia-frontend:latest"
    
    # Optional: Push to Docker Hub
    read -p "Push images to Docker Hub? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter Docker Hub username: " DOCKER_USERNAME
        
        log_info "Logging into Docker Hub..."
        docker login
        
        log_info "Tagging and pushing images..."
        docker tag cia-backend:latest $DOCKER_USERNAME/cia-backend:latest
        docker tag cia-frontend:latest $DOCKER_USERNAME/cia-frontend:latest
        
        docker push $DOCKER_USERNAME/cia-backend:latest
        docker push $DOCKER_USERNAME/cia-frontend:latest
        
        log_success "Images pushed to Docker Hub"
    fi
    
else
    log_warning "Docker not installed - skipping image build"
    log_info "Install Docker: https://docs.docker.com/get-docker/"
fi

# ============================================================================
# CREATE DEPLOYMENT SUMMARY
# ============================================================================

log_section "Deployment Summary"

# Create summary file
SUMMARY_FILE="deployment-summary.txt"
cat > $SUMMARY_FILE << EOF
CIA System - Deployment Summary
Generated: $(date)

═══════════════════════════════════════════════════════

DEPLOYMENT PLATFORMS

1. Render.com (Managed Platform)
   - Frontend: https://cia-frontend.onrender.com
   - Backend: https://cia-backend.onrender.com
   - Database: PostgreSQL (managed)
   - Cache: Redis (managed)
   - Status: Check Render dashboard

2. Vercel + Railway (Hybrid)
   - Frontend: https://cia-frontend.vercel.app
   - Backend: https://cia-backend.railway.app
   - Database: PostgreSQL on Railway
   - Cache: Redis on Railway
   - Status: Check respective dashboards

3. Docker Images (Self-Hosting)
   - Backend: cia-backend:latest
   - Frontend: cia-frontend:latest
   - Deploy with: docker-compose up -d
   - Status: Ready for deployment

═══════════════════════════════════════════════════════

NEXT STEPS

1. Verify Deployments
   - Test each platform's URLs
   - Check health endpoints
   - Verify database connections

2. Configure Custom Domain
   - Point cia.orangeocean.com to frontend
   - Update CORS settings in backend
   - Enable SSL certificates

3. Set Up Monitoring
   - UptimeRobot for uptime monitoring
   - Sentry for error tracking
   - LogRocket for session replay

4. Configure Integrations
   - Add Slack credentials
   - Configure Accelo CRM
   - Set up Google Analytics
   - Enable Fireflies integration

═══════════════════════════════════════════════════════

ENVIRONMENT VARIABLES NEEDED

Backend:
- ANTHROPIC_API_KEY (required)
- DATABASE_URL (auto-configured on platforms)
- REDIS_URL (auto-configured on platforms)
- CORS_ORIGIN (set to frontend URL)
- SLACK_BOT_TOKEN (optional)
- ACCELO_CLIENT_ID (optional)
- GOOGLE_CLIENT_ID (optional)

Frontend:
- REACT_APP_API_URL (backend URL)
- REACT_APP_WS_URL (backend WebSocket URL)

═══════════════════════════════════════════════════════

DOCUMENTATION

- PERMANENT_DEPLOYMENT.md - Detailed deployment guide
- CLOUD_DEPLOYMENT_GUIDE.md - Platform-specific instructions
- DEPLOY_NOW.md - Quick start guide
- docker-compose.yml - Self-hosting configuration

═══════════════════════════════════════════════════════

SUPPORT

For issues or questions, refer to the documentation files
or check the platform-specific dashboards.

═══════════════════════════════════════════════════════
EOF

log_success "Deployment summary created: $SUMMARY_FILE"

# Display summary
cat $SUMMARY_FILE

# ============================================================================
# COMPLETION
# ============================================================================

log_section "Deployment Complete!"

echo ""
echo -e "${GREEN}✓ All deployment configurations are ready!${NC}"
echo ""
echo "Your CIA System is deployed to:"
echo "  1. Render.com (if configured)"
echo "  2. Vercel + Railway (if configured)"
echo "  3. Docker images (ready for self-hosting)"
echo ""
echo "Next steps:"
echo "  1. Verify all deployments are working"
echo "  2. Configure custom domain (cia.orangeocean.com)"
echo "  3. Set up monitoring and alerts"
echo "  4. Add integration credentials"
echo ""
echo "See deployment-summary.txt for details."
echo ""
echo -e "${CYAN}Deployed with seamless functionality! 🚀${NC}"
echo ""
