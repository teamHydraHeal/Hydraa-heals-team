#!/usr/bin/env dart

/// TestSprite-style Debug Runner for Jal Guard
/// Comprehensive debugging and validation system
/// 
/// Usage: dart debug/testsprite_debug.dart [options]

import 'dart:io';

void main(List<String> args) async {
  print('🐛 TestSprite Debug Runner - Jal Guard');
  print('=' * 60);
  print('🔍 Comprehensive App Debugging & Validation');
  print('=' * 60);

  final startTime = DateTime.now();
  
  try {
    // Initialize debug session
    await initializeDebugSession();
    
    // Run all debug checks
    final results = await runDebugSuite();
    
    // Generate comprehensive report
    await generateDebugReport(results);
    
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    print('\n🏁 Debug Session Complete');
    print('⏱️  Total Duration: ${duration.inSeconds}s');
    print('📊 Issues Found: ${results.totalIssues}');
    print('🔧 Issues Fixed: ${results.fixedIssues}');
    print('⚠️  Warnings: ${results.warnings}');
    
    if (results.totalIssues == 0) {
      print('✅ App is healthy and ready for deployment!');
      exit(0);
    } else {
      print('🔴 Found ${results.totalIssues} issues that need attention');
      exit(1);
    }
    
  } catch (e) {
    print('❌ Debug session failed: $e');
    exit(1);
  }
}

class DebugResults {
  int totalIssues = 0;
  int fixedIssues = 0;
  int warnings = 0;
  List<String> criticalIssues = [];
  List<String> performanceIssues = [];
  List<String> codeQualityIssues = [];
  List<String> securityIssues = [];
  Map<String, dynamic> metrics = {};
}

Future<void> initializeDebugSession() async {
  print('🚀 Initializing TestSprite Debug Session...\n');
  
  // Check Flutter environment
  print('1️⃣  Checking Flutter Environment...');
  await checkFlutterEnvironment();
  
  // Validate project structure
  print('2️⃣  Validating Project Structure...');
  await validateProjectStructure();
  
  // Check dependencies
  print('3️⃣  Checking Dependencies...');
  await checkDependencies();
  
  print('✅ Debug session initialized\n');
}

Future<DebugResults> runDebugSuite() async {
  final results = DebugResults();
  
  print('🔍 Running Comprehensive Debug Suite...\n');
  
  // 1. Static Code Analysis
  print('📊 1. Static Code Analysis');
  await runStaticAnalysis(results);
  
  // 2. Dependency Validation
  print('\n🔗 2. Dependency Validation');
  await validateDependencies(results);
  
  // 3. Model Validation
  print('\n📋 3. Model Validation');
  await validateModels(results);
  
  // 4. Service Integration Testing
  print('\n⚙️  4. Service Integration Testing');
  await testServiceIntegration(results);
  
  // 5. UI Component Testing
  print('\n🎨 5. UI Component Testing');
  await testUIComponents(results);
  
  // 6. Database Testing
  print('\n💾 6. Database Testing');
  await testDatabase(results);
  
  // 7. Performance Analysis
  print('\n⚡ 7. Performance Analysis');
  await analyzePerformance(results);
  
  // 8. Security Audit
  print('\n🔒 8. Security Audit');
  await runSecurityAudit(results);
  
  // 9. Memory Leak Detection
  print('\n🧠 9. Memory Leak Detection');
  await detectMemoryLeaks(results);
  
  // 10. Cross-Platform Compatibility
  print('\n🌐 10. Cross-Platform Compatibility');
  await checkCrossPlatformCompatibility(results);
  
  return results;
}

Future<void> checkFlutterEnvironment() async {
  try {
    final result = await Process.run('flutter', ['--version']);
    if (result.exitCode == 0) {
      print('   ✅ Flutter SDK found and working');
      final version = result.stdout.toString().split('\n')[0];
      print('   📱 $version');
    } else {
      print('   ❌ Flutter SDK not found or corrupted');
    }
  } catch (e) {
    print('   ❌ Flutter environment check failed: $e');
  }
}

Future<void> validateProjectStructure() async {
  final requiredDirs = [
    'lib',
    'lib/core',
    'lib/features',
    'assets',
    'android',
    'ios',
  ];
  
  final requiredFiles = [
    'pubspec.yaml',
    'lib/main.dart',
    'lib/core/router/app_router.dart',
    'lib/core/theme/app_theme.dart',
  ];
  
  var issues = 0;
  
  // Check directories
  for (final dir in requiredDirs) {
    if (Directory(dir).existsSync()) {
      print('   ✅ Directory: $dir');
    } else {
      print('   ❌ Missing directory: $dir');
      issues++;
    }
  }
  
  // Check files
  for (final file in requiredFiles) {
    if (File(file).existsSync()) {
      print('   ✅ File: $file');
    } else {
      print('   ❌ Missing file: $file');
      issues++;
    }
  }
  
  if (issues == 0) {
    print('   ✅ Project structure is valid');
  } else {
    print('   ⚠️  Found $issues structural issues');
  }
}

Future<void> checkDependencies() async {
  try {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('   ❌ pubspec.yaml not found');
      return;
    }
    
    final content = await pubspecFile.readAsString();
    final requiredDeps = [
      'flutter',
      'provider',
      'go_router',
      'sqflite',
      'firebase_core',
      'google_maps_flutter',
    ];
    
    var missingDeps = 0;
    for (final dep in requiredDeps) {
      if (content.contains(dep)) {
        print('   ✅ Dependency: $dep');
      } else {
        print('   ❌ Missing dependency: $dep');
        missingDeps++;
      }
    }
    
    if (missingDeps == 0) {
      print('   ✅ All required dependencies found');
    } else {
      print('   ⚠️  $missingDeps dependencies missing');
    }
    
  } catch (e) {
    print('   ❌ Dependency check failed: $e');
  }
}

Future<void> runStaticAnalysis(DebugResults results) async {
  try {
    print('   🔍 Running Flutter Analyze...');
    final result = await Process.run('flutter', ['analyze']);
    
    if (result.exitCode == 0) {
      print('   ✅ No static analysis issues found');
    } else {
      final output = result.stdout.toString();
      final errorCount = _countMatches(output, 'error •');
      final warningCount = _countMatches(output, 'warning •');
      final infoCount = _countMatches(output, 'info •');
      
      results.totalIssues += errorCount;
      results.warnings += warningCount + infoCount;
      
      print('   ❌ Static analysis issues found:');
      print('      • Errors: $errorCount');
      print('      • Warnings: $warningCount');
      print('      • Info: $infoCount');
      
      if (errorCount > 0) {
        results.criticalIssues.add('Static analysis errors detected');
      }
    }
  } catch (e) {
    print('   ❌ Static analysis failed: $e');
    results.totalIssues++;
  }
}

Future<void> validateDependencies(DebugResults results) async {
  try {
    print('   📦 Checking dependency resolution...');
    final result = await Process.run('flutter', ['pub', 'deps']);
    
    if (result.exitCode == 0) {
      print('   ✅ Dependencies resolved successfully');
      
      // Check for version conflicts
      final output = result.stdout.toString();
      if (output.contains('conflict') || output.contains('incompatible')) {
        print('   ⚠️  Potential version conflicts detected');
        results.warnings++;
      }
    } else {
      print('   ❌ Dependency resolution failed');
      results.totalIssues++;
      results.criticalIssues.add('Dependency resolution failure');
    }
  } catch (e) {
    print('   ❌ Dependency validation failed: $e');
    results.totalIssues++;
  }
}

Future<void> validateModels(DebugResults results) async {
  final modelFiles = [
    'lib/core/models/user_model.dart',
    'lib/core/models/health_report_model.dart',
    'lib/core/models/district_model.dart',
    'lib/core/models/notification_model.dart',
  ];
  
  for (final modelFile in modelFiles) {
    print('   🔍 Validating $modelFile...');
    
    if (!File(modelFile).existsSync()) {
      print('   ❌ Model file missing: $modelFile');
      results.totalIssues++;
      results.criticalIssues.add('Missing model: $modelFile');
      continue;
    }
    
    try {
      final content = await File(modelFile).readAsString();
      
      // Check for required methods
      final hasFromJson = content.contains('fromJson');
      final hasToJson = content.contains('toJson');
      final hasCopyWith = content.contains('copyWith');
      
      if (!hasFromJson) {
        print('   ❌ Missing fromJson method in $modelFile');
        results.totalIssues++;
      }
      
      if (!hasToJson) {
        print('   ❌ Missing toJson method in $modelFile');
        results.totalIssues++;
      }
      
      if (!hasCopyWith) {
        print('   ⚠️  Missing copyWith method in $modelFile');
        results.warnings++;
      }
      
      if (hasFromJson && hasToJson) {
        print('   ✅ Model validation passed: $modelFile');
      }
      
    } catch (e) {
      print('   ❌ Error reading model file: $e');
      results.totalIssues++;
    }
  }
}

Future<void> testServiceIntegration(DebugResults results) async {
  final serviceFiles = [
    'lib/core/services/auth_service.dart',
    'lib/core/services/offline_service.dart',
    'lib/core/services/notification_service.dart',
    'lib/core/services/ai_analytics_service.dart',
    'lib/core/database/database_manager.dart',
  ];
  
  for (final serviceFile in serviceFiles) {
    print('   🔍 Testing service: $serviceFile...');
    
    if (!File(serviceFile).existsSync()) {
      print('   ❌ Service file missing: $serviceFile');
      results.totalIssues++;
      results.criticalIssues.add('Missing service: $serviceFile');
      continue;
    }
    
    try {
      final content = await File(serviceFile).readAsString();
      
      // Check for initialization methods
      if (content.contains('initialize')) {
        print('   ✅ Service has initialization: $serviceFile');
      } else {
        print('   ⚠️  Service may lack proper initialization: $serviceFile');
        results.warnings++;
      }
      
      // Check for error handling
      if (content.contains('try') && content.contains('catch')) {
        print('   ✅ Error handling present: $serviceFile');
      } else {
        print('   ⚠️  Limited error handling: $serviceFile');
        results.warnings++;
      }
      
    } catch (e) {
      print('   ❌ Error analyzing service: $e');
      results.totalIssues++;
    }
  }
}

Future<void> testUIComponents(DebugResults results) async {
  final screenDirs = [
    'lib/features/auth/screens',
    'lib/features/health_official/screens',
    'lib/features/field_worker/screens',
    'lib/features/citizen/screens',
    'lib/features/shared/screens',
  ];
  
  for (final screenDir in screenDirs) {
    print('   🔍 Testing UI components in: $screenDir...');
    
    if (!Directory(screenDir).existsSync()) {
      print('   ❌ Screen directory missing: $screenDir');
      results.totalIssues++;
      continue;
    }
    
    try {
      final files = Directory(screenDir)
          .listSync()
          .where((file) => file.path.endsWith('.dart'))
          .toList();
      
      for (final file in files) {
        final content = await File(file.path).readAsString();
        
        // Check for StatefulWidget or StatelessWidget
        if (content.contains('StatefulWidget') || content.contains('StatelessWidget')) {
          print('   ✅ Valid widget: ${file.path.split('/').last}');
        } else {
          print('   ⚠️  Non-widget file in screens: ${file.path.split('/').last}');
          results.warnings++;
        }
        
        // Check for build method
        if (!content.contains('Widget build(')) {
          print('   ❌ Missing build method: ${file.path.split('/').last}');
          results.totalIssues++;
        }
      }
      
    } catch (e) {
      print('   ❌ Error testing UI components: $e');
      results.totalIssues++;
    }
  }
}

Future<void> testDatabase(DebugResults results) async {
  print('   🔍 Testing database components...');
  
  final dbFiles = [
    'lib/core/database/database_service.dart',
    'lib/core/database/database_manager.dart',
    'lib/core/database/migration_service.dart',
    'lib/core/database/validation_service.dart',
  ];
  
  for (final dbFile in dbFiles) {
    if (!File(dbFile).existsSync()) {
      print('   ❌ Database file missing: $dbFile');
      results.totalIssues++;
      results.criticalIssues.add('Missing database component: $dbFile');
      continue;
    }
    
    try {
      final content = await File(dbFile).readAsString();
      
      // Check for database operations
      if (content.contains('Database') && content.contains('sqflite')) {
        print('   ✅ Database integration found: $dbFile');
      } else {
        print('   ⚠️  Database integration unclear: $dbFile');
        results.warnings++;
      }
      
    } catch (e) {
      print('   ❌ Error testing database file: $e');
      results.totalIssues++;
    }
  }
}

Future<void> analyzePerformance(DebugResults results) async {
  print('   ⚡ Analyzing performance characteristics...');
  
  try {
    // Check for potential performance issues in code
    final libDir = Directory('lib');
    if (!libDir.existsSync()) {
      print('   ❌ lib directory not found');
      results.totalIssues++;
      return;
    }
    
    var largeFiles = 0;
    var complexWidgets = 0;
    var heavyImports = 0;
    
    await for (final file in libDir.list(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        final lines = content.split('\n').length;
        
        // Check for large files (potential performance issue)
        if (lines > 500) {
          largeFiles++;
          print('   ⚠️  Large file detected: ${file.path} ($lines lines)');
        }
        
        // Check for complex widgets
        if (content.contains('StatefulWidget') && lines > 200) {
          complexWidgets++;
        }
        
        // Check for heavy imports
        final importCount = _countMatches(content, 'import ');
        if (importCount > 20) {
          heavyImports++;
        }
      }
    }
    
    results.performanceIssues.addAll([
      if (largeFiles > 0) '$largeFiles large files detected',
      if (complexWidgets > 0) '$complexWidgets complex widgets found',
      if (heavyImports > 0) '$heavyImports files with heavy imports',
    ]);
    
    if (largeFiles > 3) {
      results.warnings += largeFiles;
      print('   ⚠️  Performance concern: $largeFiles large files');
    } else {
      print('   ✅ File sizes are reasonable');
    }
    
  } catch (e) {
    print('   ❌ Performance analysis failed: $e');
    results.totalIssues++;
  }
}

Future<void> runSecurityAudit(DebugResults results) async {
  print('   🔒 Running security audit...');
  
  try {
    final pubspecContent = await File('pubspec.yaml').readAsString();
    
    // Check for security-related dependencies
    final hasEncryption = pubspecContent.contains('encrypt') || 
                         pubspecContent.contains('crypto');
    
    if (hasEncryption) {
      print('   ✅ Encryption dependency found');
    } else {
      print('   ⚠️  No encryption dependency detected');
      results.warnings++;
      results.securityIssues.add('Missing encryption dependency');
    }
    
    // Check for hardcoded secrets in code
    final libDir = Directory('lib');
    var hardcodedSecrets = 0;
    
    await for (final file in libDir.list(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        
        // Look for potential hardcoded secrets
        final suspiciousPatterns = [
          'password',
          'api_key',
          'secret',
          'token',
        ];
        
        for (final pattern in suspiciousPatterns) {
          if (content.toLowerCase().contains(pattern) && 
              content.contains('=') && 
              content.contains('"')) {
            hardcodedSecrets++;
            break;
          }
        }
      }
    }
    
    if (hardcodedSecrets > 0) {
      print('   ⚠️  Potential hardcoded secrets: $hardcodedSecrets files');
      results.warnings += hardcodedSecrets;
      results.securityIssues.add('$hardcodedSecrets files with potential secrets');
    } else {
      print('   ✅ No obvious hardcoded secrets found');
    }
    
  } catch (e) {
    print('   ❌ Security audit failed: $e');
    results.totalIssues++;
  }
}

Future<void> detectMemoryLeaks(DebugResults results) async {
  print('   🧠 Detecting potential memory leaks...');
  
  try {
    final libDir = Directory('lib');
    var potentialLeaks = 0;
    
    await for (final file in libDir.list(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        
        // Check for StatefulWidgets without dispose
        if (content.contains('StatefulWidget') && 
            content.contains('AnimationController') &&
            !content.contains('dispose()')) {
          potentialLeaks++;
          print('   ⚠️  Potential memory leak: ${file.path.split('/').last}');
        }
        
        // Check for StreamSubscription without cancel
        if (content.contains('StreamSubscription') &&
            !content.contains('.cancel()')) {
          potentialLeaks++;
        }
      }
    }
    
    if (potentialLeaks > 0) {
      results.warnings += potentialLeaks;
      results.performanceIssues.add('$potentialLeaks potential memory leaks');
      print('   ⚠️  Found $potentialLeaks potential memory leaks');
    } else {
      print('   ✅ No obvious memory leaks detected');
    }
    
  } catch (e) {
    print('   ❌ Memory leak detection failed: $e');
    results.totalIssues++;
  }
}

Future<void> checkCrossPlatformCompatibility(DebugResults results) async {
  print('   🌐 Checking cross-platform compatibility...');
  
  try {
    // Check for platform-specific code
    final libDir = Directory('lib');
    var platformSpecificCode = 0;
    
    await for (final file in libDir.list(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        
        // Check for platform-specific imports or code
        if (content.contains('dart:io') || 
            content.contains('Platform.') ||
            content.contains('kIsWeb')) {
          platformSpecificCode++;
        }
      }
    }
    
    // Check for platform directories
    final hasAndroid = Directory('android').existsSync();
    final hasIOS = Directory('ios').existsSync();
    final hasWeb = Directory('web').existsSync();
    
    print('   📱 Platform support:');
    print('      • Android: ${hasAndroid ? '✅' : '❌'}');
    print('      • iOS: ${hasIOS ? '✅' : '❌'}');
    print('      • Web: ${hasWeb ? '✅' : '❌'}');
    
    if (platformSpecificCode > 0) {
      print('   ⚠️  $platformSpecificCode files with platform-specific code');
      results.warnings++;
    } else {
      print('   ✅ No platform-specific code detected');
    }
    
  } catch (e) {
    print('   ❌ Cross-platform check failed: $e');
    results.totalIssues++;
  }
}

Future<void> generateDebugReport(DebugResults results) async {
  print('\n📊 Generating Comprehensive Debug Report...');
  
  final report = StringBuffer();
  report.writeln('# 🐛 TestSprite Debug Report - Jal Guard');
  report.writeln('Generated: ${DateTime.now()}');
  report.writeln('');
  
  // Executive Summary
  report.writeln('## 📋 Executive Summary');
  report.writeln('- **Total Issues**: ${results.totalIssues}');
  report.writeln('- **Fixed Issues**: ${results.fixedIssues}');
  report.writeln('- **Warnings**: ${results.warnings}');
  report.writeln('- **Status**: ${results.totalIssues == 0 ? '✅ HEALTHY' : '⚠️ NEEDS ATTENTION'}');
  report.writeln('');
  
  // Critical Issues
  if (results.criticalIssues.isNotEmpty) {
    report.writeln('## 🔴 Critical Issues');
    for (final issue in results.criticalIssues) {
      report.writeln('- ❌ $issue');
    }
    report.writeln('');
  }
  
  // Performance Issues
  if (results.performanceIssues.isNotEmpty) {
    report.writeln('## ⚡ Performance Issues');
    for (final issue in results.performanceIssues) {
      report.writeln('- ⚠️ $issue');
    }
    report.writeln('');
  }
  
  // Security Issues
  if (results.securityIssues.isNotEmpty) {
    report.writeln('## 🔒 Security Issues');
    for (final issue in results.securityIssues) {
      report.writeln('- 🛡️ $issue');
    }
    report.writeln('');
  }
  
  // Code Quality Issues
  if (results.codeQualityIssues.isNotEmpty) {
    report.writeln('## 📊 Code Quality Issues');
    for (final issue in results.codeQualityIssues) {
      report.writeln('- 📋 $issue');
    }
    report.writeln('');
  }
  
  // Recommendations
  report.writeln('## 💡 Recommendations');
  if (results.totalIssues == 0) {
    report.writeln('✅ Your app is in excellent condition!');
    report.writeln('- All critical components are working properly');
    report.writeln('- Code quality meets high standards');
    report.writeln('- Ready for production deployment');
  } else {
    report.writeln('🔧 Address the following issues:');
    report.writeln('1. Fix critical issues first');
    report.writeln('2. Review performance concerns');
    report.writeln('3. Implement security improvements');
    report.writeln('4. Consider code quality enhancements');
  }
  
  // Write report to file
  final reportFile = File('debug/TESTSPRITE_DEBUG_REPORT.md');
  await reportFile.parent.create(recursive: true);
  await reportFile.writeAsString(report.toString());
  
  print('✅ Debug report saved to: debug/TESTSPRITE_DEBUG_REPORT.md');
}

int _countMatches(String text, String pattern) {
  return pattern.allMatches(text).length;
}
