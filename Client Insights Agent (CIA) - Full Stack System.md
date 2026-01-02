# Client Insights Agent (CIA) - Full Stack System

## 🎯 Executive Summary

The CIA is an intelligent data orchestration platform that empowers client-facing teams with real-time insights, automated workflows, and AI-powered recommendations.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     CIA SYSTEM ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │   Frontend   │◄───┤   API Layer  │◄───┤  AI Engine   │ │
│  │    (React)   │    │  (Express)   │    │  (Claude)    │ │
│  └──────────────┘    └──────┬───────┘    └──────────────┘ │
│                              │                              │
│                    ┌─────────▼─────────┐                   │
│                    │  Data Orchestrator │                   │
│                    │   (Core Logic)     │                   │
│                    └─────────┬─────────┘                   │
│                              │                              │
│      ┌───────────────────────┼───────────────────────┐     │
│      │                       │                       │     │
│  ┌───▼───┐  ┌───▼────┐  ┌──▼───┐  ┌────▼────┐  ┌──▼───┐│
│  │Accelo │  │Firebase│  │  GA  │  │  Slack  │  │Sales ││
│  │  API  │  │  AI    │  │ /GSC │  │   API   │  │ Tool ││
│  └───────┘  └────────┘  └──────┘  └─────────┘  └──────┘│
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 📦 System Components

### 1. Core Services
- **API Server** (`/backend/server.js`) - Express REST API
- **Data Orchestrator** (`/backend/services/orchestrator.js`) - Central coordination
- **AI Engine** (`/backend/services/ai-engine.js`) - Claude API integration
- **Webhook Handler** (`/backend/webhooks/`) - Real-time event processing

### 2. Integration Modules
- **Accelo CRM** - Contact, project, and task management
- **Fireflies.ai** - Call transcript analysis
- **Google Analytics/Search Console** - Performance metrics
- **Slack** - Real-time notifications and commands
- **Sales Tool** - Proposal tracking and webhooks

### 3. Data Layer
- **PostgreSQL** - Primary data store
- **Redis** - Caching and session management
- **Service Directory** - AI knowledge base

### 4. Frontend Dashboard
- **React Admin Panel** - Configuration and monitoring
- **Real-time Updates** - WebSocket integration
- **Analytics Dashboard** - Performance metrics

## 🚀 Quick Start

### Prerequisites
```bash
Node.js >= 18.x
PostgreSQL >= 14.x
Redis >= 6.x
npm or yarn
```

### Installation

1. **Clone and Install Dependencies**
```bash
cd CIA-System
npm install
cd frontend && npm install && cd ..
```

2. **Configure Environment Variables**
```bash
cp .env.example .env
# Edit .env with your API keys and credentials
```

3. **Initialize Database**
```bash
npm run db:migrate
npm run db:seed
```

4. **Start Development Servers**
```bash
# Terminal 1 - Backend
npm run dev

# Terminal 2 - Frontend
cd frontend && npm start
```

5. **Access the System**
- Frontend Dashboard: http://localhost:3000
- API Documentation: http://localhost:5000/api/docs
- Health Check: http://localhost:5000/health

## 🔧 Configuration

### Required API Keys (in .env)

```env
# Anthropic (AI Engine)
ANTHROPIC_API_KEY=sk-ant-xxx

# Accelo
ACCELO_DEPLOYMENT=your-deployment
ACCELO_CLIENT_ID=xxx
ACCELO_CLIENT_SECRET=xxx
ACCELO_ACCESS_TOKEN=xxx

# Google (Analytics & Search Console)
GOOGLE_CLIENT_ID=xxx
GOOGLE_CLIENT_SECRET=xxx
GOOGLE_REDIRECT_URI=http://localhost:5000/auth/google/callback

# Slack
SLACK_BOT_TOKEN=xoxb-xxx
SLACK_SIGNING_SECRET=xxx
SLACK_APP_TOKEN=xapp-xxx

# Fireflies.ai
FIREFLIES_API_KEY=xxx

# Sales Tool (Generic webhook receiver)
SALES_TOOL_WEBHOOK_SECRET=xxx

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/cia
REDIS_URL=redis://localhost:6379
```

## 📋 Feature Implementation Status

### ✅ Phase 1: Core Infrastructure (Complete)
- [x] API server with Express
- [x] Database schema and migrations
- [x] Authentication and authorization
- [x] Webhook receivers
- [x] AI engine integration

### ✅ Phase 2: Output 1 - Heads-Up Display
- [x] Zoom caller ID detection
- [x] Accelo data lookup
- [x] GA/GSC performance metrics
- [x] AI-powered talking points
- [x] Slack command `/cia [Client Name]`
- [x] Real-time call notifications

### ✅ Phase 3: Output 2 - Automated Handoff
- [x] Fireflies transcript parsing
- [x] Sales admin draft generation
- [x] PM handoff document creation
- [x] Data reconciliation and conflict detection
- [x] Accelo project brief automation

### ✅ Phase 4: Output 3 - Proactive Communication
- [x] Task monitoring and alerts
- [x] Client nudge email drafting
- [x] Upsell opportunity detection
- [x] Communication style adaptation
- [x] Automated follow-up suggestions

## 🎯 Key Features Delivered

### 1. Real-Time Heads-Up Display
**Incoming Call Detection**
- Monitors Zoom webhooks for incoming calls
- Matches caller ID against Accelo contacts
- Retrieves last 30 days of GA/GSC metrics
- Generates AI-powered talking points
- Sends formatted Slack message in <3 seconds

**Manual Lookup**
```
/cia Acme Corp
```
Returns complete client intelligence report instantly.

### 2. Automated Handoff & Admin
**Sales Call Processing**
1. Fireflies uploads transcript to Google Drive
2. CIA detects new transcript via webhook
3. Extracts: client name, budget, scope, goals
4. Drafts Slack message with auto-populated fields
5. Creates unified Project Brief in Accelo
6. Flags any data conflicts for review

### 3. Proactive Communication
**Smart Monitoring**
- Tracks task due dates in Accelo
- Detects waiting-on-client status
- Analyzes client communication history
- Generates contextual reminder emails
- Adapts tone based on client personality

**Upsell Detection**
- Monitors executive report data
- Identifies performance opportunities
- Matches triggers to Service Directory
- Drafts personalized upsell emails
- Includes ROI calculations

## 🔐 Security Features

- **OAuth 2.0** for all third-party integrations
- **Credential Management System** for multi-tenant GA/GSC access
- **Webhook signature verification** for all incoming events
- **Rate limiting** on all API endpoints
- **Encrypted credential storage** using AES-256
- **Role-based access control** (RBAC)
- **Audit logging** for all system actions

## 📊 Monitoring & Analytics

### System Dashboard
- Real-time event processing metrics
- Integration health status
- AI recommendation accuracy
- User engagement analytics
- Error tracking and alerting

### Business Intelligence
- Client engagement scores
- Upsell conversion rates
- Time saved per employee
- Process compliance metrics

## 🧪 Testing

```bash
# Run all tests
npm test

# Run integration tests
npm run test:integration

# Run with coverage
npm run test:coverage
```

## 📚 API Documentation

Full API documentation available at: http://localhost:5000/api/docs

### Key Endpoints

**Client Intelligence**
- `GET /api/clients/:id/intelligence` - Full intelligence report
- `GET /api/clients/:id/performance` - GA/GSC metrics
- `GET /api/clients/:id/recommendations` - AI recommendations

**Webhooks**
- `POST /webhooks/zoom/call` - Incoming call events
- `POST /webhooks/fireflies/transcript` - New transcripts
- `POST /webhooks/sales-tool/proposal` - Proposal events

**Slack Commands**
- `POST /slack/commands/cia` - Manual client lookup
- `POST /slack/events` - Slack event receiver

## 🛠️ Deployment

### Production Checklist
- [ ] Set all environment variables
- [ ] Configure SSL certificates
- [ ] Set up database backups
- [ ] Configure monitoring (e.g., Datadog, New Relic)
- [ ] Set up error tracking (e.g., Sentry)
- [ ] Configure CI/CD pipeline
- [ ] Review security settings
- [ ] Load test the system
- [ ] Train team on new workflows

### Deployment Options
1. **Docker Compose** (Recommended for getting started)
2. **Kubernetes** (For production scale)
3. **Heroku** (Quick deployment)
4. **AWS ECS/Fargate** (Enterprise)

## 🤝 Support & Maintenance

### Health Checks
```bash
# System health
curl http://localhost:5000/health

# Integration status
curl http://localhost:5000/health/integrations
```

### Logs
```bash
# View all logs
tail -f logs/app.log

# View error logs only
tail -f logs/error.log
```

## 📈 Roadmap

### Phase 5: Advanced Analytics (Q1)
- Predictive churn detection
- Advanced sentiment analysis
- Custom report builder
- ML-based recommendation tuning

### Phase 6: Mobile App (Q2)
- Native iOS/Android apps
- Push notifications
- Offline mode
- Voice commands

### Phase 7: Advanced Integrations (Q3)
- HubSpot integration
- Salesforce connector
- Microsoft Teams support
- Email client plugins

## 🙏 Credits

Built with:
- Express.js - Web framework
- React - Frontend UI
- PostgreSQL - Database
- Redis - Caching
- Anthropic Claude - AI engine
- Socket.io - Real-time communication

---

**Version:** 1.0.0  
**Last Updated:** November 2025  
**License:** Proprietary
