-- CIA System Database Schema
-- PostgreSQL 14+

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- CORE TABLES
-- ============================================================================

-- Clients (synchronized from Accelo)
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    accelo_id VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    website VARCHAR(255),
    industry VARCHAR(100),
    status VARCHAR(50) DEFAULT 'active',
    
    -- Communication preferences
    communication_style VARCHAR(50), -- 'nurturing', 'direct', 'data-driven'
    emotional_trigger VARCHAR(100), -- 'growth', 'efficiency', 'security'
    
    -- Performance tracking
    last_contacted_at TIMESTAMP,
    next_review_date DATE,
    health_score INTEGER DEFAULT 50, -- 0-100
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_clients_accelo ON clients(accelo_id);
CREATE INDEX idx_clients_status ON clients(status);
CREATE INDEX idx_clients_health ON clients(health_score);

-- Contacts (key people at client companies)
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    accelo_id VARCHAR(100) UNIQUE,
    
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    role VARCHAR(100),
    
    is_primary BOOLEAN DEFAULT false,
    is_decision_maker BOOLEAN DEFAULT false,
    
    -- Zoom integration
    zoom_user_id VARCHAR(100),
    zoom_email VARCHAR(255),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_contacts_client ON contacts(client_id);
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_contacts_zoom ON contacts(zoom_user_id);

-- Projects (synchronized from Accelo)
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    accelo_id VARCHAR(100) UNIQUE NOT NULL,
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL, -- 'active', 'on-hold', 'completed'
    type VARCHAR(100),
    
    budget DECIMAL(10, 2),
    start_date DATE,
    end_date DATE,
    
    -- Project details
    description TEXT,
    goals TEXT,
    deliverables JSONB,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_projects_client ON projects(client_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_accelo ON projects(accelo_id);

-- Tasks (synchronized from Accelo)
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    accelo_id VARCHAR(100) UNIQUE NOT NULL,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL, -- 'pending', 'in-progress', 'waiting-on-client', 'completed'
    priority VARCHAR(20),
    
    assignee VARCHAR(100),
    due_date DATE,
    completed_at TIMESTAMP,
    
    -- Tracking
    days_waiting INTEGER DEFAULT 0,
    last_nudge_sent_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tasks_project ON tasks(project_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_waiting ON tasks(status, days_waiting) WHERE status = 'waiting-on-client';

-- ============================================================================
-- INTEGRATION TABLES
-- ============================================================================

-- Google Analytics Credentials (multi-tenant)
CREATE TABLE google_credentials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    
    -- Encrypted credentials
    credentials_encrypted TEXT NOT NULL,
    encryption_key_id VARCHAR(100) NOT NULL,
    
    -- Account info
    ga_property_id VARCHAR(100),
    ga4_property_id VARCHAR(100),
    gsc_site_url VARCHAR(255),
    
    -- OAuth tokens (encrypted)
    access_token_encrypted TEXT,
    refresh_token_encrypted TEXT,
    token_expires_at TIMESTAMP,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    last_verified_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_google_creds_client ON google_credentials(client_id);
CREATE INDEX idx_google_creds_active ON google_credentials(is_active);

-- Performance Metrics (cached from GA/GSC)
CREATE TABLE performance_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    
    metric_date DATE NOT NULL,
    period VARCHAR(20) DEFAULT 'daily', -- 'daily', 'weekly', 'monthly'
    
    -- Traffic metrics
    sessions INTEGER,
    users INTEGER,
    pageviews INTEGER,
    bounce_rate DECIMAL(5, 2),
    avg_session_duration INTEGER, -- seconds
    
    -- Conversion metrics
    conversions INTEGER,
    conversion_rate DECIMAL(5, 2),
    revenue DECIMAL(10, 2),
    
    -- SEO metrics
    impressions INTEGER,
    clicks INTEGER,
    ctr DECIMAL(5, 2),
    avg_position DECIMAL(5, 2),
    
    -- Comparison to previous period
    sessions_change_pct DECIMAL(5, 2),
    users_change_pct DECIMAL(5, 2),
    conversions_change_pct DECIMAL(5, 2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id, metric_date, period)
);

CREATE INDEX idx_metrics_client_date ON performance_metrics(client_id, metric_date DESC);

-- Call Transcripts (from Fireflies)
CREATE TABLE call_transcripts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    
    fireflies_id VARCHAR(100) UNIQUE,
    meeting_title VARCHAR(255),
    meeting_date TIMESTAMP NOT NULL,
    duration_minutes INTEGER,
    
    -- Participants
    participants JSONB, -- [{name, email, role}]
    internal_attendees TEXT[], -- Array of employee names
    
    -- Content
    transcript_text TEXT,
    summary TEXT,
    action_items JSONB, -- [{text, assignee, due_date}]
    key_topics TEXT[], -- Extracted topics
    
    -- AI Analysis
    sentiment VARCHAR(20), -- 'positive', 'neutral', 'negative'
    sentiment_score DECIMAL(3, 2), -- -1 to 1
    client_goals TEXT[],
    budget_mentioned DECIMAL(10, 2),
    
    -- Storage
    gdrive_file_id VARCHAR(100),
    gdrive_file_url TEXT,
    
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transcripts_client ON call_transcripts(client_id);
CREATE INDEX idx_transcripts_date ON call_transcripts(meeting_date DESC);
CREATE INDEX idx_transcripts_fireflies ON call_transcripts(fireflies_id);

-- ============================================================================
-- SERVICE & RECOMMENDATION TABLES
-- ============================================================================

-- Service Directory (AI Knowledge Base)
CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100), -- 'seo', 'content', 'social', 'ads'
    description TEXT,
    
    -- Pricing
    price_min DECIMAL(10, 2),
    price_max DECIMAL(10, 2),
    pricing_model VARCHAR(50), -- 'monthly', 'project', 'hourly'
    
    -- Recommendation criteria
    ideal_for TEXT[], -- Client situations
    emotional_triggers TEXT[], -- Matching emotional triggers
    performance_triggers JSONB, -- {metric: threshold} e.g., {"bounce_rate": ">60"}
    
    -- Sales enablement
    key_benefits TEXT[],
    roi_examples TEXT[],
    case_studies TEXT[],
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_services_category ON services(category);
CREATE INDEX idx_services_active ON services(is_active);

-- AI Recommendations (generated and tracked)
CREATE TABLE recommendations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    service_id UUID REFERENCES services(id) ON DELETE SET NULL,
    
    recommendation_type VARCHAR(50), -- 'upsell', 'cross-sell', 'renewal', 'check-in'
    
    -- Context
    trigger_type VARCHAR(100), -- 'performance_drop', 'goal_match', 'contract_expiring'
    trigger_data JSONB, -- Additional context about what triggered this
    confidence_score DECIMAL(3, 2), -- 0-1
    
    -- Generated content
    talking_points TEXT,
    email_draft TEXT,
    
    -- Status tracking
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'sent', 'accepted', 'declined', 'expired'
    presented_by VARCHAR(100), -- Employee who used this
    presented_at TIMESTAMP,
    outcome VARCHAR(50), -- 'converted', 'not-interested', 'follow-up-needed'
    outcome_notes TEXT,
    
    expires_at TIMESTAMP, -- Recommendations can expire
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_recommendations_client ON recommendations(client_id);
CREATE INDEX idx_recommendations_status ON recommendations(status);
CREATE INDEX idx_recommendations_created ON recommendations(created_at DESC);

-- ============================================================================
-- COMMUNICATION & WORKFLOW TABLES
-- ============================================================================

-- Slack Messages (log of all CIA-generated messages)
CREATE TABLE slack_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    message_type VARCHAR(50), -- 'heads-up-display', 'sales-admin', 'client-nudge', 'upsell'
    
    -- Target
    slack_channel_id VARCHAR(100),
    slack_user_id VARCHAR(100),
    slack_message_ts VARCHAR(50), -- Slack's message timestamp (for threading)
    
    -- Content
    message_text TEXT NOT NULL,
    blocks JSONB, -- Slack Block Kit JSON
    
    -- Context
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    recommendation_id UUID REFERENCES recommendations(id) ON DELETE SET NULL,
    triggered_by VARCHAR(100), -- 'zoom_call', 'manual_lookup', 'scheduled_check'
    
    -- Status
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    acknowledged_at TIMESTAMP
);

CREATE INDEX idx_slack_messages_client ON slack_messages(client_id);
CREATE INDEX idx_slack_messages_type ON slack_messages(message_type);
CREATE INDEX idx_slack_messages_sent ON slack_messages(sent_at DESC);

-- Workflow Events (audit log of all system actions)
CREATE TABLE workflow_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    event_type VARCHAR(100) NOT NULL, -- 'call_detected', 'transcript_processed', 'recommendation_generated'
    event_source VARCHAR(100), -- 'zoom_webhook', 'fireflies_webhook', 'scheduled_job'
    
    -- Related entities
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    
    -- Event data
    payload JSONB,
    
    -- Processing
    status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    processed_at TIMESTAMP,
    error_message TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_events_type ON workflow_events(event_type);
CREATE INDEX idx_events_status ON workflow_events(status);
CREATE INDEX idx_events_created ON workflow_events(created_at DESC);
CREATE INDEX idx_events_client ON workflow_events(client_id);

-- ============================================================================
-- SYSTEM TABLES
-- ============================================================================

-- System Configuration
CREATE TABLE system_config (
    key VARCHAR(100) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(100)
);

-- Integration Status
CREATE TABLE integration_status (
    integration_name VARCHAR(50) PRIMARY KEY,
    is_healthy BOOLEAN DEFAULT true,
    last_check_at TIMESTAMP,
    last_success_at TIMESTAMP,
    last_error TEXT,
    error_count INTEGER DEFAULT 0,
    metadata JSONB,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- API Keys (encrypted storage)
CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_name VARCHAR(100) NOT NULL,
    key_encrypted TEXT NOT NULL,
    encryption_key_id VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Active Clients with Recent Performance
CREATE VIEW active_clients_with_performance AS
SELECT 
    c.*,
    pm.sessions as last_month_sessions,
    pm.users as last_month_users,
    pm.sessions_change_pct,
    COUNT(DISTINCT p.id) as active_projects,
    MAX(ct.meeting_date) as last_call_date
FROM clients c
LEFT JOIN performance_metrics pm ON c.id = pm.client_id 
    AND pm.metric_date = CURRENT_DATE - INTERVAL '1 day'
    AND pm.period = 'monthly'
LEFT JOIN projects p ON c.id = p.client_id AND p.status = 'active'
LEFT JOIN call_transcripts ct ON c.id = ct.client_id
WHERE c.status = 'active'
GROUP BY c.id, pm.sessions, pm.users, pm.sessions_change_pct;

-- Waiting Tasks (for proactive nudges)
CREATE VIEW waiting_tasks_summary AS
SELECT 
    t.*,
    c.name as client_name,
    c.communication_style,
    p.name as project_name,
    CURRENT_DATE - t.updated_at::date as days_waiting_calculated
FROM tasks t
JOIN projects p ON t.project_id = p.id
JOIN clients c ON p.client_id = c.id
WHERE t.status = 'waiting-on-client'
AND t.due_date IS NOT NULL
ORDER BY days_waiting_calculated DESC;

-- Recommendation Pipeline
CREATE VIEW recommendation_pipeline AS
SELECT 
    r.*,
    c.name as client_name,
    c.communication_style,
    c.emotional_trigger,
    s.name as service_name,
    s.category as service_category
FROM recommendations r
JOIN clients c ON r.client_id = c.id
LEFT JOIN services s ON r.service_id = s.id
WHERE r.status = 'pending'
ORDER BY r.confidence_score DESC, r.created_at DESC;

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply update trigger to all relevant tables
CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Insert default system configuration
INSERT INTO system_config (key, value, description) VALUES
('ai_model', '"claude-sonnet-4-20250514"', 'Claude model for AI operations'),
('max_recommendations_per_client', '5', 'Maximum active recommendations per client'),
('recommendation_expiry_days', '30', 'Days until recommendation expires'),
('health_check_interval_minutes', '5', 'Interval for integration health checks'),
(Content truncated due to size limit. Use page ranges or line ranges to read remaining content)