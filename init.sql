CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'viewer',
    department VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE dashboards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    dashboard_type VARCHAR(50) NOT NULL DEFAULT 'general',
    owner_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE widgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dashboard_id UUID NOT NULL REFERENCES dashboards(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    widget_type VARCHAR(50) NOT NULL DEFAULT 'text',
    position INTEGER NOT NULL DEFAULT 0,
    data_config JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Users
INSERT INTO users (id, email, password, full_name, role, department) VALUES
    ('a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d', 'auditor@rimfrost.com', 'RF!audit2026', 'Sigrid Halvorsen', 'auditor', 'External Audit'),
    ('b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e', 'erik.nord@rimfrost.com', 'internal_pass', 'Erik Nordberg', 'admin', 'Engineering'),
    ('c3d4e5f6-a7b8-4c9d-0e1f-2a3b4c5d6e7f', 'anna.berg@rimfrost.com', 'internal_pass', 'Anna Bergstrom', 'analyst', 'Analytics');

-- Dashboards for auditor
INSERT INTO dashboards (id, title, description, dashboard_type, owner_id) VALUES
    ('d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f80', 'Revenue Overview Q4', 'Quarterly revenue metrics and growth analysis for Q4 2025', 'revenue', 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d'),
    ('e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8091', 'Security Monitoring', 'Real-time security events and threat analysis', 'security', 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d'),
    ('f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f809102', 'Traffic Analytics', 'Web traffic sources and user engagement metrics', 'traffic', 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d'),
    ('a7b8c9d0-e1f2-4a3b-4c5d-6e7f80910213', 'System Performance', 'Infrastructure health and response time monitoring', 'performance', 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d');

-- Widgets for Revenue Overview Q4
INSERT INTO widgets (dashboard_id, title, widget_type, position, data_config) VALUES
    ('d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f80', 'Monthly Recurring Revenue', 'kpi', 1, '{"value": "$2.4M", "change": 12.5}'),
    ('d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f80', 'Revenue Trend', 'chart', 2, '{"type": "line", "period": "quarterly"}'),
    ('d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f80', 'New Customers', 'kpi', 3, '{"value": "847", "change": 8.3}'),
    ('d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f80', 'Churn Rate', 'kpi', 4, '{"value": "2.1%", "change": -0.4}'),
    ('d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f80', 'Revenue by Region', 'bar', 5, '{"bars": [{"label": "EMEA", "value": "$1.1M", "percent": 85}, {"label": "APAC", "value": "$680K", "percent": 52}, {"label": "Americas", "value": "$420K", "percent": 32}, {"label": "Other", "value": "$200K", "percent": 15}]}'),
    ('d4e5f6a7-b8c9-4d0e-1f2a-3b4c5d6e7f80', 'Top Accounts', 'table', 6, '{"rows": [{"source": "Volvo Group", "visitors": "$180K", "conversion": "Enterprise"}, {"source": "Ericsson AB", "visitors": "$145K", "conversion": "Enterprise"}, {"source": "Saab Defense", "visitors": "$120K", "conversion": "Enterprise"}, {"source": "Nordea Bank", "visitors": "$95K", "conversion": "Premium"}]}');

-- Widgets for Security Monitoring
INSERT INTO widgets (dashboard_id, title, widget_type, position, data_config) VALUES
    ('e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8091', 'Active Threats', 'kpi', 1, '{"value": "3", "change": -25}'),
    ('e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8091', 'Events (24h)', 'kpi', 2, '{"value": "14,291", "change": 5.2}'),
    ('e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8091', 'Threat Timeline', 'chart', 3, '{"type": "area", "period": "24h"}'),
    ('e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8091', 'Attack Vectors', 'bar', 4, '{"bars": [{"label": "Phishing", "value": "42%", "percent": 42}, {"label": "Brute Force", "value": "28%", "percent": 28}, {"label": "XSS", "value": "18%", "percent": 18}, {"label": "SQLi", "value": "12%", "percent": 12}]}'),
    ('e5f6a7b8-c9d0-4e1f-2a3b-4c5d6e7f8091', 'Recent Incidents', 'table', 5, '{"rows": [{"source": "WAF Block", "visitors": "1,247", "conversion": "Blocked"}, {"source": "Auth Failure", "visitors": "892", "conversion": "Monitored"}, {"source": "Rate Limit", "visitors": "634", "conversion": "Throttled"}, {"source": "Geo Block", "visitors": "203", "conversion": "Blocked"}]}');

-- Widgets for Traffic Analytics
INSERT INTO widgets (dashboard_id, title, widget_type, position, data_config) VALUES
    ('f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f809102', 'Monthly Visitors', 'kpi', 1, '{"value": "284K", "change": 15.7}'),
    ('f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f809102', 'Bounce Rate', 'kpi', 2, '{"value": "34.2%", "change": -2.1}'),
    ('f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f809102', 'Visitor Trend', 'chart', 3, '{"type": "line", "period": "monthly"}'),
    ('f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f809102', 'Traffic Sources', 'bar', 4, '{"bars": [{"label": "Organic", "value": "45%", "percent": 45}, {"label": "Direct", "value": "28%", "percent": 28}, {"label": "Referral", "value": "17%", "percent": 17}, {"label": "Social", "value": "10%", "percent": 10}]}'),
    ('f6a7b8c9-d0e1-4f2a-3b4c-5d6e7f809102', 'Top Pages', 'table', 5, '{"rows": [{"source": "/dashboard", "visitors": "52,340", "conversion": "12.4%"}, {"source": "/analytics", "visitors": "38,120", "conversion": "8.7%"}, {"source": "/reports", "visitors": "24,890", "conversion": "15.2%"}, {"source": "/settings", "visitors": "12,450", "conversion": "3.1%"}]}');

-- Widgets for System Performance
INSERT INTO widgets (dashboard_id, title, widget_type, position, data_config) VALUES
    ('a7b8c9d0-e1f2-4a3b-4c5d-6e7f80910213', 'Avg Response Time', 'kpi', 1, '{"value": "142ms", "change": -8.5}'),
    ('a7b8c9d0-e1f2-4a3b-4c5d-6e7f80910213', 'Uptime (30d)', 'kpi', 2, '{"value": "99.97%", "change": 0.02}'),
    ('a7b8c9d0-e1f2-4a3b-4c5d-6e7f80910213', 'Latency Chart', 'chart', 3, '{"type": "line", "period": "7d"}'),
    ('a7b8c9d0-e1f2-4a3b-4c5d-6e7f80910213', 'Service Health', 'bar', 4, '{"bars": [{"label": "API", "value": "99.99%", "percent": 99}, {"label": "DB", "value": "99.95%", "percent": 99}, {"label": "CDN", "value": "99.98%", "percent": 99}, {"label": "Auth", "value": "99.92%", "percent": 99}]}'),
    ('a7b8c9d0-e1f2-4a3b-4c5d-6e7f80910213', 'Error Rates', 'table', 5, '{"rows": [{"source": "5xx Errors", "visitors": "0.03%", "conversion": "Normal"}, {"source": "4xx Errors", "visitors": "1.24%", "conversion": "Normal"}, {"source": "Timeouts", "visitors": "0.08%", "conversion": "Normal"}, {"source": "DNS Failures", "visitors": "0.01%", "conversion": "Good"}]}');
