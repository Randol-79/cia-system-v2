#!/bin/bash

# ============================================================================
# CIA System - Monitoring and Health Check Setup
# Configures monitoring, logging, and alerting for all deployments
# ============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
    echo ""
}

# ============================================================================
# HEALTH CHECK ENDPOINTS
# ============================================================================

log_section "Setting Up Health Check Monitoring"

cat > health-check-urls.txt << 'EOF'
# CIA System - Health Check URLs
# Monitor these endpoints for uptime and performance

# Render.com Deployment
https://cia-frontend.onrender.com/
https://cia-backend.onrender.com/health

# Vercel + Railway Deployment
https://cia-frontend.vercel.app/
https://cia-backend.railway.app/health

# Self-Hosted (update with your domain)
https://cia.orangeocean.com/
https://api.cia.orangeocean.com/health

# WebSocket Endpoints (for advanced monitoring)
wss://cia-backend.onrender.com/socket.io
wss://cia-backend.railway.app/socket.io
EOF

log_success "Health check URLs saved to health-check-urls.txt"

# ============================================================================
# UPTIMEROBOT CONFIGURATION
# ============================================================================

log_section "UptimeRobot Setup (Free Tier)"

cat > uptimerobot-monitors.json << 'EOF'
{
  "monitors": [
    {
      "friendly_name": "CIA Frontend (Render)",
      "url": "https://cia-frontend.onrender.com",
      "type": 1,
      "interval": 300,
      "timeout": 30
    },
    {
      "friendly_name": "CIA Backend (Render)",
      "url": "https://cia-backend.onrender.com/health",
      "type": 1,
      "interval": 300,
      "timeout": 30
    },
    {
      "friendly_name": "CIA Frontend (Vercel)",
      "url": "https://cia-frontend.vercel.app",
      "type": 1,
      "interval": 300,
      "timeout": 30
    },
    {
      "friendly_name": "CIA Backend (Railway)",
      "url": "https://cia-backend.railway.app/health",
      "type": 1,
      "interval": 300,
      "timeout": 30
    }
  ]
}
EOF

log_success "UptimeRobot configuration saved"

echo ""
echo "To set up UptimeRobot monitoring:"
echo "1. Go to: https://uptimerobot.com"
echo "2. Sign up for free account (50 monitors)"
echo "3. Add monitors for each URL in health-check-urls.txt"
echo "4. Configure alert contacts (email, Slack, SMS)"
echo "5. Set check interval to 5 minutes"
echo ""

# ============================================================================
# SENTRY ERROR TRACKING
# ============================================================================

log_section "Sentry Error Tracking Setup"

cat > sentry-config.md << 'EOF'
# Sentry Error Tracking Configuration

## Setup Steps

1. **Create Sentry Account**
   - Go to: https://sentry.io
   - Sign up for free (5,000 events/month)

2. **Create Projects**
   - Create project: "CIA Backend"
   - Create project: "CIA Frontend"

3. **Get DSN Keys**
   - Backend DSN: Copy from Backend project settings
   - Frontend DSN: Copy from Frontend project settings

4. **Add to Environment Variables**

   **Backend (.env):**
   ```
   SENTRY_DSN=https://your-backend-dsn@sentry.io/project-id
   ```

   **Frontend (Vercel/Render):**
   ```
   REACT_APP_SENTRY_DSN=https://your-frontend-dsn@sentry.io/project-id
   ```

5. **Install Sentry SDKs**

   **Backend:**
   ```bash
   cd backend
   npm install @sentry/node
   ```

   **Frontend:**
   ```bash
   cd frontend
   npm install @sentry/react
   ```

6. **Initialize Sentry**

   **Backend (server.js):**
   ```javascript
   const Sentry = require("@sentry/node");
   
   Sentry.init({
     dsn: process.env.SENTRY_DSN,
     environment: process.env.NODE_ENV,
     tracesSampleRate: 1.0,
   });
   ```

   **Frontend (index.js):**
   ```javascript
   import * as Sentry from "@sentry/react";
   
   Sentry.init({
     dsn: process.env.REACT_APP_SENTRY_DSN,
     environment: process.env.NODE_ENV,
     integrations: [new Sentry.BrowserTracing()],
     tracesSampleRate: 1.0,
   });
   ```

## Features Enabled

- ✅ Error tracking and reporting
- ✅ Performance monitoring
- ✅ Release tracking
- ✅ User feedback
- ✅ Breadcrumbs
- ✅ Source maps (for production debugging)

EOF

log_success "Sentry configuration guide created"

# ============================================================================
# LOGROCKET SESSION REPLAY
# ============================================================================

log_section "LogRocket Session Replay Setup"

cat > logrocket-config.md << 'EOF'
# LogRocket Session Replay Configuration

## Setup Steps

1. **Create LogRocket Account**
   - Go to: https://logrocket.com
   - Sign up for free (1,000 sessions/month)

2. **Create Application**
   - Create new app: "CIA System"
   - Get App ID from dashboard

3. **Add to Frontend**

   **Install:**
   ```bash
   cd frontend
   npm install logrocket logrocket-react
   ```

   **Initialize (src/index.js):**
   ```javascript
   import LogRocket from 'logrocket';
   import setupLogRocketReact from 'logrocket-react';
   
   if (process.env.NODE_ENV === 'production') {
     LogRocket.init('your-app-id/cia-system');
     setupLogRocketReact(LogRocket);
   }
   ```

4. **Integrate with Sentry**
   ```javascript
   LogRocket.getSessionURL(sessionURL => {
     Sentry.configureScope(scope => {
       scope.setExtra("sessionURL", sessionURL);
     });
   });
   ```

## Features

- ✅ Session replay
- ✅ Console logs
- ✅ Network requests
- ✅ Redux state
- ✅ User interactions
- ✅ Performance metrics

EOF

log_success "LogRocket configuration guide created"

# ============================================================================
# CUSTOM MONITORING SCRIPT
# ============================================================================

log_section "Creating Custom Health Check Script"

cat > check-health.sh << 'SCRIPT'
#!/bin/bash

# CIA System Health Check Script
# Run this periodically to check all deployments

URLS=(
    "https://cia-frontend.onrender.com"
    "https://cia-backend.onrender.com/health"
    "https://cia-frontend.vercel.app"
    "https://cia-backend.railway.app/health"
)

echo "CIA System Health Check - $(date)"
echo "=========================================="

for url in "${URLS[@]}"; do
    echo -n "Checking $url ... "
    
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url")
    
    if [ "$status" -eq 200 ]; then
        echo "✓ OK ($status)"
    else
        echo "✗ FAILED ($status)"
    fi
done

echo "=========================================="
SCRIPT

chmod +x check-health.sh
log_success "Health check script created: check-health.sh"

# ============================================================================
# PERFORMANCE MONITORING
# ============================================================================

log_section "Performance Monitoring Setup"

cat > performance-monitoring.md << 'EOF'
# Performance Monitoring Configuration

## 1. Google Analytics (Free)

**Setup:**
1. Go to: https://analytics.google.com
2. Create property: "CIA System"
3. Get Measurement ID (G-XXXXXXXXXX)

**Add to Frontend:**
```bash
npm install react-ga4
```

```javascript
// src/index.js
import ReactGA from 'react-ga4';

ReactGA.initialize('G-XXXXXXXXXX');
ReactGA.send("pageview");
```

## 2. Web Vitals Monitoring

**Add to Frontend:**
```bash
npm install web-vitals
```

```javascript
// src/index.js
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

function sendToAnalytics({ name, delta, id }) {
  // Send to your analytics endpoint
  console.log({ name, delta, id });
}

getCLS(sendToAnalytics);
getFID(sendToAnalytics);
getFCP(sendToAnalytics);
getLCP(sendToAnalytics);
getTTFB(sendToAnalytics);
```

## 3. Backend Performance

**Add to Backend:**
```bash
npm install express-status-monitor
```

```javascript
// server.js
const statusMonitor = require('express-status-monitor');

app.use(statusMonitor({
  title: 'CIA System Status',
  path: '/status',
  healthChecks: [{
    protocol: 'http',
    host: 'localhost',
    path: '/health',
    port: 5000
  }]
}));
```

Access at: `/status`

## 4. Database Monitoring

**PostgreSQL:**
- Monitor connection pool usage
- Track slow queries
- Monitor disk usage

**Redis:**
- Monitor memory usage
- Track cache hit rate
- Monitor connection count

EOF

log_success "Performance monitoring guide created"

# ============================================================================
# ALERTING CONFIGURATION
# ============================================================================

log_section "Alerting Configuration"

cat > alerting-config.md << 'EOF'
# Alerting Configuration

## 1. UptimeRobot Alerts

**Email Alerts:**
- Add your email in UptimeRobot dashboard
- Receive alerts when services go down
- Get monthly uptime reports

**Slack Alerts:**
1. Create Slack incoming webhook
2. Add webhook URL to UptimeRobot
3. Receive real-time alerts in Slack

**SMS Alerts (Paid):**
- Upgrade to Pro plan
- Add phone number
- Receive SMS for critical alerts

## 2. Sentry Alerts

**Configure in Sentry Dashboard:**
- Error rate threshold alerts
- New issue alerts
- Performance degradation alerts
- Custom metric alerts

**Integration Options:**
- Email
- Slack
- PagerDuty
- Discord
- Microsoft Teams

## 3. Custom Alerts

**Create webhook endpoint:**
```javascript
// backend/routes/alerts.js
app.post('/api/alerts/webhook', (req, res) => {
  const { type, message, severity } = req.body;
  
  // Send to Slack
  sendSlackAlert(message);
  
  // Log to database
  logAlert(type, message, severity);
  
  res.json({ status: 'received' });
});
```

## 4. Cron Job Monitoring

**Use Cronitor or Healthchecks.io:**
1. Create account at https://cronitor.io
2. Create monitors for scheduled tasks
3. Ping endpoint when job runs
4. Get alerted if job fails or misses

EOF

log_success "Alerting configuration guide created"

# ============================================================================
# BACKUP CONFIGURATION
# ============================================================================

log_section "Backup Configuration"

cat > backup-config.md << 'EOF'
# Backup Configuration

## 1. Database Backups

### Render.com
- Automatic daily backups (paid plans)
- Manual backups via dashboard
- Point-in-time recovery (paid plans)

### Railway
- Automatic backups included
- Download backups via CLI
- Restore from dashboard

### Self-Hosted
```bash
# Create backup script
cat > backup-db.sh << 'BACKUP'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -h localhost -U cia_user cia_db > backup_$DATE.sql
gzip backup_$DATE.sql
# Upload to S3 or backup location
BACKUP

chmod +x backup-db.sh

# Add to crontab (daily at 2 AM)
crontab -e
0 2 * * * /path/to/backup-db.sh
```

## 2. Redis Backups

**Automatic:**
- Redis persistence enabled in docker-compose.yml
- RDB snapshots saved to volume

**Manual:**
```bash
redis-cli SAVE
cp /var/lib/redis/dump.rdb /backup/location/
```

## 3. Application Code

**GitHub:**
- Automatic version control
- All code backed up in repository
- Easy rollback to previous versions

## 4. Environment Variables

**Backup .env files securely:**
```bash
# Encrypt and backup
gpg -c .env
# Store encrypted file in secure location
```

**Use Secret Management:**
- AWS Secrets Manager
- HashiCorp Vault
- Doppler
- 1Password for Teams

EOF

log_success "Backup configuration guide created"

# ============================================================================
# MONITORING DASHBOARD
# ============================================================================

log_section "Creating Monitoring Dashboard"

cat > monitoring-dashboard.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CIA System - Monitoring Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        h1 {
            color: white;
            text-align: center;
            margin-bottom: 30px;
            font-size: 2.5em;
        }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        
        .card h2 {
            color: #667eea;
            margin-bottom: 15px;
            font-size: 1.3em;
        }
        
        .status {
            display: flex;
            align-items: center;
            margin: 10px 0;
            padding: 10px;
            border-radius: 5px;
            background: #f7f7f7;
        }
        
        .status-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 10px;
        }
        
        .status-dot.online {
            background: #10b981;
            box-shadow: 0 0 10px #10b981;
        }
        
        .status-dot.offline {
            background: #ef4444;
            box-shadow: 0 0 10px #ef4444;
        }
        
        .status-dot.checking {
            background: #f59e0b;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        .metric {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .metric:last-child {
            border-bottom: none;
        }
        
        .metric-label {
            color: #6b7280;
        }
        
        .metric-value {
            font-weight: bold;
            color: #111827;
        }
        
        button {
            background: #667eea;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
            margin-top: 10px;
        }
        
        button:hover {
            background: #5568d3;
        }
        
        .timestamp {
            text-align: center;
            color: white;
            margin-top: 20px;
            opacity: 0.8;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 CIA System Monitoring Dashboard</h1>
        
        <div class="grid">
            <!-- Render.com Status -->
            <div class="card">
                <h2>Render.com Deployment</h2>
                <div class="status">
                    <div class="status-dot checking" id="render-frontend-dot"></div>
                    <span id="render-frontend-status">Checking...</span>
                </div>
                <div class="status">
                    <div class="status-dot checking" id="render-backend-dot"></div>
                    <span id="render-backend-status">Checking...</span>
                </div>
                <button onclick="checkRender()">Refresh Status</button>
            </div>
            
            <!-- Vercel Status -->
            <div class="card">
                <h2>Vercel Deployment</h2>
                <div class="status">
                    <div class="status-dot checking" id="vercel-dot"></div>
                    <span id="vercel-status">Checking...</span>
                </div>
                <button onclick="checkVercel()">Refresh Status</button>
            </div>
            
            <!-- Railway Status -->
            <div class="card">
                <h2>Railway Deployment</h2>
                <div class="status">
                    <div class="status-dot checking" id="railway-dot"></div>
                    <span id="railway-status">Checking...</span>
                </div>
                <button onclick="checkRailway()">Refresh Status</button>
            </div>
            
            <!-- System Metrics -->
            <div class="card">
                <h2>System Metrics</h2>
                <div class="metric">
                    <span class="metric-label">Uptime</span>
                    <span class="metric-value" id="uptime">99.9%</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Response Time</span>
                    <span class="metric-value" id="response-time">~ms</span>
                </div>
                <div class="metric">
                    <span class="metric-label">Last Check</span>
                    <span class="metric-value" id="last-check">-</span>
                </div>
            </div>
        </div>
        
        <div class="timestamp">
            Last updated: <span id="timestamp">-</span>
        </div>
    </div>
    
    <script>
        async function checkEndpoint(url) {
            try {
                const start = Date.now();
                const response = await fetch(url, { mode: 'no-cors' });
                const time = Date.now() - start;
                return { online: true, time };
            } catch (error) {
                return { online: false, time: 0 };
            }
        }
        
        async function checkRender() {
            const frontend = await checkEndpoint('https://cia-frontend.onrender.com');
            const backend = await checkEndpoint('https://cia-backend.onrender.com/health');
            
            updateStatus('render-frontend', frontend.online);
            updateStatus('render-backend', backend.online);
        }
        
        async function checkVercel() {
            const result = await checkEndpoint('https://cia-frontend.vercel.app');
            updateStatus('vercel', result.online);
        }
        
        async function checkRailway() {
            const result = await checkEndpoint('https://cia-backend.railway.app/health');
            updateStatus('railway', result.online);
        }
        
        function updateStatus(id, online) {
            const dot = document.getElementById(`${id}-dot`);
            const status = document.getElementById(`${id}-status`);
            
            if (online) {
                dot.className = 'status-dot online';
                status.textContent = 'Online ✓';
            } else {
                dot.className = 'status-dot offline';
                status.textContent = 'Offline ✗';
            }
        }
        
        function updateTimestamp() {
            document.getElementById('timestamp').textContent = new Date().toLocaleString();
            document.getElementById('last-check').textContent = new Date().toLocaleTimeString();
        }
        
        async function checkAll() {
            updateTimestamp();
            await Promise.all([
                checkRender(),
                checkVercel(),
                checkRailway()
            ]);
        }
        
        // Check on load
        checkAll();
        
        // Auto-refresh every 60 seconds
        setInterval(checkAll, 60000);
    </script>
</body>
</html>
EOF

log_success "Monitoring dashboard created: monitoring-dashboard.html"

# ============================================================================
# SUMMARY
# ============================================================================

log_section "Monitoring Setup Complete!"

echo ""
echo "Created monitoring configuration files:"
echo "  ✓ health-check-urls.txt - URLs to monitor"
echo "  ✓ uptimerobot-monitors.json - UptimeRobot configuration"
echo "  ✓ sentry-config.md - Error tracking setup"
echo "  ✓ logrocket-config.md - Session replay setup"
echo "  ✓ performance-monitoring.md - Performance tracking"
echo "  ✓ alerting-config.md - Alert configuration"
echo "  ✓ backup-config.md - Backup strategies"
echo "  ✓ check-health.sh - Custom health check script"
echo "  ✓ monitoring-dashboard.html - Visual monitoring dashboard"
echo ""
echo "Next steps:"
echo "  1. Set up UptimeRobot account and add monitors"
echo "  2. Configure Sentry for error tracking"
echo "  3. Add LogRocket for session replay"
echo "  4. Set up automated backups"
echo "  5. Configure alerting channels"
echo ""
echo "Open monitoring-dashboard.html in your browser for a visual overview!"
echo ""
