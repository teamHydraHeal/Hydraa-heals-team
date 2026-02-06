import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Service to communicate with the Ollama-powered chat backend.
/// Handles conversation history, context injection, and response streaming.
class ChatService {
  static String _baseUrl = _detectBaseUrl();

  static String _detectBaseUrl() {
    if (kIsWeb) {
      final host = web.window.location.hostname;
      return 'http://$host:5001';
    }
    return 'http://localhost:5001';
  }

  static void setBaseUrl(String url) => _baseUrl = url;

  /// Send a message to the Ollama chat and get a response.
  ///
  /// [message] — the user's text
  /// [history] — list of previous messages [{role: 'user'|'assistant', content: '...'}]
  /// [context] — optional context data (current action plan, ML predictions, etc.)
  ///
  /// Returns a map with:
  ///   response (String) — the AI's reply
  ///   llm_used (bool)   — whether Ollama was used or a fallback
  ///   model (String)     — model name used
  static Future<Map<String, dynamic>> sendMessage(
    String message, {
    List<Map<String, String>>? history,
    Map<String, dynamic>? context,
  }) async {
    try {
      final body = <String, dynamic>{
        'message': message,
      };
      if (history != null && history.isNotEmpty) {
        body['history'] = history;
      }
      if (context != null && context.isNotEmpty) {
        body['context'] = context;
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('Chat error: ${response.statusCode} ${response.body}');
        return {
          'response': 'Sorry, I couldn\'t process that request. Please try again.',
          'llm_used': false,
          'model': 'error',
        };
      }
    } catch (e) {
      debugPrint('Chat request failed: $e');
      return {
        'response':
            'Unable to reach the AI backend. Check that the server is running.',
        'llm_used': false,
        'model': 'offline',
      };
    }
  }

  /// Check Ollama status — whether the LLM is running and model loaded.
  static Future<Map<String, dynamic>> checkOllamaStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/ollama/status'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {'ollama_running': false};
    } catch (_) {
      return {'ollama_running': false};
    }
  }

  /// Check if the backend is reachable at all.
  static Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/tts/languages'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
