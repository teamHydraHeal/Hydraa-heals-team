import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  
  bool _isOnline = true;
  ConnectivityResult _connectivityResult = ConnectivityResult.wifi;
  bool _isInitialized = false;
  int _pendingSyncCount = 0;
  DateTime? _lastSyncTime;

  bool get isOnline => _isOnline;
  ConnectivityResult get connectivityResult => _connectivityResult;
  bool get isInitialized => _isInitialized;
  int get pendingSyncCount => _pendingSyncCount;
  DateTime? get lastSyncTime => _lastSyncTime;

  ConnectivityProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Get initial connectivity status
      final result = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(result);
      
      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen((result) {
        _updateConnectivityStatus(result);
      });
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize connectivity: $e');
    }
  }

  void _updateConnectivityStatus(ConnectivityResult result) {
    _connectivityResult = result;
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectivityStatus(result);
      return _isOnline;
    } catch (e) {
      debugPrint('Failed to check connectivity: $e');
      return false;
    }
  }

  String get connectivityStatus {
    if (!_isOnline) return 'Offline';
    
    switch (_connectivityResult) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'Offline';
    }
  }

  bool get isWifi => _connectivityResult == ConnectivityResult.wifi;
  bool get isMobileData => _connectivityResult == ConnectivityResult.mobile;
  bool get isLowBandwidth => isMobileData;

  // Update pending sync count
  void updatePendingSyncCount(int count) {
    _pendingSyncCount = count;
    notifyListeners();
  }

  // Update last sync time
  void updateLastSyncTime(DateTime time) {
    _lastSyncTime = time;
    notifyListeners();
  }

  // Attempt to sync data
  Future<void> attemptSync() async {
    if (!_isOnline) return;
    
    try {
      // Mock sync operation
      await Future.delayed(const Duration(seconds: 2));
      
      _pendingSyncCount = 0;
      _lastSyncTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }
}
