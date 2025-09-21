#!/usr/bin/env dart

/// Test runner script for Jal Guard app
/// This script provides a comprehensive testing interface similar to TestSprite
/// 
/// Usage:
/// dart test/run_tests.dart [options]
/// 
/// Options:
/// --unit          Run only unit tests
/// --widget        Run only widget tests  
/// --integration   Run only integration tests
/// --performance   Run only performance tests
/// --coverage      Run with coverage report
/// --verbose       Show detailed output
/// --help          Show this help message

import 'dart:io';

void main(List<String> args) async {
  print('🧪 Jal Guard Test Runner (TestSprite-style)');
  print('=' * 50);

  if (args.contains('--help')) {
    showHelp();
    return;
  }

  final options = parseArgs(args);
  
  print('📋 Test Configuration:');
  print('  • Unit Tests: ${options.runUnit ? '✅' : '❌'}');
  print('  • Widget Tests: ${options.runWidget ? '✅' : '❌'}');
  print('  • Integration Tests: ${options.runIntegration ? '✅' : '❌'}');
  print('  • Performance Tests: ${options.runPerformance ? '✅' : '❌'}');
  print('  • Coverage Report: ${options.coverage ? '✅' : '❌'}');
  print('  • Verbose Output: ${options.verbose ? '✅' : '❌'}');
  print('');

  final startTime = DateTime.now();
  var totalTests = 0;
  var passedTests = 0;
  var failedTests = 0;

  try {
    // Run Unit Tests
    if (options.runUnit) {
      print('🔬 Running Unit Tests...');
      final result = await runUnitTests(options.verbose);
      totalTests += result.total;
      passedTests += result.passed;
      failedTests += result.failed;
      print('');
    }

    // Run Widget Tests
    if (options.runWidget) {
      print('🎨 Running Widget Tests...');
      final result = await runWidgetTests(options.verbose);
      totalTests += result.total;
      passedTests += result.passed;
      failedTests += result.failed;
      print('');
    }

    // Run Integration Tests
    if (options.runIntegration) {
      print('🔗 Running Integration Tests...');
      final result = await runIntegrationTests(options.verbose);
      totalTests += result.total;
      passedTests += result.passed;
      failedTests += result.failed;
      print('');
    }

    // Run Performance Tests
    if (options.runPerformance) {
      print('⚡ Running Performance Tests...');
      final result = await runPerformanceTests(options.verbose);
      totalTests += result.total;
      passedTests += result.passed;
      failedTests += result.failed;
      print('');
    }

    // Generate Coverage Report
    if (options.coverage) {
      print('📊 Generating Coverage Report...');
      await generateCoverageReport();
      print('');
    }

    // Final Results
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    print('🏁 Test Results Summary');
    print('=' * 50);
    print('📊 Total Tests: $totalTests');
    print('✅ Passed: $passedTests');
    print('❌ Failed: $failedTests');
    print('📈 Success Rate: ${((passedTests / totalTests) * 100).toStringAsFixed(1)}%');
    print('⏱️  Duration: ${duration.inSeconds}s');
    print('');

    if (failedTests == 0) {
      print('🎉 All tests passed! App is ready for deployment.');
      exit(0);
    } else {
      print('⚠️  Some tests failed. Please review and fix issues.');
      exit(1);
    }

  } catch (e) {
    print('❌ Test execution failed: $e');
    exit(1);
  }
}

class TestOptions {
  final bool runUnit;
  final bool runWidget;
  final bool runIntegration;
  final bool runPerformance;
  final bool coverage;
  final bool verbose;

  TestOptions({
    this.runUnit = true,
    this.runWidget = true,
    this.runIntegration = true,
    this.runPerformance = true,
    this.coverage = false,
    this.verbose = false,
  });
}

class TestResult {
  final int total;
  final int passed;
  final int failed;

  TestResult({required this.total, required this.passed, required this.failed});
}

TestOptions parseArgs(List<String> args) {
  if (args.isEmpty) {
    return TestOptions(); // Run all tests by default
  }

  return TestOptions(
    runUnit: args.contains('--unit') || (!args.any((arg) => arg.startsWith('--') && arg != '--coverage' && arg != '--verbose')),
    runWidget: args.contains('--widget') || (!args.any((arg) => arg.startsWith('--') && arg != '--coverage' && arg != '--verbose')),
    runIntegration: args.contains('--integration') || (!args.any((arg) => arg.startsWith('--') && arg != '--coverage' && arg != '--verbose')),
    runPerformance: args.contains('--performance') || (!args.any((arg) => arg.startsWith('--') && arg != '--coverage' && arg != '--verbose')),
    coverage: args.contains('--coverage'),
    verbose: args.contains('--verbose'),
  );
}

void showHelp() {
  print('''
🧪 Jal Guard Test Runner (TestSprite-style)

USAGE:
  dart test/run_tests.dart [options]

OPTIONS:
  --unit          Run only unit tests (models, services)
  --widget        Run only widget tests (UI components)
  --integration   Run only integration tests (full app flows)
  --performance   Run only performance tests (benchmarks)
  --coverage      Generate and display coverage report
  --verbose       Show detailed test output
  --help          Show this help message

EXAMPLES:
  dart test/run_tests.dart                    # Run all tests
  dart test/run_tests.dart --unit             # Run only unit tests
  dart test/run_tests.dart --coverage         # Run all tests with coverage
  dart test/run_tests.dart --unit --verbose   # Run unit tests with details
  dart test/run_tests.dart --performance      # Run only performance tests

TEST CATEGORIES:
  🔬 Unit Tests      - Model validation, service logic
  🎨 Widget Tests    - UI component rendering, interactions
  🔗 Integration     - Full app flows, service integration
  ⚡ Performance     - Speed benchmarks, memory usage

COVERAGE REPORT:
  When --coverage is used, generates an HTML report at:
  coverage/html/index.html
''');
}

Future<TestResult> runUnitTests(bool verbose) async {
  final tests = [
    'test/models/user_model_test.dart',
    'test/models/health_report_model_test.dart',
    'test/models/district_model_test.dart',
    'test/services/database_service_test.dart',
  ];

  var totalTests = 0;
  var passedTests = 0;
  var failedTests = 0;

  for (final test in tests) {
    if (verbose) print('  Running $test...');
    
    final result = await Process.run(
      'flutter', 
      ['test', test, '--reporter=json'],
      workingDirectory: '.',
    );

    if (result.exitCode == 0) {
      final testCount = _countTestsInFile(test);
      totalTests += testCount;
      passedTests += testCount;
      if (verbose) print('    ✅ $testCount tests passed');
    } else {
      final testCount = _countTestsInFile(test);
      totalTests += testCount;
      failedTests += testCount;
      if (verbose) {
        print('    ❌ Tests failed');
        print('    Error: ${result.stderr}');
      }
    }
  }

  print('  📊 Unit Tests: $passedTests/$totalTests passed');
  return TestResult(total: totalTests, passed: passedTests, failed: failedTests);
}

Future<TestResult> runWidgetTests(bool verbose) async {
  final tests = [
    'test/widgets/heatmap_widget_test.dart',
  ];

  var totalTests = 0;
  var passedTests = 0;
  var failedTests = 0;

  for (final test in tests) {
    if (verbose) print('  Running $test...');
    
    final result = await Process.run(
      'flutter', 
      ['test', test, '--reporter=json'],
      workingDirectory: '.',
    );

    if (result.exitCode == 0) {
      final testCount = _countTestsInFile(test);
      totalTests += testCount;
      passedTests += testCount;
      if (verbose) print('    ✅ $testCount tests passed');
    } else {
      final testCount = _countTestsInFile(test);
      totalTests += testCount;
      failedTests += testCount;
      if (verbose) {
        print('    ❌ Tests failed');
        print('    Error: ${result.stderr}');
      }
    }
  }

  print('  📊 Widget Tests: $passedTests/$totalTests passed');
  return TestResult(total: totalTests, passed: passedTests, failed: failedTests);
}

Future<TestResult> runIntegrationTests(bool verbose) async {
  final tests = [
    'test/integration/app_integration_test.dart',
  ];

  var totalTests = 0;
  var passedTests = 0;
  var failedTests = 0;

  for (final test in tests) {
    if (verbose) print('  Running $test...');
    
    final result = await Process.run(
      'flutter', 
      ['test', test, '--reporter=json'],
      workingDirectory: '.',
    );

    if (result.exitCode == 0) {
      final testCount = _countTestsInFile(test);
      totalTests += testCount;
      passedTests += testCount;
      if (verbose) print('    ✅ $testCount tests passed');
    } else {
      final testCount = _countTestsInFile(test);
      totalTests += testCount;
      failedTests += testCount;
      if (verbose) {
        print('    ❌ Tests failed');
        print('    Error: ${result.stderr}');
      }
    }
  }

  print('  📊 Integration Tests: $passedTests/$totalTests passed');
  return TestResult(total: totalTests, passed: passedTests, failed: failedTests);
}

Future<TestResult> runPerformanceTests(bool verbose) async {
  if (verbose) print('  Running performance benchmarks...');
  
  final result = await Process.run(
    'flutter', 
    ['test', 'test/test_suite.dart', '--name=Performance Tests', '--reporter=json'],
    workingDirectory: '.',
  );

  if (result.exitCode == 0) {
    if (verbose) print('    ✅ Performance tests passed');
    print('  📊 Performance Tests: 3/3 passed');
    return TestResult(total: 3, passed: 3, failed: 0);
  } else {
    if (verbose) {
      print('    ❌ Performance tests failed');
      print('    Error: ${result.stderr}');
    }
    print('  📊 Performance Tests: 0/3 passed');
    return TestResult(total: 3, passed: 0, failed: 3);
  }
}

Future<void> generateCoverageReport() async {
  print('  Collecting coverage data...');
  
  final result = await Process.run(
    'flutter', 
    ['test', '--coverage'],
    workingDirectory: '.',
  );

  if (result.exitCode == 0) {
    print('  Generating HTML report...');
    
    // Generate HTML coverage report
    final genHtmlResult = await Process.run(
      'genhtml', 
      ['coverage/lcov.info', '-o', 'coverage/html'],
      workingDirectory: '.',
    );

    if (genHtmlResult.exitCode == 0) {
      print('  ✅ Coverage report generated at coverage/html/index.html');
    } else {
      print('  📊 Coverage data collected at coverage/lcov.info');
      print('  💡 Install lcov for HTML reports: apt-get install lcov');
    }
  } else {
    print('  ❌ Coverage collection failed');
  }
}

int _countTestsInFile(String filePath) {
  try {
    final file = File(filePath);
    final content = file.readAsStringSync();
    final testMatches = RegExp(r'test\(').allMatches(content);
    final testWidgetsMatches = RegExp(r'testWidgets\(').allMatches(content);
    return testMatches.length + testWidgetsMatches.length;
  } catch (e) {
    return 1; // Default to 1 if we can't count
  }
}
