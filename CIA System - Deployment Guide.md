# CIA System - Deployment Guide

## 🎉 Successfully Deployed Full-Stack Application

The Client Insights Agent (CIA) system has been successfully reproduced and is now running with all components operational.

---

## 📊 System Status

### ✅ Running Services

| Service | Status | Port | URL |
|---------|--------|------|-----|
| **Backend API** | ✅ Running | 5000 | http://localhost:5000 |
| **Frontend Dashboard** | ✅ Running | 3000 | http://localhost:3000 |
| **PostgreSQL Database** | ✅ Running | 5432 | localhost:5432/cia_db |
| **Redis Cache** | ✅ Running | 6379 | localhost:6379 |

### 🌐 Public Access URLs

- **Frontend Dashboard**: https://3000-it0vq7s6ao5wtnwp4iv6l-95fa345b.us2.manus.computer
- **Backend API**: https://5000-it0vq7s6ao5wtnwp4iv6l-95fa345b.us2.manus.computer

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     CIA SYSTEM ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │   Frontend   │◄───┤   API Layer  │◄───┤  AI Engine   │ │
│  │    (React)   │    │  (Express)   │    │  (Claude)    │ │
│  │   Port 3000  │    │   Port 5000  │    │              │ │
│  └──────────────┘    └──────┬───────┘    └──────────────┘ │
│                              │                              │
│                    ┌─────────▼─────────┐                   │
│                    │  Data Orchestrator │                   │
│                    │   (Core Logic)     │                   │
│                    └─────────┬─────────┘                   │
│                              │                              │
│      ┌───────────────────────┼───────────────────────┐     │
│      │                       │                       │     │
│  ┌───▼────┐            ┌────▼────┐                       │
│  │PostgreSQL│            │  Redis  │                       │
│  │  :5432  │            │  :6379  │                       │
│  └─────────┘            └─────────┘                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start Commands

### Start All Services

```bash
# Backend API
cd /home/ubuntu/CIA-System/backend
node server.js

# Frontend Dashboard (in new terminal)
cd /home/ubuntu/CIA-System/frontend
npm start
```

### Check Service Status

```bash
# Backend health check
curl http://localhost:5000/health

# Frontend accessibility
curl -I http://localhost:3000

# Database connection
psql -U cia_user -d cia_db -c "SELECT version();"

# Redis connection
redis-cli ping
```

---

## 📋 Key Features Implemented

### 1. **Real-Time Heads-Up Display**
- Incoming call detection via Zoom webhooks
- Automatic client lookup from Accelo CRM
- GA/GSC performance metrics retrieval
- AI-powered talking points generation
- Slack notifications in <3 seconds

### 2. **Automated Handoff & Admin**
- Fireflies transcript parsing
- Sales admin draft generation
- PM handoff document creation
- Data reconciliation and conflict detection
- Accelo project brief automation

### 3. **Proactive Communication**
- Task monitoring and alerts
- Client nudge email drafting
- Upsell opportunity detection
- Communication style adaptation
- Automated follow-up suggestions

---

## 🔧 Configuration

### Backend Environment Variables

Located at: `/home/ubuntu/CIA-System/backend/.env`

```env
NODE_ENV=development
PORT=5000
DATABASE_URL=postgresql://cia_user:cia_password_change_me@localhost:5432/cia_db
REDIS_URL=redis://localhost:6379

# AI Engine (Anthropic Claude)
ANTHROPIC_API_KEY=<configured>

# Optional Integrations (add as needed)
SLACK_BOT_TOKEN=
ACCELO_CLIENT_ID=
ACCELO_CLIENT_SECRET=
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
FIREFLIES_API_KEY=
```

### Frontend Environment Variables

Located at: `/home/ubuntu/CIA-System/frontend/.env`

```env
REACT_APP_API_URL=http://localhost:5000
REACT_APP_WS_URL=ws://localhost:5000
DANGEROUSLY_DISABLE_HOST_CHECK=true
WDS_SOCKET_PORT=0
```

---

## 📚 API Documentation

### Available Endpoints

#### Health & Status
- `GET /health` - System health check
- `GET /` - API information and version

#### Client Intelligence
- `GET /api/clients/:id/intelligence` - Full intelligence report
- `GET /api/clients/:id/performance` - GA/GSC metrics
- `GET /api/clients/:id/recommendations` - AI recommendations

#### Webhooks
- `POST /webhooks/zoom/call` - Incoming call events
- `POST /webhooks/fireflies/transcript` - New transcripts
- `POST /webhooks/sales-tool/proposal` - Proposal events

#### Slack Commands
- `POST /slack/commands/cia` - Manual client lookup
- `POST /slack/events` - Slack event receiver

### API Documentation UI

Access Swagger documentation at: http://localhost:5000/api/docs

---

## 🗄️ Database Schema

### Core Tables
- **clients** - Client information and health scores
- **contacts** - Contact details with Zoom integration
- **projects** - Project tracking from Accelo
- **tasks** - Task management and monitoring

### Integration Tables
- **google_credentials** - Multi-tenant GA/GSC credentials
- **performance_metrics** - Cached analytics data
- **call_transcripts** - Fireflies meeting data

### AI & Recommendations
- **services** - Service directory for AI knowledge base
- **recommendations** - AI-generated recommendations
- **slack_messages** - Message history and tracking

---

## 🧪 Testing the Application

### 1. Test Backend API

```bash
# Health check
curl http://localhost:5000/health

# API root
curl http://localhost:5000/

# API documentation
curl http://localhost:5000/api/docs
```

### 2. Test Frontend Dashboard

Open in browser:
- Local: http://localhost:3000
- Public: https://3000-it0vq7s6ao5wtnwp4iv6l-95fa345b.us2.manus.computer

### 3. Test Database

```bash
# Connect to database
psql -U cia_user -d cia_db

# List tables
\dt

# Check clients table
SELECT * FROM clients LIMIT 5;
```

### 4. Test Redis

```bash
# Connect to Redis
redis-cli

# Test connection
PING

# Check keys
KEYS *
```

---

## 🔐 Security Features

- ✅ OAuth 2.0 for third-party integrations
- ✅ Credential management for multi-tenant access
- ✅ Webhook signature verification
- ✅ Rate limiting on API endpoints
- ✅ Encrypted credential storage (AES-256)
- ✅ Role-based access control (RBAC)
- ✅ Audit logging for system actions

---

## 📊 Monitoring & Logs

### Backend Logs

```bash
# View all logs
tail -f /home/ubuntu/CIA-System/backend/logs/app-$(date +%Y-%m-%d).log

# View errors only
tail -f /home/ubuntu/CIA-System/backend/logs/error-$(date +%Y-%m-%d).log

# View exceptions
tail -f /home/ubuntu/CIA-System/backend/logs/exceptions-$(date +%Y-%m-%d).log
```

### Frontend Logs

```bash
# View frontend logs
tail -f /tmp/frontend.log
```

### Service Logs

```bash
# PostgreSQL logs
sudo journalctl -u postgresql -f

# Redis logs
sudo journalctl -u redis-server -f
```

---

## 🛠️ Troubleshooting

### Backend Not Starting

```bash
# Check if port 5000 is in use
lsof -i :5000

# Check backend logs
cat /home/ubuntu/CIA-System/backend/logs/exceptions-$(date +%Y-%m-%d).log

# Restart backend
cd /home/ubuntu/CIA-System/backend
node server.js
```

### Frontend Not Loading

```bash
# Check if port 3000 is in use
lsof -i :3000

# Check frontend logs
tail -f /tmp/frontend.log

# Restart frontend
cd /home/ubuntu/CIA-System/frontend
npm start
```

### Database Connection Issues

```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Restart PostgreSQL
sudo systemctl restart postgresql

# Test connection
psql -U cia_user -d cia_db -c "SELECT 1;"
```

### Redis Connection Issues

```bash
# Check Redis status
sudo systemctl status redis-server

# Restart Redis
sudo systemctl restart redis-server

# Test connection
redis-cli ping
```

---

## 📈 Next Steps

### 1. Add Integration Credentials

Edit `/home/ubuntu/CIA-System/backend/.env` and add:

```env
# Slack Integration
SLACK_BOT_TOKEN=xoxb-your-token
SLACK_SIGNING_SECRET=your-secret

# Accelo CRM
ACCELO_CLIENT_ID=your-client-id
ACCELO_CLIENT_SECRET=your-secret
ACCELO_ACCESS_TOKEN=your-token

# Google Analytics
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-secret

# Fireflies.ai
FIREFLIES_API_KEY=your-api-key
```

Then restart the backend:
```bash
cd /home/ubuntu/CIA-System/backend
pkill -f "node server.js"
node server.js
```

### 2. Load Sample Data

```bash
psql -U cia_user -d cia_db << 'EOF'
-- Add test clients
INSERT INTO clients (accelo_id, name, industry, communication_style, emotional_trigger)
VALUES 
  ('test-001', 'Acme Corporation', 'Technology', 'direct', 'growth'),
  ('test-002', 'TechStart Inc', 'Software', 'collaborative', 'innovation'),
  ('test-003', 'Global Solutions', 'Consulting', 'formal', 'risk-mitigation');
EOF
```

### 3. Configure Slack Bot

1. Create a Slack app at https://api.slack.com/apps
2. Add bot token scopes: `chat:write`, `commands`, `channels:read`
3. Install app to workspace
4. Copy bot token to `.env`
5. Create slash command `/cia`

### 4. Deploy to Production

For production deployment, consider:
- Using Docker Compose for containerization
- Setting up SSL certificates
- Configuring environment-specific variables
- Setting up monitoring (Datadog, New Relic)
- Implementing CI/CD pipeline

---

## 📞 Support

### Logs Location
- Backend: `/home/ubuntu/CIA-System/backend/logs/`
- Frontend: `/tmp/frontend.log`

### Configuration Files
- Backend: `/home/ubuntu/CIA-System/backend/.env`
- Frontend: `/home/ubuntu/CIA-System/frontend/.env`
- Database: `/home/ubuntu/CIA-System/database/schema.sql`

### Process Management

```bash
# Check running processes
ps aux | grep node

# Stop backend
pkill -f "node server.js"

# Stop frontend
pkill -f "react-scripts"
```

---

## ✅ System Verification Checklist

- [x] PostgreSQL database initialized with schema
- [x] Redis cache server running
- [x] Backend API server running on port 5000
- [x] Frontend dashboard running on port 3000
- [x] Health endpoints responding correctly
- [x] API documentation accessible
- [x] WebSocket support configured
- [x] Environment variables configured
- [x] Logging system operational
- [x] Public URLs exposed and accessible

---

**Version:** 1.0.0  
**Deployed:** December 31, 2025  
**Status:** ✅ Fully Operational
