import 'dart:async';
import 'dart:math';

class ErrorHandlingService {
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 1);
  static const Duration _maxDelay = Duration(seconds: 30);
  
  // Retry mechanism with exponential backoff
  static Future<T> retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
    Duration baseDelay = _baseDelay,
    Duration maxDelay = _maxDelay,
    bool Function(Exception)? retryCondition,
  }) async {
    int attempt = 0;
    Exception? lastException;
    
    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        // Check if we should retry this exception
        if (retryCondition != null && !retryCondition(lastException)) {
          throw lastException;
        }
        
        attempt++;
        
        if (attempt >= maxRetries) {
          throw lastException;
        }
        
        // Calculate delay with exponential backoff and jitter
        final delay = _calculateDelay(attempt, baseDelay, maxDelay);
        await Future.delayed(delay);
      }
    }
    
    throw lastException ?? Exception('Unknown error occurred');
  }
  
  // Calculate delay with exponential backoff and jitter
  static Duration _calculateDelay(int attempt, Duration baseDelay, Duration maxDelay) {
    final exponentialDelay = baseDelay * pow(2, attempt - 1);
    final jitter = Duration(milliseconds: Random().nextInt(1000));
    final totalDelay = exponentialDelay + jitter;
    
    return totalDelay > maxDelay ? maxDelay : totalDelay;
  }
  
  // Handle network failures
  static Future<T> handleNetworkFailure<T>(
    Future<T> Function() operation,
  ) async {
    return retryWithBackoff(
      operation,
      retryCondition: (exception) {
        // Retry on network-related exceptions
        return exception.toString().toLowerCase().contains('network') ||
               exception.toString().toLowerCase().contains('timeout') ||
               exception.toString().toLowerCase().contains('connection');
      },
    );
  }
  
  // Handle API failures
  static Future<T> handleApiFailure<T>(
    Future<T> Function() operation,
  ) async {
    return retryWithBackoff(
      operation,
      retryCondition: (exception) {
        // Retry on API-related exceptions
        return exception.toString().toLowerCase().contains('api') ||
               exception.toString().toLowerCase().contains('http') ||
               exception.toString().toLowerCase().contains('server');
      },
    );
  }
  
  // Handle sync conflicts
  static Future<T> handleSyncConflict<T>(
    Future<T> Function() operation,
    T Function() conflictResolver,
  ) async {
    try {
      return await operation();
    } catch (e) {
      if (e.toString().toLowerCase().contains('conflict')) {
        // Resolve conflict using provided resolver
        return conflictResolver();
      }
      rethrow;
    }
  }
  
  // Validate data integrity
  static bool validateDataIntegrity(String data, String expectedHash) {
    try {
      // Simple hash validation - in real app, use proper hashing
      final actualHash = data.hashCode.toString();
      return actualHash == expectedHash;
    } catch (e) {
      return false;
    }
  }
  
  // Handle data corruption
  static T handleDataCorruption<T>(
    T Function() dataAccessor,
    T Function() fallbackProvider,
  ) {
    try {
      final data = dataAccessor();
      // Validate data integrity
      if (data == null) {
        return fallbackProvider();
      }
      return data;
    } catch (e) {
      // Data corruption detected, use fallback
      return fallbackProvider();
    }
  }
  
  // Handle storage limits
  static Future<void> handleStorageLimit(
    Future<void> Function() operation,
    Future<void> Function() cleanupOperation,
  ) async {
    try {
      await operation();
    } catch (e) {
      if (e.toString().toLowerCase().contains('storage') ||
          e.toString().toLowerCase().contains('space')) {
        // Storage limit reached, perform cleanup
        await cleanupOperation();
        // Retry operation after cleanup
        await operation();
      } else {
        rethrow;
      }
    }
  }
  
  // Handle AI service errors
  static Future<T> handleAiServiceError<T>(
    Future<T> Function() operation,
    T Function() fallbackResponse,
  ) async {
    try {
      return await operation();
    } catch (e) {
      // Log AI service error
      print('AI Service Error: $e');
      
      // Check if it's a rate limiting error
      if (e.toString().toLowerCase().contains('rate limit')) {
        // Wait and retry once
        await Future.delayed(const Duration(seconds: 5));
        try {
          return await operation();
        } catch (e2) {
          return fallbackResponse();
        }
      }
      
      // For other AI errors, return fallback response
      return fallbackResponse();
    }
  }
  
  // Handle authentication errors
  static Future<T> handleAuthError<T>(
    Future<T> Function() operation,
    Future<void> Function() refreshToken,
    Future<T> Function() retryOperation,
  ) async {
    try {
      return await operation();
    } catch (e) {
      if (e.toString().toLowerCase().contains('unauthorized') ||
          e.toString().toLowerCase().contains('token')) {
        // Token expired, refresh and retry
        await refreshToken();
        return await retryOperation();
      }
      rethrow;
    }
  }
  
  // Handle role mismatch errors
  static void handleRoleMismatch(String requiredRole, String userRole) {
    throw Exception(
      'Access denied. Required role: $requiredRole, User role: $userRole',
    );
  }
  
  // Handle verification failures
  static Future<T> handleVerificationFailure<T>(
    Future<T> Function() operation,
    String errorMessage,
  ) async {
    try {
      return await operation();
    } catch (e) {
      throw Exception('Verification failed: $errorMessage');
    }
  }
  
  // Global error handler
  static void handleGlobalError(dynamic error, StackTrace stackTrace) {
    // Log error to crash reporting service
    print('Global Error: $error');
    print('Stack Trace: $stackTrace');
    
    // In production, send to crash reporting service like Sentry
    // Sentry.captureException(error, stackTrace: stackTrace);
  }
  
  // Error recovery strategies
  static Future<T> recoverFromError<T>(
    Future<T> Function() operation,
    List<Future<T> Function()> recoveryStrategies,
  ) async {
    try {
      return await operation();
    } catch (e) {
      // Try recovery strategies in order
      for (final strategy in recoveryStrategies) {
        try {
          return await strategy();
        } catch (recoveryError) {
          // Continue to next strategy
          continue;
        }
      }
      
      // All recovery strategies failed
      rethrow;
    }
  }
}

// Circuit breaker pattern for external services
class CircuitBreaker {
  static final Map<String, CircuitBreakerState> _states = {};
  
  static Future<T> execute<T>(
    String serviceName,
    Future<T> Function() operation,
    T Function() fallback,
  ) async {
    final state = _states.putIfAbsent(
      serviceName,
      () => CircuitBreakerState(),
    );
    
    if (state.isOpen) {
      if (state.nextAttempt != null && DateTime.now().isAfter(state.nextAttempt!)) {
        state.halfOpen();
      } else {
        return fallback();
      }
    }
    
    try {
      final result = await operation();
      state.onSuccess();
      return result;
    } catch (e) {
      state.onFailure();
      return fallback();
    }
  }
}

// Circuit breaker state
class CircuitBreakerState {
  int _failureCount = 0;
  DateTime? _nextAttempt;
  bool _isOpen = false;
  
  bool get isOpen => _isOpen;
  DateTime? get nextAttempt => _nextAttempt;
  
  void onSuccess() {
    _failureCount = 0;
    _isOpen = false;
    _nextAttempt = null;
  }
  
  void onFailure() {
    _failureCount++;
    // Track failure time for circuit breaker logic
    
    if (_failureCount >= 5) {
      _isOpen = true;
      _nextAttempt = DateTime.now().add(const Duration(minutes: 5));
    }
  }
  
  void halfOpen() {
    _isOpen = false;
  }
}

// Data cleanup policies
class DataCleanupService {
  Future<void> cleanupOldData({
    Duration maxAge = const Duration(days: 30),
    int maxItems = 1000,
  }) async {
    try {
      // Clean up old cached data
      // This would be implemented based on your storage solution
      print('Cleaning up old data older than $maxAge or more than $maxItems items');
    } catch (e) {
      print('Failed to cleanup old data: $e');
    }
  }
  
  // Health check for services
  Future<bool> healthCheck(String serviceName) async {
    try {
      // Implement health check logic for each service
      switch (serviceName) {
        case 'ai_service':
          // Check AI service health
          return true;
        case 'map_service':
          // Check map service health
          return true;
        case 'notification_service':
          // Check notification service health
          return true;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}