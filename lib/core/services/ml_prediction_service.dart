import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

/// Service to communicate with the jal-ML Flask backend
/// that runs the trained RandomForest model + rule-based risk engine.
class MlPredictionService {
  // Auto-detect backend URL: use same host as the page on web, localhost for native
  static String _baseUrl = _detectBaseUrl();

  static String _detectBaseUrl() {
    if (kIsWeb) {
      final location = web.window.location;
      final port = location.port;
      // When served via nginx (Docker), use same origin — nginx proxies API calls
      // When running locally via `flutter run`, use port 5001 for direct backend access
      final isNginxServed = port == '' || port == '80' || port == '9090';
      if (isNginxServed) {
        return location.origin;
      }
      return 'http://${location.hostname}:5001';
    }
    return 'http://localhost:5001';
  }

  /// Override the backend URL (e.g. for production deployment on Render)
  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  /// Call `/predict` on the Flask backend with water-quality + symptom data.
  ///
  /// Returns a map like:
  /// ```json
  /// {
  ///   "status": "RED",
  ///   "rule_status": "RED",
  ///   "ml_status": "RED",
  ///   "total_risk": 0.72,
  ///   "risks": { "ph": 0.4, "turbidity": 0.8, ... },
  ///   "advisory": "High water turbidity risk detected ...",
  ///   "processed_data": { "ph": 5.8, ... }
  /// }
  /// ```
  static Future<Map<String, dynamic>?> predict({
    double? ph,
    double? turbidity,
    double? orp,
    double? rainfall,
    int? diarrhea,
    int? vomiting,
    int? fever,
    String? reportText,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (ph != null) body['ph'] = ph;
      if (turbidity != null) body['turbidity'] = turbidity;
      if (orp != null) body['orp'] = orp;
      if (rainfall != null) body['rainfall'] = rainfall;
      if (diarrhea != null) body['diarrhea'] = diarrhea;
      if (vomiting != null) body['vomiting'] = vomiting;
      if (fever != null) body['fever'] = fever;
      if (reportText != null) body['report_text'] = reportText;

      final response = await http
          .post(
            Uri.parse('$_baseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('ML Prediction: $data');
        return data;
      } else {
        debugPrint('ML backend returned ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('ML prediction failed (backend may not be running): $e');
      return null;
    }
  }

  /// Convenience: predict from a free-form text report
  static Future<Map<String, dynamic>?> predictFromText(String reportText) {
    return predict(reportText: reportText);
  }

  /// Check if the ML backend is reachable
  static Future<bool> isBackendAvailable() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
