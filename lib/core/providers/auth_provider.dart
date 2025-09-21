import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize auth state from local storage
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      
      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentUser = User.fromJson(userData);
        _isAuthenticated = true;
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Send OTP for Aadhaar verification
  Future<bool> sendOtp(String aadhaarNumber) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Validate Aadhaar format (12 digits)
      if (aadhaarNumber.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadhaarNumber)) {
        _setError('Please enter a valid 12-digit Aadhaar number');
        return false;
      }

      // Mock OTP sending - in real app, this would call an API
      await Future.delayed(const Duration(seconds: 1));
      
      // Store Aadhaar number for verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_aadhaar', aadhaarNumber);
      
      return true;
    } catch (e) {
      _setError('Failed to send OTP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP and authenticate user
  Future<bool> verifyOtp(String otp) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Demo OTP is 123456
      if (otp != '123456') {
        _setError('Invalid OTP. Please use 123456 for demo');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final aadhaarNumber = prefs.getString('pending_aadhaar');
      
      if (aadhaarNumber == null) {
        _setError('Aadhaar number not found. Please try again.');
        return false;
      }

      // Mock user creation based on Aadhaar number
      final user = await _createMockUser(aadhaarNumber);
      
      if (user != null) {
        await _saveUser(user);
        _currentUser = user;
        _isAuthenticated = true;
        
        // Clear pending Aadhaar
        await prefs.remove('pending_aadhaar');
        
        return true;
      } else {
        _setError('Failed to create user account');
        return false;
      }
    } catch (e) {
      _setError('Failed to verify OTP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Professional verification for ASHA workers and Health Officials
  Future<bool> verifyProfessional(String professionalId, String documentType) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_currentUser == null) {
        _setError('No user found. Please login again.');
        return false;
      }

      // Mock professional verification
      await Future.delayed(const Duration(seconds: 2));
      
      // Update user verification status
      final updatedUser = _currentUser!.copyWith(
        professionalId: professionalId,
        isVerified: true,
      );
      
      await _saveUser(updatedUser);
      _currentUser = updatedUser;
      
      return true;
    } catch (e) {
      _setError('Failed to verify professional credentials: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      
      _currentUser = null;
      _isAuthenticated = false;
      _clearError();
    } catch (e) {
      _setError('Failed to logout: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create mock user based on Aadhaar number
  Future<User?> _createMockUser(String aadhaarNumber) async {
    // Mock user creation logic based on Aadhaar number
    // In real app, this would call an API to get user details
    
    UserRole role;
    String name;
    String phoneNumber;
    String? district;
    String? block;
    String? village;
    
    // Determine role based on Aadhaar number pattern (demo logic)
    final lastDigit = int.parse(aadhaarNumber.substring(11));
    
    if (lastDigit % 3 == 0) {
      role = UserRole.healthOfficial;
      name = 'Dr. Rajesh Kumar';
      phoneNumber = '+91-9876543210';
      district = 'East Khasi Hills';
      block = 'Shillong';
    } else if (lastDigit % 3 == 1) {
      role = UserRole.ashaWorker;
      name = 'Meera Devi';
      phoneNumber = '+91-9876543211';
      district = 'East Khasi Hills';
      block = 'Mawryngkneng';
      village = 'Mawryngkneng';
    } else {
      role = UserRole.citizen;
      name = 'Amit Singh';
      phoneNumber = '+91-9876543212';
      district = 'East Khasi Hills';
      block = 'Shillong';
      village = 'Shillong';
    }
    
    return User(
      id: 'user_${aadhaarNumber}',
      aadhaarNumber: aadhaarNumber,
      name: name,
      phoneNumber: phoneNumber,
      role: role,
      isVerified: role == UserRole.citizen,
      district: district,
      block: block,
      village: village,
      createdAt: DateTime.now(),
      preferences: {
        'language': 'en',
        'notifications': true,
        'location_sharing': true,
      },
    );
  }

  // Save user to local storage
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(user.toJson()));
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
