# 🚀 Jal Guard - Developer Setup Guide

## 📋 **Quick Start**

This guide will help you set up the Jal Guard development environment and get the app running locally.

## ✅ **Prerequisites**

### **Required Software**
- **Flutter SDK**: 3.35.3 or higher
- **Dart SDK**: 3.5.0 or higher
- **Git**: Version control
- **IDE**: VS Code or Android Studio

### **Platform-Specific Requirements**

#### **Android Development**
- **Android Studio**: Latest version
- **Android SDK**: API 21+ (Android 5.0+)
- **Java Development Kit**: JDK 11 or higher
- **Google Maps API Key**: For map functionality

#### **iOS Development** (macOS only)
- **Xcode**: Latest version
- **iOS Simulator**: iOS 12.0+
- **CocoaPods**: Dependency manager
- **Google Maps API Key**: For map functionality

#### **Web Development**
- **Chrome**: For testing
- **Google Maps JavaScript API Key**: For web maps

## 🛠️ **Installation Steps**

### **1. Clone the Repository**
```bash
git clone https://github.com/your-username/jal-guard.git
cd jal-guard
```

### **2. Install Flutter Dependencies**
```bash
flutter pub get
```

### **3. Verify Flutter Installation**
```bash
flutter doctor
```
Ensure all required components are installed and configured.

### **4. Configure Google Maps** (Required for heatmaps)

#### **Android Configuration**
1. Get Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY_HERE"/>
</application>
```

#### **iOS Configuration**
1. Add to `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### **Web Configuration**
1. Add to `web/index.html`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE"></script>
```

### **5. Configure Firebase** (Optional)
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Configure Firebase
flutterfire configure
```

### **6. Run the Application**

#### **Debug Mode**
```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome
```

#### **Release Mode**
```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Web
flutter build web --release
```

## 🗄️ **Database Setup**

### **Local Database**
The app uses SQLite with an enhanced database system. No additional setup required - the database is automatically initialized on first run.

### **Sample Data**
Sample data is automatically seeded on first run. To reset:
```dart
// In your development environment
await DatabaseManager.resetDatabase();
```

### **Database Inspection**
Use the built-in database inspector in VS Code or Android Studio to view and modify data.

## 🧪 **Testing**

### **Run Tests**
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/auth_test.dart

# Run integration tests
flutter test integration_test/
```

### **Test Coverage**
```bash
# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🔧 **Development Tools**

### **VS Code Extensions** (Recommended)
- **Flutter**: Official Flutter extension
- **Dart**: Official Dart extension
- **Flutter Intl**: Internationalization support
- **Bracket Pair Colorizer**: Code readability
- **GitLens**: Git integration

### **Android Studio Plugins**
- **Flutter**: Official Flutter plugin
- **Dart**: Official Dart plugin
- **Flutter Intl**: Internationalization support

## 📱 **Platform-Specific Setup**

### **Android Setup**
1. **Enable Developer Options** on your Android device
2. **Enable USB Debugging**
3. **Connect device** via USB
4. **Accept debugging** when prompted
5. **Run**: `flutter run -d android`

### **iOS Setup** (macOS only)
1. **Open Xcode** and accept license agreements
2. **Install iOS Simulator** from Xcode
3. **Run**: `flutter run -d ios`

### **Web Setup**
1. **Enable Web support**: `flutter config --enable-web`
2. **Run**: `flutter run -d chrome`

## 🐛 **Troubleshooting**

### **Common Issues**

#### **Flutter Doctor Issues**
```bash
# Fix common issues
flutter doctor --android-licenses
flutter doctor --fix
```

#### **Dependency Issues**
```bash
# Clean and reinstall
flutter clean
flutter pub get
```

#### **Build Issues**
```bash
# Clean build cache
flutter clean
flutter pub get
flutter run
```

#### **Google Maps Issues**
- Verify API key is correct
- Check API key restrictions
- Ensure billing is enabled for Google Cloud project

#### **Database Issues**
```bash
# Reset database
flutter clean
flutter pub get
# App will recreate database on next run
```

### **Performance Issues**
- **Hot Reload**: Use `r` for hot reload
- **Hot Restart**: Use `R` for hot restart
- **Debug Mode**: Use `--debug` flag for debugging
- **Profile Mode**: Use `--profile` flag for performance testing

## 📊 **Development Workflow**

### **Feature Development**
1. **Create feature branch**: `git checkout -b feature/new-feature`
2. **Implement feature**: Write code and tests
3. **Test locally**: `flutter test`
4. **Commit changes**: `git commit -m "Add new feature"`
5. **Push branch**: `git push origin feature/new-feature`
6. **Create pull request**: Submit for review

### **Code Quality**
- **Linting**: Code is automatically linted
- **Formatting**: Use `dart format .` to format code
- **Testing**: Maintain test coverage above 80%
- **Documentation**: Document all public APIs

## 🔍 **Debugging**

### **Debug Tools**
- **Flutter Inspector**: Widget tree inspection
- **Dart DevTools**: Performance profiling
- **VS Code Debugger**: Breakpoint debugging
- **Console Logging**: Use `print()` or `logger`

### **Database Debugging**
```dart
// Enable database logging
await DatabaseManager.getHealthStatus();
```

### **Network Debugging**
- **Charles Proxy**: HTTP traffic inspection
- **Flutter Inspector**: Network tab
- **Console Logs**: API call logging

## 📚 **Useful Commands**

### **Flutter Commands**
```bash
# Check Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Clean project
flutter clean

# Run tests
flutter test

# Build app
flutter build apk
flutter build ios
flutter build web

# Run on device
flutter run
flutter run -d android
flutter run -d ios
flutter run -d chrome
```

### **Git Commands**
```bash
# Clone repository
git clone <repository-url>

# Create branch
git checkout -b feature/new-feature

# Commit changes
git add .
git commit -m "Your commit message"

# Push changes
git push origin feature/new-feature
```

## 🆘 **Getting Help**

### **Documentation**
- **Flutter Docs**: https://flutter.dev/docs
- **Dart Docs**: https://dart.dev/guides
- **Project Docs**: Check `/docs` folder

### **Community Support**
- **GitHub Issues**: Report bugs and request features
- **Discord**: Join our developer community
- **Stack Overflow**: Tag questions with `flutter` and `jal-guard`

### **Team Contact**
- **Email**: dev@jalguard.ai
- **Slack**: #jal-guard-dev channel
- **Office Hours**: Tuesdays 2-4 PM IST

## 🎯 **Next Steps**

1. **Explore the codebase**: Start with `lib/main.dart`
2. **Run the app**: Follow the setup steps above
3. **Read documentation**: Check `/docs` folder
4. **Join community**: Connect with other developers
5. **Start contributing**: Pick an issue and submit a PR

---

**Happy coding! 🚀**

*For additional help, check the main README.md or contact the development team.*

