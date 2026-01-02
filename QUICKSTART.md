# 🚀 CIA System - 5-Minute Quick Start

Get the CIA system running locally in under 5 minutes for testing and evaluation.

## Prerequisites Check

Run these commands to verify you have everything:

```bash
node --version    # Should be >= 18.x
npm --version     # Should be >= 9.x
docker --version  # Should be installed
```

Don't have these? See SETUP_GUIDE.md for installation instructions.

## Step 1: Start Databases (1 minute)

```bash
cd CIA-System
docker-compose up -d postgres redis
```

Wait 10 seconds for databases to initialize:
```bash
sleep 10
docker-compose ps  # Both should show "Up"
```

## Step 2: Setup Database Schema (1 minute)

```bash
docker-compose exec postgres psql -U cia_user -d cia_db -f /docker-entrypoint-initdb.d/01-schema.sql
```

Expected output: Multiple "CREATE TABLE" messages

## Step 3: Configure Minimum Environment (1 minute)

```bash
cd backend
cat > .env << 'EOF'
NODE_ENV=development
PORT=5000
DATABASE_URL=postgresql://cia_user:cia_password_change_me@localhost:5432/cia_db
REDIS_URL=redis://localhost:6379

# Add your Anthropic API key here:
ANTHROPIC_API_KEY=sk-ant-api03-your-key-here

# Optional - add later for full functionality:
SLACK_BOT_TOKEN=xoxb-your-token
ACCELO_CLIENT_ID=your-client-id
EOF
```

**Edit `.env`** and add your real Anthropic API key.

## Step 4: Install & Start Backend (1 minute)

```bash
npm install
npm run dev
```

Expected output:
```
🚀 CIA System API Server running on http://0.0.0.0:5000
✅ Database connection established
```

Keep this terminal open!

## Step 5: Test the System (1 minute)

Open a new terminal:

```bash
# Test health check
curl http://localhost:5000/health

# Expected response:
# {"status":"healthy","timestamp":"...","uptime":...}

# Test AI engine (if you have API key)
curl -X POST http://localhost:5000/api/test/ai \
  -H "Content-Type: application/json" \
  -d '{"test": "Hello CIA"}'
```

## 🎉 Success!

Your CIA system is running! Here's what you can do now:

### Test the Heads-Up Display

Simulate an incoming Zoom call:

```bash
curl -X POST http://localhost:5000/webhooks/zoom/events \
  -H "Content-Type: application/json" \
  -d '{
    "event": "meeting.started",
    "payload": {
      "participant": {"email": "test@example.com"},
      "object": {"id": "123", "topic": "Test Call"}
    }
  }'
```

### Access API Documentation

Open in browser: http://localhost:5000/api/docs

### View Logs

```bash
tail -f logs/app.log
```

### Check System Health

```bash
curl http://localhost:5000/health/integrations
```

## Next Steps

### 1. Add More Integrations

Edit `backend/.env` and add your API keys for:
- Slack Bot Token
- Accelo Credentials
- Google Analytics
- Fireflies API Key

Then restart the backend:
```bash
# In backend terminal, press Ctrl+C
npm run dev
```

### 2. Load Sample Data

```bash
psql -U cia_user -d cia_db << 'EOF'
-- Add a test client
INSERT INTO clients (accelo_id, name, industry, communication_style, emotional_trigger)
VALUES ('test-001', 'Acme Corporation', 'Technology', 'direct', 'growth');

-- Add a test contact
INSERT INTO contacts (client_id, accelo_id, first_name, last_name, email, is_primary)
VALUES (
  (SELECT id FROM clients WHERE accelo_id = 'test-001'),
  'contact-001',
  'John',
  'Doe',
  'john@acme.com',
  true
);
EOF
```

### 3. Start the Frontend Dashboard
```bash
# New terminal
cd frontend
npm install
npm start
```

Dashboard will open at: http://localhost:3000

### 4. Test Slack Integration

If you added Slack credentials:

1. Invite the bot to a channel: `/invite @CIA System`
2. Test the command: `/cia Acme Corporation`

## 🐛 Troubleshooting

### "Port 5000 already in use"
```bash
lsof -i :5000
kill -9 <PID>
```

### "Database connection failed"
```bash
docker-compose ps  # Check postgres is running
docker-compose logs postgres  # Check for errors
```

### "Redis connection failed"
```bash
docker-compose exec redis redis-cli ping
# Should return: PONG
```

### "Cannot find module"
```bash
cd backend
rm -rf node_modules package-lock.json
npm install
```

## 📚 Full Documentation

Once you have the basics working, dive deeper:

1. **README.md** - System architecture and overview
2. **SETUP_GUIDE.md** - Complete setup with all integrations (15 pages)
3. **IMPLEMENTATION_SUMMARY.md** - Full feature list and customization guide

## 💡 Testing Tips

### Test Without Real Integrations

The system works with just Anthropic API key. You can:
- Test AI generation endpoints
- Explore database schema
- Test webhook receivers (they'll log but not send to Slack)
- Use API directly without Slack

### Mock Data Mode

Set in backend/.env:
```env
USE_MOCK_DATA=true
```

This will use sample data instead of calling real APIs.

## 🎯 What's Working

Even with minimal setup, you have:

✅ Full API server with all routes  
✅ Complete database with sample data  
✅ AI engine ready to generate insights  
✅ Webhook receivers ready for testing  
✅ Health monitoring and logging  
✅ Real-time WebSocket support  

## 🚀 Ready for More?


1. **Connect your CRM**: Add Accelo credentials
2. **Enable Slack**: Create a Slack app and add bot token
3. **Add Analytics**: Set up Google Analytics integration
4. **Deploy to Cloud**: See SETUP_GUIDE.md for deployment options

---

**Need Help?**

Check the logs:
```bash
# Application logs
tail -f backend/logs/app.log

# Error logs only
tail -f backend/logs/error.log

# All docker services
docker-compose logs -f
```

**Stuck?** Review the full SETUP_GUIDE.md for detailed troubleshooting.