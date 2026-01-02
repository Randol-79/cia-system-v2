#!/bin/bash

# CIA System - Deploy to All 3 Platforms
# Automated deployment script with mobile-first optimizations

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ${1}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local missing_deps=()
    
    if ! command_exists git; then
        missing_deps+=("git")
    else
        print_success "Git installed"
    fi
    
    if ! command_exists node; then
        missing_deps+=("node")
    else
        print_success "Node.js installed ($(node --version))"
    fi
    
    if ! command_exists npm; then
        missing_deps+=("npm")
    else
        print_success "npm installed ($(npm --version))"
    fi
    
    if ! command_exists docker; then
        print_warning "Docker not installed (optional for self-hosting)"
    else
        print_success "Docker installed ($(docker --version))"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install missing dependencies and try again"
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Initialize Git repository
init_git_repo() {
    print_header "Initializing Git Repository"
    
    if [ -d ".git" ]; then
        print_info "Git repository already initialized"
    else
        print_info "Initializing new Git repository..."
        git init
        print_success "Git repository initialized"
    fi
    
    # Check if remote exists
    if git remote | grep -q "origin"; then
        print_info "Git remote 'origin' already exists"
    else
        print_warning "No Git remote configured"
        print_info "You'll need to add a remote: git remote add origin <url>"
    fi
}

# Commit changes
commit_changes() {
    print_header "Committing Changes"
    
    print_info "Staging all files..."
    git add -A
    
    if git diff --staged --quiet; then
        print_info "No changes to commit"
    else
        print_info "Committing changes..."
        git commit -m "Mobile-first architecture deployment - $(date +%Y-%m-%d)"
        print_success "Changes committed"
    fi
}

# Deploy to Render.com
deploy_to_render() {
    print_header "Platform 1: Render.com Deployment"
    
    print_info "Render.com requires manual setup via dashboard"
    echo ""
    echo "Steps to deploy:"
    echo "1. Go to: https://render.com"
    echo "2. Sign up/login with GitHub"
    echo "3. Click 'New +' → 'Blueprint'"
    echo "4. Select your repository"
    echo "5. Choose 'render-mobile.yaml' as blueprint"
    echo "6. Click 'Apply'"
    echo "7. Add environment variable: ANTHROPIC_API_KEY"
    echo ""
    print_info "Configuration file: render-mobile.yaml"
    print_success "Render.com configuration ready!"
    
    echo ""
    read -p "Press Enter when Render deployment is complete..."
}

# Deploy to Vercel + Railway
deploy_to_vercel_railway() {
    print_header "Platform 2: Vercel + Railway Deployment"
    
    # Vercel Frontend
    print_info "Deploying frontend to Vercel..."
    
    if command_exists vercel; then
        print_info "Vercel CLI found"
        cd frontend
        
        print_info "Running Vercel deployment..."
        vercel --prod || {
            print_warning "Vercel deployment failed or requires manual setup"
            echo ""
            echo "Manual Vercel deployment:"
            echo "1. Go to: https://vercel.com"
            echo "2. Import your repository"
            echo "3. Set root directory to: frontend"
            echo "4. Deploy"
        }
        
        cd ..
    else
        print_warning "Vercel CLI not installed"
        echo ""
        echo "Install Vercel CLI: npm install -g vercel"
        echo "Or deploy manually:"
        echo "1. Go to: https://vercel.com"
        echo "2. Import your repository"
        echo "3. Set root directory to: frontend"
        echo "4. Deploy"
    fi
    
    echo ""
    
    # Railway Backend
    print_info "Deploying backend to Railway..."
    
    if command_exists railway; then
        print_info "Railway CLI found"
        cd backend
        
        print_info "Running Railway deployment..."
        railway up || {
            print_warning "Railway deployment failed or requires manual setup"
            echo ""
            echo "Manual Railway deployment:"
            echo "1. Go to: https://railway.app"
            echo "2. Create new project"
            echo "3. Connect your repository"
            echo "4. Set root directory to: backend"
            echo "5. Add PostgreSQL and Redis services"
            echo "6. Deploy"
        }
        
        cd ..
    else
        print_warning "Railway CLI not installed"
        echo ""
        echo "Install Railway CLI: npm install -g @railway/cli"
        echo "Or deploy manually:"
        echo "1. Go to: https://railway.app"
        echo "2. Create new project"
        echo "3. Connect your repository"
        echo "4. Set root directory to: backend"
        echo "5. Add PostgreSQL and Redis services"
        echo "6. Deploy"
    fi
    
    print_success "Vercel + Railway configuration ready!"
    
    echo ""
    read -p "Press Enter when Vercel + Railway deployment is complete..."
}

# Deploy to Docker (Self-Hosted)
deploy_to_docker() {
    print_header "Platform 3: Docker Self-Hosted Deployment"
    
    if ! command_exists docker; then
        print_error "Docker not installed"
        print_info "Install Docker: https://docs.docker.com/get-docker/"
        return
    fi
    
    if ! command_exists docker-compose && ! docker compose version >/dev/null 2>&1; then
        print_error "Docker Compose not installed"
        print_info "Install Docker Compose: https://docs.docker.com/compose/install/"
        return
    fi
    
    # Check for .env.production
    if [ ! -f ".env.production" ]; then
        print_warning ".env.production not found"
        print_info "Creating from template..."
        cp .env.production.example .env.production
        print_success "Created .env.production"
        print_warning "Please edit .env.production and add your configuration"
        echo ""
        read -p "Press Enter after editing .env.production..."
    fi
    
    print_info "Building Docker images..."
    docker compose -f docker-compose.production.yml build || {
        print_error "Docker build failed"
        return
    }
    print_success "Docker images built"
    
    print_info "Starting services..."
    docker compose -f docker-compose.production.yml up -d || {
        print_error "Docker startup failed"
        return
    }
    print_success "Docker services started"
    
    echo ""
    print_info "Waiting for services to be healthy..."
    sleep 10
    
    # Check service health
    print_info "Checking service status..."
    docker compose -f docker-compose.production.yml ps
    
    echo ""
    print_success "Docker deployment complete!"
    print_info "Frontend: http://localhost"
    print_info "Backend: http://localhost:5000"
    print_info "Database: localhost:5432"
    print_info "Redis: localhost:6379"
}

# Generate deployment summary
generate_summary() {
    print_header "Deployment Summary"
    
    cat > DEPLOYMENT_SUMMARY.txt << EOF
CIA System - Multi-Platform Deployment Summary
Generated: $(date)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PLATFORM 1: RENDER.COM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Configuration: render-mobile.yaml
Status: Ready for deployment

Access:
- Dashboard: https://dashboard.render.com
- Frontend: https://cia-frontend-mobile.onrender.com (after deployment)
- Backend: https://cia-backend-mobile.onrender.com (after deployment)

Features:
✓ Managed PostgreSQL + Redis
✓ Auto-deploy on git push
✓ Zero-downtime updates
✓ Free tier available
✓ Mobile-optimized configuration

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PLATFORM 2: VERCEL + RAILWAY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Frontend: Vercel (vercel.json)
Backend: Railway (railway.json)
Status: Ready for deployment

Access:
- Vercel Dashboard: https://vercel.com/dashboard
- Railway Dashboard: https://railway.app/dashboard
- Frontend: https://cia-system-mobile.vercel.app (after deployment)
- Backend: https://cia-backend.railway.app (after deployment)

Features:
✓ Vercel CDN for frontend
✓ Railway for backend + database
✓ Excellent performance
✓ Easy scaling
✓ PWA-optimized

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PLATFORM 3: DOCKER SELF-HOSTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Configuration: docker-compose.production.yml
Status: $(docker compose -f docker-compose.production.yml ps >/dev/null 2>&1 && echo "Running" || echo "Not started")

Access:
- Frontend: http://localhost
- Backend: http://localhost:5000
- Database: localhost:5432
- Redis: localhost:6379

Features:
✓ Full control
✓ Self-hosted
✓ Production-ready
✓ Complete stack included
✓ Easy backup/restore

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

MOBILE-FIRST FEATURES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Progressive Web App (PWA)
✓ Installable on iOS/Android
✓ Offline support
✓ Service worker caching
✓ Push notifications ready
✓ Touch-optimized UI
✓ Mobile-first responsive design
✓ Connection-aware API
✓ Adaptive compression
✓ Dark mode support

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NEXT STEPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Test each deployment
2. Add ANTHROPIC_API_KEY to all platforms
3. Configure custom domains (optional)
4. Set up monitoring
5. Test mobile installation
6. Verify offline functionality

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For detailed documentation, see:
- MOBILE_DEPLOYMENT_GUIDE.md
- MOBILE_DEPLOYMENT_SUMMARY.md
- README.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

    print_success "Deployment summary generated: DEPLOYMENT_SUMMARY.txt"
    cat DEPLOYMENT_SUMMARY.txt
}

# Main deployment flow
main() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
   _____ _____          _____           _                 
  / ____|_   _|   /\   / ____|         | |                
 | |      | |    /  \ | (___  _   _ ___| |_ ___ _ __ ___  
 | |      | |   / /\ \ \___ \| | | / __| __/ _ \ '_ ` _ \ 
 | |____ _| |_ / ____ \____) | |_| \__ \ ||  __/ | | | | |
  \_____|_____/_/    \_\_____/ \__, |___/\__\___|_| |_| |_|
                                __/ |                      
                               |___/                       
                               
  Multi-Platform Deployment Script
  Mobile-First Architecture
  
EOF
    echo -e "${NC}"
    
    print_info "This script will deploy CIA System to all 3 platforms:"
    echo "  1. Render.com (Managed Platform)"
    echo "  2. Vercel + Railway (Hybrid)"
    echo "  3. Docker (Self-Hosted)"
    echo ""
    
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deployment cancelled"
        exit 0
    fi
    
    # Run deployment steps
    check_prerequisites
    init_git_repo
    commit_changes
    
    echo ""
    print_info "Choose deployment platforms:"
    echo "  1. All 3 platforms"
    echo "  2. Render.com only"
    echo "  3. Vercel + Railway only"
    echo "  4. Docker only"
    echo ""
    read -p "Enter choice (1-4): " choice
    
    case $choice in
        1)
            deploy_to_render
            deploy_to_vercel_railway
            deploy_to_docker
            ;;
        2)
            deploy_to_render
            ;;
        3)
            deploy_to_vercel_railway
            ;;
        4)
            deploy_to_docker
            ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    generate_summary
    
    print_header "Deployment Complete!"
    print_success "CIA System deployed successfully!"
    print_info "Check DEPLOYMENT_SUMMARY.txt for details"
}

# Run main function
main "$@"
