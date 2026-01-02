#!/bin/bash

# CIA System - Automated Deployment to Render.com
# This script helps you deploy the CIA System to Render with one command

set -e

echo "=================================================="
echo "CIA System - Render.com Deployment Script"
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}GitHub CLI not found. Installing...${NC}"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh -y
fi

echo -e "${BLUE}Step 1: GitHub Authentication${NC}"
echo "Please authenticate with GitHub..."
gh auth login

echo ""
echo -e "${BLUE}Step 2: Create GitHub Repository${NC}"
read -p "Enter repository name (default: cia-system): " REPO_NAME
REPO_NAME=${REPO_NAME:-cia-system}

echo "Creating repository: $REPO_NAME"
gh repo create $REPO_NAME --public --source=. --remote=origin --push

echo ""
echo -e "${GREEN}✓ Repository created and code pushed!${NC}"
echo ""

echo -e "${BLUE}Step 3: Deploy to Render${NC}"
echo ""
echo "Now, follow these steps to deploy on Render.com:"
echo ""
echo "1. Go to: https://render.com"
echo "2. Sign up/Login with GitHub"
echo "3. Click 'New +' → 'Blueprint'"
echo "4. Connect your repository: $REPO_NAME"
echo "5. Render will detect render.yaml and create all services"
echo "6. Add environment variable: ANTHROPIC_API_KEY"
echo "7. Click 'Apply' to deploy"
echo ""
echo -e "${YELLOW}Important: Add these environment variables in Render:${NC}"
echo "  - ANTHROPIC_API_KEY: your_anthropic_api_key"
echo "  - (Optional) SLACK_BOT_TOKEN, ACCELO_CLIENT_ID, etc."
echo ""
echo -e "${GREEN}Deployment will take 5-10 minutes.${NC}"
echo ""
echo "Your URLs will be:"
echo "  Frontend: https://cia-frontend.onrender.com"
echo "  Backend: https://cia-backend.onrender.com"
echo ""
echo "=================================================="
echo "Deployment script complete!"
echo "=================================================="
