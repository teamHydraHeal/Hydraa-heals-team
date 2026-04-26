# Jal Guard - Database Architecture

## Overview

Jal Guard uses a **hybrid database architecture** combining local SQLite storage for offline functionality with cloud-based services for real-time data synchronization and IoT sensor integration. This architecture ensures the app works seamlessly in low-connectivity areas while providing real-time insights when connected.

## 🗄️ **Database Systems Used**

### 1. **Local Storage - SQLite**
- **Purpose**: Offline-first data storage and caching
- **Package**: `sqflite` (Flutter SQLite plugin)
- **Database Name**: `jal_guard_offline.db`
- **Version**: 1

### 2. **Cloud Database - Supabase (PostgreSQL)**
- **Purpose**: Real-time data synchronization and IoT sensor data
- **Features**: Row Level Security (RLS), Real-time subscriptions, Edge Functions
- **API**: RESTful API with real-time WebSocket connections

### 3. **IoT Data Storage - Time Series Database**
- **Purpose**: High-frequency sensor data storage
- **Technology**: InfluxDB or TimescaleDB (PostgreSQL extension)
- **Features**: Time-series optimization, data retention policies

### 4. **File Storage - Supabase Storage**
- **Purpose**: Photo attachments, documents, and media files
- **Features**: CDN distribution, secure file access

## 📊 **Database Schema**

### **Local SQLite Tables**

#### 1. **Health Reports Table** (`health_reports`)
```sql
CREATE TABLE health_reports (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  reporterName TEXT NOT NULL,
  location TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  description TEXT NOT NULL,
  symptoms TEXT NOT NULL,           -- JSON array
  severity TEXT NOT NULL,           -- low, medium, high, critical
  status TEXT NOT NULL,             -- pending, analyzed, escalated
  photoUrls TEXT,                   -- JSON array
  reportedAt TEXT NOT NULL,         -- ISO 8601 timestamp
  processedAt TEXT,                 -- ISO 8601 timestamp
  aiAnalysis TEXT,                  -- AI-generated analysis
  aiEntities TEXT,                  -- JSON object with extracted entities
  triageResponse TEXT,              -- AI triage recommendations
  isOffline INTEGER NOT NULL DEFAULT 1,
  isSynced INTEGER NOT NULL DEFAULT 0,
  data TEXT NOT NULL                -- Complete JSON object
);
```

#### 2. **Sync Queue Table** (`sync_queue`)
```sql
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  tableName TEXT NOT NULL,
  recordId TEXT NOT NULL,
  operation TEXT NOT NULL,          -- INSERT, UPDATE, DELETE
  data TEXT NOT NULL,               -- JSON data to sync
  createdAt TEXT NOT NULL,          -- ISO 8601 timestamp
  retryCount INTEGER NOT NULL DEFAULT 0,
  lastRetry TEXT                    -- ISO 8601 timestamp
);
```

#### 3. **User Preferences Table** (`user_preferences`)
```sql
CREATE TABLE user_preferences (
  userId TEXT PRIMARY KEY,
  language TEXT NOT NULL DEFAULT 'en',
  notificationSettings TEXT NOT NULL, -- JSON object
  offlineMode INTEGER NOT NULL DEFAULT 1,
  lastSyncAt TEXT,                  -- ISO 8601 timestamp
  data TEXT NOT NULL                -- Complete JSON object
);
```

#### 4. **Cached District Data Table** (`cached_districts`)
```sql
CREATE TABLE cached_districts (
  districtId TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  riskScore REAL NOT NULL,
  riskLevel TEXT NOT NULL,
  iotData TEXT,                     -- JSON object
  lastUpdated TEXT NOT NULL,        -- ISO 8601 timestamp
  data TEXT NOT NULL                -- Complete JSON object
);
```

### **Cloud Database Tables (Supabase/PostgreSQL)**

#### 1. **Users Table**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  aadhaar_number TEXT UNIQUE NOT NULL,
  phone_number TEXT NOT NULL,
  role TEXT NOT NULL,               -- health_official, asha_worker, citizen
  is_verified BOOLEAN DEFAULT FALSE,
  professional_id TEXT,             -- For ASHA workers and officials
  district_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own data
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (auth.uid() = id);
```

#### 2. **Health Reports Table**
```sql
CREATE TABLE health_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  reporter_name TEXT NOT NULL,
  location TEXT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  description TEXT NOT NULL,
  symptoms JSONB NOT NULL,
  severity TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  photo_urls JSONB,
  reported_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed_at TIMESTAMP WITH TIME ZONE,
  ai_analysis TEXT,
  ai_entities JSONB,
  triage_response TEXT,
  district_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_health_reports_district ON health_reports(district_id);
CREATE INDEX idx_health_reports_severity ON health_reports(severity);
CREATE INDEX idx_health_reports_reported_at ON health_reports(reported_at);
CREATE INDEX idx_health_reports_location ON health_reports USING GIST (
  ST_Point(longitude, latitude)
);
```

#### 3. **IoT Sensor Data Table**
```sql
CREATE TABLE iot_sensor_data (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sensor_id TEXT NOT NULL,
  sensor_type TEXT NOT NULL,        -- water_quality, temperature, humidity, ph_level
  value DECIMAL(10, 4) NOT NULL,
  unit TEXT NOT NULL,               -- °C, %, pH, mg/L
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  district_id TEXT NOT NULL,
  recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  quality_score DECIMAL(3, 2),      -- 0.00 to 1.00
  is_anomaly BOOLEAN DEFAULT FALSE
);

-- Time-series optimization
CREATE INDEX idx_iot_sensor_data_time ON iot_sensor_data(recorded_at DESC);
CREATE INDEX idx_iot_sensor_data_sensor ON iot_sensor_data(sensor_id, recorded_at DESC);
CREATE INDEX idx_iot_sensor_data_district ON iot_sensor_data(district_id, recorded_at DESC);
CREATE INDEX idx_iot_sensor_data_location ON iot_sensor_data USING GIST (
  ST_Point(longitude, latitude)
);
```

#### 4. **Districts Table**
```sql
CREATE TABLE districts (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  state TEXT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  population INTEGER NOT NULL,
  risk_score DECIMAL(3, 2) DEFAULT 0.00,
  risk_level TEXT DEFAULT 'low',
  active_reports INTEGER DEFAULT 0,
  critical_reports INTEGER DEFAULT 0,
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  polygon_coordinates JSONB,        -- GeoJSON polygon
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Spatial index for geographic queries
CREATE INDEX idx_districts_location ON districts USING GIST (
  ST_Point(longitude, latitude)
);
```

#### 5. **Risk Analysis Table**
```sql
CREATE TABLE risk_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  district_id TEXT REFERENCES districts(id),
  risk_score DECIMAL(3, 2) NOT NULL,
  risk_level TEXT NOT NULL,
  factors JSONB NOT NULL,           -- Risk factors and weights
  iot_contribution DECIMAL(3, 2),   -- IoT data contribution to risk
  report_contribution DECIMAL(3, 2), -- Report data contribution
  historical_contribution DECIMAL(3, 2), -- Historical data contribution
  predicted_trend TEXT,             -- increasing, stable, decreasing
  confidence_score DECIMAL(3, 2),   -- Model confidence
  analyzed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  valid_until TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Index for time-based queries
CREATE INDEX idx_risk_analysis_district_time ON risk_analysis(district_id, analyzed_at DESC);
```

#### 6. **Notifications Table**
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,               -- alert, update, reminder
  severity TEXT NOT NULL,           -- low, medium, high, critical
  district_id TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE,
  action_url TEXT,                  -- Deep link to relevant screen
  metadata JSONB                    -- Additional data
);

-- Indexes for performance
CREATE INDEX idx_notifications_user ON notifications(user_id, sent_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;
```

## 🔄 **Data Synchronization Strategy**

### **Offline-First Architecture**
1. **Local Storage**: All data is stored locally first using SQLite
2. **Sync Queue**: Changes are queued for synchronization when online
3. **Conflict Resolution**: Last-write-wins with user notification for conflicts
4. **Incremental Sync**: Only changed data is synchronized

### **Sync Process**
```dart
class SyncService {
  // 1. Check connectivity
  // 2. Process sync queue
  // 3. Upload local changes
  // 4. Download remote changes
  // 5. Resolve conflicts
  // 6. Update local database
  // 7. Clear sync queue
}
```

### **Data Retention Policies**
- **Local SQLite**: 30 days of reports, 7 days of cached data
- **IoT Data**: 1 year of raw data, 5 years of aggregated data
- **Health Reports**: Permanent storage with anonymization after 2 years
- **User Data**: Permanent with GDPR compliance

## 🌐 **IoT Data Integration**

### **Sensor Types Supported**
1. **Water Quality Sensors**
   - pH levels (6.5-8.5 optimal)
   - Turbidity (NTU)
   - Chlorine residual (mg/L)
   - Total dissolved solids (TDS)

2. **Environmental Sensors**
   - Temperature (°C)
   - Humidity (%)
   - Air quality index
   - Rainfall (mm)

3. **Health Monitoring Sensors**
   - Population density
   - Disease outbreak indicators
   - Water source contamination

### **Data Processing Pipeline**
```
IoT Sensors → Data Collection → Validation → Storage → Analysis → Risk Calculation → Alerts
```

### **Real-time Data Flow**
1. **Sensor Data Ingestion**: Every 15 minutes
2. **Data Validation**: Range checks, anomaly detection
3. **Risk Calculation**: XGBoost model updates
4. **Alert Generation**: Threshold-based notifications
5. **Dashboard Updates**: Real-time UI refresh

## 🔒 **Security & Privacy**

### **Data Encryption**
- **At Rest**: AES-256 encryption for local SQLite
- **In Transit**: TLS 1.3 for all API communications
- **Sensitive Data**: Field-level encryption for PII

### **Access Control**
- **Row Level Security (RLS)**: Users only access their district data
- **Role-based Access**: Different permissions for each user type
- **API Authentication**: JWT tokens with refresh mechanism

### **Privacy Compliance**
- **Data Anonymization**: Personal data removed after 2 years
- **Consent Management**: User consent for data collection
- **Right to Deletion**: GDPR-compliant data deletion

## 📈 **Performance Optimization**

### **Database Indexing**
- **Spatial Indexes**: For geographic queries
- **Time-series Indexes**: For IoT data queries
- **Composite Indexes**: For complex queries

### **Caching Strategy**
- **Local Caching**: Frequently accessed data
- **CDN Caching**: Static assets and images
- **Query Caching**: Expensive analytical queries

### **Data Partitioning**
- **Time-based Partitioning**: IoT data by month
- **Geographic Partitioning**: Data by district
- **User-based Partitioning**: User data isolation

## 🔧 **Backup & Recovery**

### **Backup Strategy**
- **Local Backups**: Daily SQLite backups
- **Cloud Backups**: Hourly Supabase backups
- **Cross-region Replication**: Disaster recovery

### **Recovery Procedures**
- **Point-in-time Recovery**: Up to 30 days
- **Data Integrity Checks**: Automated validation
- **Failover Mechanisms**: Automatic failover to backup systems

## 📊 **Monitoring & Analytics**

### **Database Monitoring**
- **Query Performance**: Slow query detection
- **Connection Pooling**: Connection monitoring
- **Storage Usage**: Disk space monitoring

### **Business Analytics**
- **Report Trends**: Health report patterns
- **Risk Patterns**: District risk evolution
- **User Engagement**: App usage analytics

## 🚀 **Scalability Considerations**

### **Horizontal Scaling**
- **Database Sharding**: By geographic region
- **Load Balancing**: Multiple API instances
- **CDN Distribution**: Global content delivery

### **Vertical Scaling**
- **Resource Optimization**: CPU and memory tuning
- **Query Optimization**: Index optimization
- **Connection Pooling**: Efficient connection management

This database architecture ensures Jal Guard can handle the complex requirements of a public health monitoring system while maintaining offline functionality and real-time responsiveness.

