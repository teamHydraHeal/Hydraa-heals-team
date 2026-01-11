import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SecurityService {
  static const String _encryptionKey = 'jal_guard_encryption_key_2024';
  static const String _userTokenKey = 'user_auth_token';
  static const String _sessionKey = 'user_session';
  
  // Generate secure session token
  static String generateSessionToken() {
    final uuid = const Uuid();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomString = uuid.v4();
    
    final tokenData = '$timestamp:$randomString';
    final bytes = utf8.encode(tokenData);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }
  
  // Hash password with salt
  static String hashPassword(String password, {String? salt}) {
    final saltToUse = salt ?? _generateSalt();
    final combined = '$password:$saltToUse';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    
    return '$saltToUse:${digest.toString()}';
  }
  
  // Verify password
  static bool verifyPassword(String password, String hashedPassword) {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) return false;
      
      final salt = parts[0];
      
      final computedHash = hashPassword(password, salt: salt);
      return computedHash == hashedPassword;
    } catch (e) {
      return false;
    }
  }
  
  // Generate salt
  static String _generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
  
  // Encrypt sensitive data
  static String encryptData(String data) {
    try {
      // Simple XOR encryption for demo - in production, use AES encryption
      final key = _encryptionKey;
      final keyBytes = utf8.encode(key);
      final dataBytes = utf8.encode(data);
      
      final encrypted = <int>[];
      for (int i = 0; i < dataBytes.length; i++) {
        encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64.encode(encrypted);
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }
  
  // Decrypt sensitive data
  static String decryptData(String encryptedData) {
    try {
      final key = _encryptionKey;
      final keyBytes = utf8.encode(key);
      final encryptedBytes = base64.decode(encryptedData);
      
      final decrypted = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decrypted.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
  
  // Store encrypted data in SharedPreferences
  static Future<void> storeEncryptedData(String key, String data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = encryptData(data);
      await prefs.setString(key, encryptedData);
    } catch (e) {
      throw Exception('Failed to store encrypted data: $e');
    }
  }
  
  // Retrieve and decrypt data from SharedPreferences
  static Future<String?> getEncryptedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString(key);
      
      if (encryptedData == null) return null;
      
      return decryptData(encryptedData);
    } catch (e) {
      throw Exception('Failed to retrieve encrypted data: $e');
    }
  }
  
  // Store user session
  static Future<void> storeUserSession(String userId, String token) async {
    try {
      final sessionData = {
        'userId': userId,
        'token': token,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiresAt': DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch,
      };
      
      await storeEncryptedData(_sessionKey, json.encode(sessionData));
    } catch (e) {
      throw Exception('Failed to store user session: $e');
    }
  }
  
  // Get user session
  static Future<Map<String, dynamic>?> getUserSession() async {
    try {
      final sessionData = await getEncryptedData(_sessionKey);
      if (sessionData == null) return null;
      
      final session = json.decode(sessionData) as Map<String, dynamic>;
      final expiresAt = session['expiresAt'] as int;
      
      // Check if session is expired
      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await clearUserSession();
        return null;
      }
      
      return session;
    } catch (e) {
      return null;
    }
  }
  
  // Clear user session
  static Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove(_userTokenKey);
    } catch (e) {
      throw Exception('Failed to clear user session: $e');
    }
  }
  
  // Validate user access
  static Future<bool> validateUserAccess(String userId, String requiredRole) async {
    try {
      final session = await getUserSession();
      if (session == null) return false;
      
      final sessionUserId = session['userId'] as String;
      if (sessionUserId != userId) return false;
      
      // In a real app, you would check user roles from the database
      // For demo purposes, we'll use a simple validation
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Generate secure API key
  static String generateApiKey() {
    final uuid = const Uuid();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomString = uuid.v4();
    
    final keyData = 'jal_guard:$timestamp:$randomString';
    final bytes = utf8.encode(keyData);
    final digest = sha256.convert(bytes);
    
    return 'jg_${digest.toString().substring(0, 32)}';
  }
  
  // Hash sensitive data for storage
  static String hashSensitiveData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Validate data integrity
  static bool validateDataIntegrity(String data, String hash) {
    final computedHash = hashSensitiveData(data);
    return computedHash == hash;
  }
  
  // Sanitize user input
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    String result = input;
    result = result.replaceAll('<', '');
    result = result.replaceAll('>', '');
    result = result.replaceAll('"', '');
    result = result.replaceAll("'", '');
    result = result.replaceAll('{', '');
    result = result.replaceAll('}', '');
    result = result.replaceAll('[', '');
    result = result.replaceAll(']', '');
    return result.trim();
  }
  
  // Validate Aadhaar number format
  static bool validateAadhaarNumber(String aadhaarNumber) {
    // Remove spaces and check if it's 12 digits
    final cleaned = aadhaarNumber.replaceAll(' ', '');
    return RegExp(r'^\d{12}$').hasMatch(cleaned);
  }
  
  // Validate phone number format
  static bool validatePhoneNumber(String phoneNumber) {
    // Remove spaces and check if it's a valid Indian phone number
    final cleaned = phoneNumber.replaceAll(' ', '').replaceAll('-', '');
    return RegExp(r'^(\+91|91)?[6-9]\d{9}$').hasMatch(cleaned);
  }
  
  // Generate secure file name
  static String generateSecureFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalName.split('.').last;
    final uuid = const Uuid().v4();
    
    return '${timestamp}_${uuid}.$extension';
  }
  
  // Check if data contains sensitive information
  static bool containsSensitiveData(String data) {
    final sensitivePatterns = [
      RegExp(r'\b\d{12}\b'), // Aadhaar numbers
      RegExp(r'\b\d{10}\b'), // Phone numbers
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Email addresses
      RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), // Credit card numbers
    ];
    
    return sensitivePatterns.any((pattern) => pattern.hasMatch(data));
  }
  
  // Mask sensitive data for display
  static String maskSensitiveData(String data, {String maskChar = '*'}) {
    if (data.length <= 4) return maskChar * data.length;
    
    final start = data.substring(0, 2);
    final end = data.substring(data.length - 2);
    final middle = maskChar * (data.length - 4);
    
    return '$start$middle$end';
  }
  
  // Audit log entry
  static Future<void> logSecurityEvent(String event, String userId, {Map<String, dynamic>? metadata}) async {
    try {
      final logEntry = {
        'event': event,
        'userId': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata ?? {},
        'sessionId': await _getCurrentSessionId(),
      };
      
      // In a real app, this would be sent to a secure logging service
      print('Security Event: ${json.encode(logEntry)}');
    } catch (e) {
      print('Failed to log security event: $e');
    }
  }
  
  // Get current session ID
  static Future<String?> _getCurrentSessionId() async {
    try {
      final session = await getUserSession();
      return session?['token'] as String?;
    } catch (e) {
      return null;
    }
  }
  
  // Check for suspicious activity
  static Future<bool> detectSuspiciousActivity(String userId, String action) async {
    try {
      // In a real app, this would analyze user behavior patterns
      // For demo purposes, we'll implement basic checks
      
      final session = await getUserSession();
      if (session == null) return true; // No session is suspicious
      
      final timestamp = session['timestamp'] as int;
      final timeSinceLogin = DateTime.now().millisecondsSinceEpoch - timestamp;
      
      // Flag if user has been active for more than 8 hours
      if (timeSinceLogin > 8 * 60 * 60 * 1000) {
        await logSecurityEvent('suspicious_long_session', userId);
        return true;
      }
      
      return false;
    } catch (e) {
      return true; // Err on the side of caution
    }
  }
  
  // Encrypt file data
  static Uint8List encryptFileData(Uint8List fileData) {
    try {
      final key = _encryptionKey;
      final keyBytes = utf8.encode(key);
      
      final encrypted = <int>[];
      for (int i = 0; i < fileData.length; i++) {
        encrypted.add(fileData[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return Uint8List.fromList(encrypted);
    } catch (e) {
      throw Exception('File encryption failed: $e');
    }
  }
  
  // Decrypt file data
  static Uint8List decryptFileData(Uint8List encryptedData) {
    try {
      final key = _encryptionKey;
      final keyBytes = utf8.encode(key);
      
      final decrypted = <int>[];
      for (int i = 0; i < encryptedData.length; i++) {
        decrypted.add(encryptedData[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return Uint8List.fromList(decrypted);
    } catch (e) {
      throw Exception('File decryption failed: $e');
    }
  }
  
  // Generate secure random string
  static String generateSecureRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final bytes = utf8.encode(random.toString());
    final digest = sha256.convert(bytes);
    
    final hashString = digest.toString();
    final result = StringBuffer();
    
    for (int i = 0; i < length; i++) {
      final index = int.parse(hashString.substring(i * 2, i * 2 + 2), radix: 16) % chars.length;
      result.write(chars[index]);
    }
    
    return result.toString();
  }
}
