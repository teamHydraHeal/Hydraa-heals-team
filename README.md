# 🏥 Jal Guard - AI-Powered Public Health Command Center

[![Flutter](https://img.shields.io/badge/Flutter-3.35.3-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.5.0-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey.svg)](https://flutter.dev/)

> **Jal Guard** is an AI-powered mobile application designed to address water-borne disease outbreaks in Northeast India, specifically targeting the state of Meghalaya. The app serves as a comprehensive public health command center with role-based access for Health Officials, ASHA Workers, and Citizens.

## 📱 **App Overview**

Jal Guard (Jal Suchak) is a comprehensive public health management system that leverages AI analytics, real-time monitoring, and community engagement to prevent and respond to water-borne disease outbreaks. The application provides different interfaces and functionalities based on user roles, ensuring appropriate access and tools for each stakeholder.

### 🎯 **Key Features**

- **🤖 AI-Powered Analytics**: XGBoost models for risk scoring and predictive insights
- **🗺️ Interactive Heatmaps**: Real-time health risk visualization for all user roles
- **📱 Offline-First Architecture**: Complete functionality without internet connectivity
- **🌐 Multi-Language Support**: English and Khasi localization
- **🔐 Secure Authentication**: Aadhaar-based verification with OTP
- **📊 Real-Time Dashboard**: Comprehensive analytics and reporting
- **🚨 Smart Notifications**: Targeted alerts and emergency responses
- **📋 Digital MCP Cards**: Mother and Child Protection tracking
- **🎓 Educational Modules**: Offline health education content

## 👥 **User Roles & Features**

### 🏥 **Health Officials**
- **Command Center Dashboard**: Real-time district monitoring
- **AI Co-pilot**: Strategic decision support and action planning
- **Interactive District Maps**: Risk visualization and resource allocation
- **Broadcast System**: AI-powered community announcements
- **Resource Management**: Inventory and allocation tracking
- **Emergency Escalation**: Critical situation response protocols

### 👩‍⚕️ **ASHA Workers**
- **Field Dashboard**: Local area health status
- **Report Submission**: Photo-based health incident reporting
- **AI Field Assistant**: Guidance on procedures and patient care
- **MCP Card Management**: Digital Mother and Child Protection tracking
- **Educational Access**: Offline training materials
- **Sync Status**: Offline data synchronization

### 👨‍👩‍👧‍👦 **Citizens**
- **Community Dashboard**: Local health awareness
- **Concern Reporting**: Easy health issue reporting
- **AI Health Assistant**: Personal health guidance and tips
- **Community Support**: Connect with local health workers
- **Health Alerts**: Public health notifications
- **Educational Content**: Health tips and prevention guides

## 🛠️ **Tech Stack**

### **Frontend & Framework**
- **Flutter 3.35.3**: Cross-platform mobile development
- **Dart 3.5.0**: Programming language
- **Material Design 3**: UI/UX design system
- **Provider**: State management
- **GoRouter**: Navigation and routing

### **Backend & Database**
- **SQLite**: Local database with enhanced schema
- **Supabase**: Cloud database and real-time sync (ready for integration)
- **PostgreSQL**: Cloud database engine
- **InfluxDB/TimescaleDB**: Time-series data for IoT sensors

### **Maps & Location**
- **Google Maps Flutter**: Interactive mapping
- **Geolocator**: Location services
- **Geocoding**: Address and coordinate conversion

### **AI & Analytics**
- **XGBoost**: Machine learning for risk scoring
- **TensorFlow Lite**: On-device AI models
- **GPT-4o**: Conversational AI and insights
- **NLP**: Natural language processing for entity extraction

### **Notifications & Communication**
- **Firebase Messaging**: Push notifications
- **Flutter Local Notifications**: Local alerts
- **WebSocket**: Real-time communication

### **Storage & File Management**
- **Shared Preferences**: User settings and preferences
- **Path Provider**: File system access
- **Image Picker**: Photo capture and selection
- **Supabase Storage**: Cloud file storage

### **Security & Encryption**
- **Encrypt Package**: Data encryption
- **TLS 1.3**: Secure communication
- **Row Level Security**: Database access control
- **AES-256**: Data encryption at rest

### **Development & Testing**
- **Logger**: Comprehensive logging
- **Connectivity Plus**: Network status monitoring
- **Intl**: Internationalization support
- **HTTP**: API communication

## 📁 **Project Structure**

```
lib/
├── core/                          # Core application logic
│   ├── database/                  # Enhanced database system
│   │   ├── database_service.dart  # Main database service
│   │   ├── migration_service.dart # Database migrations
│   │   ├── seed_service.dart      # Sample data seeding
│   │   ├── validation_service.dart # Data validation
│   │   ├── query_service.dart     # Advanced queries
│   │   ├── database_manager.dart  # Unified database interface
│   │   └── dao/                   # Data Access Objects
│   │       ├── user_dao.dart
│   │       ├── health_report_dao.dart
│   │       └── district_dao.dart
│   ├── models/                    # Data models
│   ├── providers/                 # State management
│   ├── services/                  # Business logic services
│   ├── router/                    # Navigation configuration
│   ├── theme/                     # App theming
│   └── navigation/                # Navigation components
├── features/                      # Feature-based modules
│   ├── auth/                      # Authentication screens
│   ├── health_official/           # Health official features
│   ├── field_worker/              # ASHA worker features
│   ├── citizen/                   # Citizen features
│   └── shared/                    # Shared components
└── main.dart                      # Application entry point
```

## 🚀 **Getting Started**

### **Prerequisites**
- Flutter SDK 3.35.3 or higher
- Dart SDK 3.5.0 or higher
- Android Studio / VS Code
- Git

### **Installation**

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/jal-guard.git
   cd jal-guard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (Optional)
   ```bash
   flutterfire configure
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### **Platform-Specific Setup**

#### **Android**
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Google Maps API key required

#### **iOS**
- Minimum iOS: 12.0
- Google Maps API key required
- Location permissions configured

#### **Web**
- Chrome/Firefox/Safari support
- Google Maps JavaScript API key required

## 📊 **Database Architecture**

### **Local Database (SQLite)**
- **13 Comprehensive Tables**: Users, Health Reports, Districts, IoT Data, etc.
- **Advanced Indexing**: Spatial, time-series, and composite indexes
- **Migration System**: Automated schema evolution
- **Data Validation**: Comprehensive validation and integrity checks
- **Offline Support**: Complete functionality without internet

### **Cloud Integration (Supabase Ready)**
- **Real-time Sync**: WebSocket-based synchronization
- **Conflict Resolution**: Intelligent conflict resolution strategies
- **Row Level Security**: Role-based data access
- **Edge Functions**: Serverless backend logic

### **Key Tables**
- `users`: User profiles and authentication
- `health_reports`: Health incident reports
- `districts`: Geographic and risk data
- `iot_sensor_data`: Real-time sensor readings
- `notifications`: User alerts and messages
- `risk_analysis`: AI-generated risk assessments
- `action_plans`: AI-generated response plans
- `resources`: Resource inventory
- `mcp_cards`: Mother and Child Protection records
- `educational_content`: Offline learning materials

## 🗺️ **Heatmap Implementation**

### **Health Officials**
- **Full Google Maps Integration**: Interactive district visualization
- **Risk Overlay**: Color-coded risk levels and predictions
- **District Selection**: Detailed district information and analytics
- **Resource Allocation**: Visual resource distribution

### **ASHA Workers**
- **Local Area Heatmap**: Field-focused area visualization
- **Risk Indicators**: Simple color-coded risk levels
- **Workflow Integration**: Embedded in dashboard for easy access

### **Citizens**
- **Community Health Map**: Public health awareness visualization
- **Interactive Markers**: Health report locations and severity
- **Safety Information**: Local risk levels and alerts

## 🤖 **AI Features**

### **Risk Scoring**
- **XGBoost Models**: Machine learning for risk prediction
- **Multi-factor Analysis**: Water quality, disease reports, environmental data
- **Real-time Updates**: Dynamic risk assessment
- **Predictive Insights**: Future risk trends and patterns

### **AI Co-pilots**
- **Health Official AI**: Strategic decision support and action planning
- **ASHA Worker AI**: Field procedure guidance and patient care
- **Citizen AI**: Personal health advice and community support

### **Natural Language Processing**
- **Entity Extraction**: Automatic identification of health entities
- **Report Analysis**: AI-powered report categorization
- **Conversational AI**: GPT-4o integration for intelligent responses

## 🔒 **Security & Privacy**

### **Data Protection**
- **AES-256 Encryption**: Data encryption at rest
- **TLS 1.3**: Secure data transmission
- **Row Level Security**: Database access control
- **Audit Trails**: Complete operation logging

### **Privacy Compliance**
- **GDPR Ready**: Data anonymization and deletion
- **Consent Management**: User consent tracking
- **Data Minimization**: Only necessary data collection
- **Local Processing**: On-device AI processing

## 📱 **Offline Capabilities**

### **Complete Offline Functionality**
- **Local Database**: Full SQLite database with 13 tables
- **Offline Reports**: Submit reports without internet
- **Cached Data**: Pre-loaded essential information
- **Smart Sync**: Automatic synchronization when online

### **Sync Strategy**
- **Conflict Resolution**: Intelligent conflict resolution
- **Priority Queuing**: Critical data sync prioritization
- **Retry Logic**: Exponential backoff for failed syncs
- **Progress Tracking**: Visual sync status indicators

## 🌐 **Multi-Language Support**

### **Supported Languages**
- **English**: Primary language
- **Khasi**: Local language support
- **Extensible**: Easy addition of new languages

### **Localization Features**
- **Dynamic Language Switching**: Runtime language changes
- **Cultural Adaptation**: Region-specific content
- **RTL Support**: Right-to-left language support
- **Pluralization**: Proper plural forms

## 📈 **Performance & Analytics**

### **Performance Metrics**
- **Response Times**: Sub-second query performance
- **Sync Efficiency**: Optimized data synchronization
- **Battery Optimization**: Power-efficient operations
- **Memory Management**: Efficient resource usage

### **Analytics Dashboard**
- **User Statistics**: Active users and engagement
- **Health Trends**: Time-series health data analysis
- **Geographic Distribution**: Spatial health patterns
- **Predictive Insights**: AI-generated forecasts

## 🧪 **Testing**

### **Test Coverage**
- **Unit Tests**: Core business logic testing
- **Integration Tests**: End-to-end functionality testing
- **Widget Tests**: UI component testing
- **Performance Tests**: Database and API performance

### **Testing Tools**
- **Flutter Test**: Built-in testing framework
- **Mockito**: Mocking and stubbing
- **Integration Test**: End-to-end testing
- **Golden Tests**: UI regression testing

## 🚀 **Deployment**

### **Build Configuration**
```bash
# Debug build
flutter run --debug

# Release build
flutter build apk --release
flutter build ios --release
flutter build web --release
```

### **Platform Deployment**
- **Google Play Store**: Android app distribution
- **Apple App Store**: iOS app distribution
- **Web Hosting**: Progressive Web App deployment
- **Enterprise**: Internal distribution options

## 📚 **Documentation**

### **Available Documentation**
- **API Documentation**: Complete API reference
- **Database Schema**: Detailed database documentation
- **User Guides**: Role-specific user manuals
- **Developer Guide**: Technical implementation details
- **Deployment Guide**: Production deployment instructions

### **Documentation Files**
- `requirements.md`: Detailed requirements specification
- `design.md`: UI/UX design documentation
- `SCREEN_LAYOUTS.md`: Screen layout specifications
- `DATABASE_ARCHITECTURE.md`: Database architecture details
- `ENHANCED_DATABASE_SUMMARY.md`: Enhanced database overview

## 🤝 **Contributing**

### **Development Setup**
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### **Code Standards**
- **Dart Style Guide**: Follow official Dart style guidelines
- **Flutter Best Practices**: Adhere to Flutter development practices
- **Documentation**: Document all public APIs
- **Testing**: Maintain test coverage above 80%

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 **Team**

- **Project Lead**: [Your Name]
- **Backend Developer**: [Backend Developer Name]
- **Frontend Developer**: [Frontend Developer Name]
- **AI/ML Engineer**: [AI Engineer Name]
- **UI/UX Designer**: [Designer Name]

## 📞 **Support**

### **Contact Information**
- **Email**: support@jalguard.ai
- **Website**: https://jalguard.ai
- **Documentation**: https://docs.jalguard.ai
- **Issues**: [GitHub Issues](https://github.com/your-username/jal-guard/issues)

### **Community**
- **Discord**: [Join our Discord](https://discord.gg/jalguard)
- **Telegram**: [Telegram Group](https://t.me/jalguard)
- **Twitter**: [@JalGuard](https://twitter.com/jalguard)

## 🙏 **Acknowledgments**

- **Meghalaya Health Department**: For domain expertise and requirements
- **ASHA Workers**: For field insights and feedback
- **Community Members**: For user testing and validation
- **Open Source Community**: For the amazing tools and libraries

## 🔮 **Roadmap**

### **Phase 1** ✅ (Completed)
- Core application development
- Basic AI integration
- Offline functionality
- Multi-language support

### **Phase 2** 🚧 (In Progress)
- Enhanced AI analytics
- Real-time synchronization
- Advanced reporting
- Performance optimization

### **Phase 3** 📋 (Planned)
- Machine learning models
- IoT device integration
- Advanced analytics
- Community features

### **Phase 4** 🔮 (Future)
- Predictive analytics
- Automated responses
- Integration with government systems
- International expansion

---

**Made with ❤️ for the people of Meghalaya and Northeast India**

*Jal Guard - Protecting communities through technology and AI*

